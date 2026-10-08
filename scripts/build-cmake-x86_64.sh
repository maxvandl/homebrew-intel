#!/bin/bash
# Нативная кросс-сборка cmake под x86_64 macOS на Apple Silicon.
# Конфигурация повторяет формулу homebrew-core (bootstrap --no-system-libs,
# системные zlib/bzip2/curl). Компилятор — arm64 clang из CLT с "-arch x86_64";
# bootstrap-cmake запускается через Rosetta.
set -euo pipefail
VER=4.4.4
ROOT=/Users/lin/llvm/cmake
SRC=$ROOT/cmake-$VER
BLD=$ROOT/build
PREFIX=/usr/local/Cellar/cmake/$VER
STAGE=$ROOT/stage
CLT=/Library/Developer/CommandLineTools

export SDKROOT=$CLT/SDKs/MacOSX26.sdk
export PATH=$CLT/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin
export CC="$CLT/usr/bin/clang -arch x86_64"
export CXX="$CLT/usr/bin/clang++ -arch x86_64"
export MACOSX_DEPLOYMENT_TARGET=26.0

rm -rf "$STAGE" "$BLD"; mkdir -p "$BLD"; cd "$BLD"
"$SRC/bootstrap" --prefix="$PREFIX" --no-system-libs --parallel="$(sysctl -n hw.ncpu)" \
  --datadir=/share/cmake --docdir=/share/doc/cmake --mandir=/share/man \
  --system-zlib --system-bzip2 --system-curl
make -j"$(sysctl -n hw.ncpu)"
make install DESTDIR="$STAGE"
echo "Готово: $STAGE$PREFIX"
file "$STAGE$PREFIX/bin/cmake"
