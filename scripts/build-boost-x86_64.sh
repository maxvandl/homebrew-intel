#!/bin/bash
# Нативная кросс-сборка boost под x86_64 macOS на Apple Silicon (аргументы b2 как у homebrew-core).
# b2 собирается и работает нативно (arm64), toolset darwin получает "clang++ -arch x86_64" и
# architecture=x86 address-model=64. b2 не умеет DESTDIR, поэтому --prefix указывает прямо в stage,
# а install name'ы потом переписываются на /usr/local/opt/boost (и на opt других keg'ов).
set -euo pipefail
VER=1.92.0
ICU=icu4c@79
ROOT=/Users/lin/llvm
SRC=$ROOT/boost/src
PREFIX=/usr/local/Cellar/boost/$VER
STAGE=$ROOT/boost/stage
CLT=/Library/Developer/CommandLineTools; export DEVELOPER_DIR=$CLT
SDK=$CLT/SDKs/MacOSX26.sdk   # не SDK 27: слабые символы ломают результат на macOS 26
export PATH=$CLT/usr/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
export MACOSX_DEPLOYMENT_TARGET=26.0

mkdir -p "$ROOT/boost"; cd "$ROOT/boost"
[ -f "boost-$VER-b2-nodocs.tar.xz" ] || curl -fLO "https://github.com/boostorg/boost/releases/download/boost-$VER/boost-$VER-b2-nodocs.tar.xz"
rm -rf "$SRC" "$STAGE"; mkdir -p "$SRC"; tar xf "boost-$VER-b2-nodocs.tar.xz" -C "$SRC" --strip-components 1

# icu4c@79 из этого tap может быть ещё не установлен: на время сборки opt -> staged keg
TMPLINK=""
if [ ! -e "/usr/local/opt/$ICU" ]; then
  ln -s "$(ls -d "$ROOT/$ICU"/stage/usr/local/Cellar/$ICU/* | tail -1)" "/usr/local/opt/$ICU"; TMPLINK=/usr/local/opt/$ICU
fi
trap '[ -n "$TMPLINK" ] && rm -f "$TMPLINK"' EXIT

cd "$SRC"
echo "using darwin : : $CLT/usr/bin/clang++ -arch x86_64 -isysroot $SDK ;" > user-config.jam
SDKROOT= ./bootstrap.sh --prefix="$STAGE$PREFIX" --libdir="$STAGE$PREFIX/lib" --with-icu=/usr/local/opt/$ICU \
  --without-libraries=python,mpi
INC=""; LNK=""
for d in $ICU xz zstd; do INC="$INC cxxflags=-I/usr/local/opt/$d/include cflags=-I/usr/local/opt/$d/include"; LNK="$LNK linkflags=-L/usr/local/opt/$d/lib"; done
./b2 headers
./b2 --prefix="$STAGE$PREFIX" --libdir="$STAGE$PREFIX/lib" -d2 -j"$(sysctl -n hw.ncpu)" --layout=system \
  --user-config=user-config.jam install threading=multi link=shared,static \
  architecture=x86 address-model=64 \
  cxxflags=-std=c++17 cxxflags=-stdlib=libc++ linkflags=-stdlib=libc++ \
  linkflags=-Wl,-headerpad_max_install_names $INC $LNK -sICU_PATH=/usr/local/opt/$ICU

# install name'ы: @rpath/libboost_*.dylib и пути stage -> /usr/local/opt/boost/lib
K=$STAGE$PREFIX
for f in "$K"/lib/*.dylib; do
  [ -L "$f" ] && continue
  n=$(basename "$f")
  install_name_tool -id "/usr/local/opt/boost/lib/$n" "$f"
  otool -L "$f" | tail -n +2 | awk '{print $1}' | while read -r dep; do
    case $dep in
      @rpath/libboost_*|libboost_*|"$K"/*) install_name_tool -change "$dep" "/usr/local/opt/boost/lib/$(basename "$dep")" "$f" ;;
    esac
  done
done
# в cmake-конфигах путь stage -> Cellar
grep -rl "$STAGE" "$K" 2>/dev/null | while read -r f; do sed -i '' "s|$STAGE||g" "$f"; done
"$ROOT/homebrew-intel/scripts/fix-opt-paths.sh" "$K"
echo "Готово: $K"
