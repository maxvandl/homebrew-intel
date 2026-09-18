#!/bin/bash
# Нативная кросс-сборка Node.js под x86_64 macOS на Apple Silicon.
# CC с "-arch x86_64" заставляет configure считать хост x86_64: никакого
# cross_compiling-режима, snapshot и code cache включены, вспомогательные
# инструменты сборки (mksnapshot и т.п.) выполняются под Rosetta.
set -euo pipefail
VER=26.8.2
ROOT=/Users/lin/llvm/node
SRC=$ROOT/node-v$VER
PREFIX=/usr/local/Cellar/node/$VER      # как у Homebrew; реальная установка идёт в STAGE
STAGE=$ROOT/stage

export CC="$(xcrun -f clang) -arch x86_64"
export CXX="$(xcrun -f clang++) -arch x86_64"
export CC_host="$CC" CXX_host="$CXX"
export PYTHON=/opt/homebrew/bin/python3
export PATH=/opt/homebrew/opt/rustup/bin:$PATH   # rustup-toolchain с rust-std для x86_64-apple-darwin (brew rust его не имеет)
export SDKROOT="$(xcrun --show-sdk-path)"   # clang по полному пути без этого не находит SDK

cd "$SRC"
[ -f config.gypi ] || $PYTHON ./configure --prefix="$PREFIX" --dest-cpu=x64 \
  --with-intl=full-icu --shared --disable-single-executable-application
make -j10
rm -rf "$STAGE"
make install DESTDIR="$STAGE"
echo "Готово: $STAGE$PREFIX"
file "$STAGE$PREFIX/bin/node"
