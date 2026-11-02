#!/usr/bin/env python3
# Выпуск готового x86_64 keg'а: tar -> GitHub Release -> Formula/<name>.rb -> README -> brew style -> commit/push.
# usage: release-keg.py NAME VERSION STAGE_KEG SCRIPT_DESC [--test 'ruby'] [--notes 'текст'] [--no-push]
#   STAGE_KEG — .../stage/usr/local/Cellar/NAME/VERSION
#   SCRIPT_DESC — чем собрано, например "scripts/build-cmakeproj-x86_64.sh"
# desc/homepage/license/зависимости/keg_only берутся из homebrew-core (arm64 brew info --json=v2).
# Зависимости, для которых в tap есть своя формула, пишутся как maxvandl/intel/<dep>.
import argparse, hashlib, json, os, re, subprocess, sys

TAP = "/Users/lin/llvm/homebrew-intel"
REPO = "maxvandl/homebrew-intel"
INTEL_BREW = ["arch", "-x86_64", "/usr/local/bin/brew"]

ap = argparse.ArgumentParser()
ap.add_argument("name"); ap.add_argument("version"); ap.add_argument("keg"); ap.add_argument("script")
ap.add_argument("--test", default=None)
ap.add_argument("--install", default=None, help="тело def install (по умолчанию prefix.install)")
ap.add_argument("--extra", default=None, help="строки DSL после depends_on (link_overwrite, post_install_steps...)")
ap.add_argument("--notes", default="")
ap.add_argument("--no-push", action="store_true")
ap.add_argument("--deps", default=None, help="список зависимостей через пробел вместо core (\"\" — без зависимостей)")
a = ap.parse_args()

def run(cmd, **kw):
    print("+", " ".join(cmd) if isinstance(cmd, list) else cmd, flush=True)
    return subprocess.run(cmd, check=True, **kw)

info = json.loads(subprocess.check_output(["brew", "info", "--json=v2", a.name]))["formulae"][0]
keg = os.path.abspath(a.keg)
assert os.path.basename(keg) == a.version, keg
tarname = f"{a.name}-{a.version}-x86_64-macos.tar.gz"
tarpath = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(keg)))))), tarname)
run(["tar", "czf", tarpath, "-C", os.path.dirname(keg), a.version])
sha = hashlib.sha256(open(tarpath, "rb").read()).hexdigest()

tag = f"{a.name}-{a.version}"
tag_url = tag.replace("@", "%40")
env = dict(os.environ, GH_TOKEN=subprocess.check_output(["gh", "auth", "token", "-u", "maxvandl"], text=True).strip())
notes = (f"Prebuilt x86_64 macOS keg of {a.name} {a.version}, cross-built natively on Apple Silicon with "
         f"`{a.script}` against the macOS 26 SDK. Install names point at `/usr/local/opt/*`."
         + (f"\n\n{a.notes}" if a.notes else "") + f"\n\nsha256 {sha}")
exists = subprocess.run(["gh", "release", "view", tag, "-R", REPO], env=env, capture_output=True).returncode == 0
if exists:
    run(["gh", "release", "upload", tag, tarpath, "--clobber", "-R", REPO], env=env)
    run(["gh", "release", "edit", tag, "--notes", notes, "-R", REPO], env=env)
else:
    run(["gh", "release", "create", tag, tarpath, "-R", REPO, "--title", f"{a.name} {a.version} (x86_64 macOS keg)",
         "--notes", notes], env=env)

# --- формула
# как Formulary.class_s: c-ares -> CAres, icu4c@78 -> Icu4cAT78, python@3.12 -> PythonAT312
cls = "".join(p[:1].upper() + p[1:] for p in re.split(r"[-_]", a.name.replace("+", "x")))
cls = re.sub(r"@", "AT", cls).replace(".", "")
desc = info["desc"]
suffix = " (prebuilt x86_64 keg)"
desc = desc + suffix if len(desc) + len(suffix) < 80 else desc
lic = info.get("license") or ""
tap_formulae = {f[:-3] for f in os.listdir(f"{TAP}/Formula")} | {a.name}
deps = []
for d in (a.deps.split() if a.deps is not None else info["dependencies"]):
    deps.append(f"maxvandl/intel/{d}" if d in tap_formulae else d)
lines = [f"# Готовый x86_64 keg {a.name} {a.version}, кросс-собранный нативно на Apple Silicon",
         f"# скриптом {a.script} (параметры как у формулы homebrew-core).",
         f"class {cls} < Formula",
         f'  desc "{desc}"',
         f'  homepage "{info["homepage"]}"',
         f'  url "https://github.com/{REPO}/releases/download/{tag_url}/{tarname}"',
         f'  version "{a.version}"',
         f'  sha256 "{sha}"']
if lic and re.fullmatch(r"[A-Za-z0-9.+-]+", lic):
    lines.append(f'  license "{lic}"')
lines.append("")
if info.get("keg_only"):
    reason = (info.get("keg_only_reason") or {}).get("reason", "")
    lines += [f"  keg_only {reason}" if reason.startswith(":") else "  keg_only :versioned_formula", ""]
lines.append("  depends_on arch: :x86_64")
lines += [f'  depends_on "{d}"' for d in deps]
lines.append("  depends_on :macos")
lines.append("")
if a.extra:
    lines += [f"  {l}" if l else "" for l in a.extra.splitlines()] + [""]
body = a.install or 'prefix.install Dir["*"]'
lines += ["  def install"] + [f"    {l}" if l else "" for l in body.splitlines()] + ["  end", ""]
test = a.test or f'assert_path_exists prefix/"lib"'
lines += ["  test do"] + [f"    {l}" if l else "" for l in test.splitlines()] + ["  end", "end", ""]
fpath = f"{TAP}/Formula/{a.name}.rb"
open(fpath, "w").write("\n".join(lines))
subprocess.run(INTEL_BREW + ["style", "--fix", fpath])
run(INTEL_BREW + ["style", fpath])

# --- README: строка в таблице формул (перед пустой строкой после таблицы)
readme = open(f"{TAP}/README.md").read()
row_re = re.compile(rf"^\| `{re.escape(a.name)}` *\|[^|]*\|(.*)$", re.M)
if row_re.search(readme):
    readme = row_re.sub(lambda m: f"| `{a.name}` | {a.version} |{m.group(1)}", readme)
else:
    note = info["desc"] + "."
    head = readme.index("| Formula")
    end = readme.index("\n\n", head)
    readme = readme[:end] + f"\n| `{a.name}` | {a.version} | {note} |" + readme[end:]
open(f"{TAP}/README.md", "w").write(readme)

run(["git", "-C", TAP, "add", fpath, "README.md", "scripts"])
run(["git", "-C", TAP, "commit", "-qm",
     f"{a.name} {a.version}: prebuilt x86_64 keg\n\nCo-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"])
if not a.no_push:
    run(["git", "-C", TAP, "push", "-q", "origin", "main"])
print(f"OK {a.name} {a.version} {sha}")
