#!/bin/bash
# Универсальная нативная кросс-сборка autotools-проекта под x86_64 macOS на Apple Silicon.
# usage: [DEPS="xz zstd ..."] [SUBDIR=source] [OPTLINKS=...] [MAKEARGS=...] build-autotools-x86_64.sh NAME VERSION SRCDIR [configure args...]
#   DEPS   — формулы Intel-brew (/usr/local/opt/*), чьи include/lib/pkgconfig подключить (аналог superenv)
#   SUBDIR — подкаталог SRCDIR с configure (у icu4c это source)
# configure запускается под Rosetta (arch -x86_64), поэтому build==host==x86_64 и тестовые
# программы configure просто исполняются. Компилятор — arm64 clang из CLT с "-arch x86_64".
# Результат: <ROOT>/<NAME>/stage/usr/local/Cellar/<NAME>/<VERSION>, ссылки на другие keg'и через opt.
set -euo pipefail
[ "$(uname -m)" = x86_64 ] || exec arch -x86_64 /bin/bash "$0" "$@"
NAME=$1; VER=$2; SRC=$3; shift 3
ROOT=/Users/lin/llvm
PREFIX=/usr/local/Cellar/$NAME/$VER
STAGE=$ROOT/$NAME/stage
CLT=/Library/Developer/CommandLineTools; export DEVELOPER_DIR=$CLT

export SDKROOT=$CLT/SDKs/MacOSX26.sdk     # не SDK 27 из CLT 27: слабые символы (pipe2 и т.п.) ломают рантайм на macOS 26
# инструменты arm64-brew с нативными модулями (perl/python) под Rosetta не грузятся:
# обёртки запускают их как arm64 (arch -arm64)
ARMBIN=$ROOT/deps/armbin; mkdir -p "$ARMBIN"
for t in help2man; do
  printf '#!/bin/sh\nexec arch -arm64 /opt/homebrew/bin/%s "$@"\n' "$t" > "$ARMBIN/$t"; chmod +x "$ARMBIN/$t"
done
export PATH=$ARMBIN:$CLT/usr/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
export CC="$CLT/usr/bin/clang -arch x86_64" CXX="$CLT/usr/bin/clang++ -arch x86_64"
export MACOSX_DEPLOYMENT_TARGET=26.0
export PKG_CONFIG=/opt/homebrew/bin/pkgconf
CPPF=""; LDF=""; PCDIRS=""
for d in ${DEPS:-}; do
  CPPF="$CPPF -I/usr/local/opt/$d/include"; LDF="$LDF -L/usr/local/opt/$d/lib"
  for p in lib/pkgconfig share/pkgconfig; do [ -d "/usr/local/opt/$d/$p" ] && PCDIRS="$PCDIRS:/usr/local/opt/$d/$p"; done
done
export CPPFLAGS="${CPPF# }" LDFLAGS="${LDF# } -Wl,-headerpad_max_install_names"   # место для opt-путей (fix-opt-paths)
export PKG_CONFIG_LIBDIR="$ROOT/deps/pkgconfig${PCDIRS}:/usr/local/Homebrew/Library/Homebrew/os/mac/pkgconfig/26"

# OPTLINKS="openssl@4 ..." — keg'и этого tap, ещё не установленные в Intel-brew: на время сборки
# /usr/local/opt/<f> указывает на staged keg (<ROOT>/<dir>/stage*/usr/local/Cellar/<f>/<ver>)
TMPLINKS=""
for f in ${OPTLINKS:-}; do
  [ -e "/usr/local/opt/$f" ] && continue
  k=$(ls -d "$ROOT"/*/stage*/usr/local/Cellar/"$f"/* 2>/dev/null | tail -1)
  [ -n "$k" ] || { echo "ERROR: нет staged keg для $f"; exit 1; }
  ln -s "$k" "/usr/local/opt/$f"; TMPLINKS="$TMPLINKS /usr/local/opt/$f"
done
trap 'for l in $TMPLINKS; do rm -f "$l"; done' EXIT
rm -rf "$STAGE"
cd "$SRC/${SUBDIR:-.}"
make distclean >/dev/null 2>&1 || true
./configure --disable-debug --disable-dependency-tracking --prefix="$PREFIX" --libdir="$PREFIX/lib" "$@"
make -j"$(sysctl -n hw.ncpu)" ${MAKEARGS:-}
make install DESTDIR="$STAGE" ${MAKEARGS:-}
/Users/lin/llvm/homebrew-intel/scripts/fix-opt-paths.sh "$STAGE$PREFIX"
echo "Готово: $STAGE$PREFIX"
