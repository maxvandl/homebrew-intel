#!/bin/bash
# Сборка Python-приложений из homebrew-core как самодостаточных x86_64 keg'ов: venv в libexec на
# python@3.15 из этого tap, внутрь ставятся ровно те версии, что закреплены в resource'ах формулы core,
# плюс сам пакет. В отличие от core, python-зависимости, которые там вынесены в отдельные формулы
# (cryptography, cffi, pillow, rpds-py, ...), ставятся прямо в venv; нативные — x86_64-колёсами с PyPI
# (pip под x86_64-python выбирает macosx x86_64 wheels), остальные собираются из sdist arm64 clang'ом
# с "-arch x86_64". bin/ — симлинки на console scripts пакета. venv создаётся сразу по настоящему пути
# keg'а (шебанги), потом переносится в stage.
# usage: build-pyapp-x86_64.sh name [name...]
set -uo pipefail
R=/Users/lin/llvm
CLT=/Library/Developer/CommandLineTools
PY=/usr/local/opt/python@3.15/bin/python3.15
export CC="$CLT/usr/bin/clang -arch x86_64" CXX="$CLT/usr/bin/clang++ -arch x86_64" ARCHFLAGS="-arch x86_64"
export SDKROOT=$CLT/SDKs/MacOSX26.sdk MACOSX_DEPLOYMENT_TARGET=26.0 PIP_DISABLE_PIP_VERSION_CHECK=1
for n in "$@"; do (
  set -e
  W=$R/$n; mkdir -p $W; L=$W/build.log; exec > $L 2>&1
  src=$(arch -arm64 brew info --json=v2 "$n" | /usr/bin/python3 -c 'import json,sys;d=json.load(sys.stdin)["formulae"][0];print(d["ruby_source_path"], d["versions"]["stable"], d["urls"]["stable"]["url"])')
  set -- $src; path=$1; V=$2; MAINURL=$3
  curl -fsL "https://raw.githubusercontent.com/Homebrew/homebrew-core/main/$path" > $W/formula.rb
  KEG=/usr/local/Cellar/$n/$V; STAGE=$W/stage
  [ -e "$KEG" ] && { echo "ERROR: $KEG существует"; exit 1; }
  rm -rf "$STAGE"
  # name==version из имён sdist'ов resource'ов
  pins=$(grep -A1 '^  resource "' $W/formula.rb | grep -oE 'https://[^"]+' | /usr/bin/python3 -c '
import sys, re, os
for u in sys.stdin.read().split():
    b = os.path.basename(u)
    b = re.sub(r"\.(tar\.gz|tar\.bz2|tar\.xz|zip|tgz)$", "", b)
    if b.endswith(".whl"): b = b.split("-")[0] + "-" + b.split("-")[1]
    name, ver = b.rsplit("-", 1)
    print(f"{name}=={ver}")')
  main=$(basename "$MAINURL" | /usr/bin/python3 -c 'import sys,re;b=re.sub(r"\.(tar\.gz|zip|tgz)$","",sys.stdin.read().strip());n,v=b.rsplit("-",1);print(f"{n}=={v}")')
  echo "### $n $V: $main + $(echo $pins | wc -w) pins"
  "$PY" -m venv "$KEG/libexec"
  "$KEG/libexec/bin/python" -m pip install --no-deps $pins
  # python-библиотеки, которые в core — отдельные формулы-зависимости (без закрепления версий)
  extra=$(arch -arm64 brew info --json=v2 "$n" | /usr/bin/python3 -c '
import json,sys
m={"certifi":"certifi","cffi":"cffi pycparser","cryptography":"cryptography cffi pycparser","pillow":"pillow","rpds-py":"rpds-py","pycparser":"pycparser","python-setuptools":"setuptools"}
d=json.load(sys.stdin)["formulae"][0]["dependencies"]
print(" ".join(sorted(set(" ".join(m[x] for x in d if x in m).split()))))')
  [ -n "$extra" ] && "$KEG/libexec/bin/python" -m pip install --no-deps --only-binary :all: $extra
  "$KEG/libexec/bin/python" -m pip install --no-deps "$main"
  "$KEG/libexec/bin/python" -m pip check || true
  mkdir -p "$KEG/bin"
  dist=${main%%==*}
  for s in $("$KEG/libexec/bin/python" -c "import importlib.metadata as m,sys;print(' '.join(e.name for e in m.distribution(sys.argv[1]).entry_points if e.group=='console_scripts'))" "$dist"); do
    ln -s "../libexec/bin/$s" "$KEG/bin/$s"
  done
  ls "$KEG/bin"
  mkdir -p "$STAGE/usr/local/Cellar/$n"; mv "$KEG" "$STAGE/usr/local/Cellar/$n/"; rmdir "/usr/local/Cellar/$n" 2>/dev/null || true
  "$R/homebrew-intel/scripts/fix-opt-paths.sh" "$STAGE$KEG"
); echo "$n $?"; done
