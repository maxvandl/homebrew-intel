#!/bin/bash
# Нативная кросс-сборка gobject-introspection под x86_64 macOS на Apple Silicon, как формула homebrew-core:
# venv в libexec (mako, markdown, markupsafe, setuptools) на python@3.15 из этого tap, патч
# EXTRA_LIBRARY_PATHS из __END__ формулы, сборка через build-meson-x86_64.sh против glib/cairo
# этого tap (deps/pkgconfig). venv создаётся сразу по настоящему пути keg'а (шебанги), потом
# переносится в stage.
set -euo pipefail
VER=1.86.0
ROOT=/Users/lin/llvm
W=$ROOT/gobject-introspection
SRC=$W/src
KEG=/usr/local/Cellar/gobject-introspection/$VER
STAGE=$W/stage
CLT=/Library/Developer/CommandLineTools
PY=/usr/local/opt/python@3.15/bin/python3.15
[ -x "$PY" ] || { echo "ERROR: нужен python@3.15 в /usr/local/opt (установленный или staged)"; exit 1; }
[ -e "$KEG" ] && { echo "ERROR: $KEG уже существует"; exit 1; }

mkdir -p "$W"; cd "$W"
curl -fsL https://raw.githubusercontent.com/Homebrew/homebrew-core/main/Formula/g/gobject-introspection.rb > formula.rb
[ -f "gobject-introspection-$VER.tar.xz" ] || curl -fLO "https://download.gnome.org/sources/gobject-introspection/${VER%.*}/gobject-introspection-$VER.tar.xz"
rm -rf "$SRC"; mkdir -p "$SRC"; tar xf "gobject-introspection-$VER.tar.xz" -C "$SRC" --strip-components 1
cd "$SRC"
sed -n '/^__END__$/,$p' "$W/formula.rb" | sed 1d | patch -p1
sed -i '' 's|/usr/share|/usr/local/share|' giscanner/transformer.py
sed -i '' "s|config.set_quoted('GOBJECT_INTROSPECTION_LIBDIR', join_paths(get_option('prefix'), get_option('libdir')))|config.set_quoted('GOBJECT_INTROSPECTION_LIBDIR', '/usr/local/lib')|" meson.build
grep -q "'/usr/local/lib')" meson.build

echo "### venv"
"$PY" -m venv "$KEG/libexec"
CC="$CLT/usr/bin/clang -arch x86_64" "$KEG/libexec/bin/python" -m pip install --no-deps --no-binary :all: \
  $(grep -A1 'resource "' "$W/formula.rb" | grep -oE 'https://[^"]+')

echo "### meson"
export GI_SCANNER_DISABLE_CACHE=true PATH=$KEG/libexec/bin:$PATH
"$ROOT/homebrew-intel/scripts/build-meson-x86_64.sh" gobject-introspection "$VER" "$SRC" \
  -Dpython="$KEG/libexec/bin/python" -Dextra_library_paths=/usr/local/lib -Dtests=false

echo "### venv -> stage, шебанги"
mv "$KEG/libexec" "$STAGE$KEG/libexec"
rmdir "$KEG" "/usr/local/Cellar/gobject-introspection" 2>/dev/null || true
for f in "$STAGE$KEG"/bin/*; do
  head -c 2 "$f" | grep -q '#!' && sed -i '' "1s|^#!.*python.*$|#!$KEG/libexec/bin/python|" "$f"
done
"$ROOT/homebrew-intel/scripts/fix-opt-paths.sh" "$STAGE$KEG"
echo "Готово: $STAGE$KEG"
