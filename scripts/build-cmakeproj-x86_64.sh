#!/bin/bash
# Универсальная нативная кросс-сборка CMake-проекта под x86_64 macOS на Apple Silicon.
# usage: [DEPS="zstd imath ..."] build-cmakeproj-x86_64.sh NAME VERSION SRCDIR [cmake args...]
#   DEPS — формулы Intel-brew (/usr/local/opt/*), добавляемые в CMAKE_PREFIX_PATH (аналог superenv)
# Аргументы как у std_cmake_args Homebrew. cmake и ninja — arm64 из /opt/homebrew, компилятор —
# arm64 clang из CLT с CMAKE_OSX_ARCHITECTURES=x86_64; try_run-проверки исполняются под Rosetta.
# Результат: <ROOT>/<NAME>/stage/usr/local/Cellar/<NAME>/<VERSION>, ссылки на другие keg'и через opt.
set -euo pipefail
NAME=$1; VER=$2; SRC=$3; shift 3
ROOT=/Users/lin/llvm
PREFIX=/usr/local/Cellar/$NAME/$VER
STAGE=$ROOT/$NAME/stage
BLD=$ROOT/$NAME/build
CLT=/Library/Developer/CommandLineTools; export DEVELOPER_DIR=$CLT

export SDKROOT=$CLT/SDKs/MacOSX26.sdk     # не SDK 27 из CLT 27: слабые символы (pipe2 и т.п.) ломают рантайм на macOS 26
export PATH=$CLT/usr/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
export MACOSX_DEPLOYMENT_TARGET=26.0
export PKG_CONFIG=/opt/homebrew/bin/pkgconf
PP=""; PCDIRS=""
for d in ${DEPS:-}; do
  PP="$PP;/usr/local/opt/$d"
  for p in lib/pkgconfig share/pkgconfig; do [ -d "/usr/local/opt/$d/$p" ] && PCDIRS="$PCDIRS:/usr/local/opt/$d/$p"; done
done
export PKG_CONFIG_LIBDIR="$ROOT/deps/pkgconfig${PCDIRS}:/usr/local/Homebrew/Library/Homebrew/os/mac/pkgconfig/26"

rm -rf "$STAGE" "$BLD"
cmake -G Ninja -S "$SRC" -B "$BLD" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_INSTALL_NAME_DIR="$PREFIX/lib" \
  -DCMAKE_INSTALL_RPATH="$PREFIX/lib" \
  -DCMAKE_FIND_FRAMEWORK=LAST \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DCMAKE_C_COMPILER="$CLT/usr/bin/clang" \
  -DCMAKE_CXX_COMPILER="$CLT/usr/bin/clang++" \
  -DCMAKE_OSX_SYSROOT="$SDKROOT" \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DCMAKE_SYSTEM_PROCESSOR=x86_64 \
  -DCMAKE_PREFIX_PATH="${PP#;}" \
  -DCMAKE_EXE_LINKER_FLAGS_INIT=-Wl,-headerpad_max_install_names \
  -DCMAKE_SHARED_LINKER_FLAGS_INIT=-Wl,-headerpad_max_install_names \
  -DCMAKE_MODULE_LINKER_FLAGS_INIT=-Wl,-headerpad_max_install_names \
  -DBUILD_TESTING=OFF \
  -Wno-dev "$@"
ninja -C "$BLD" -j"$(sysctl -n hw.ncpu)"
DESTDIR="$STAGE" ninja -C "$BLD" install
/Users/lin/llvm/homebrew-intel/scripts/fix-opt-paths.sh "$STAGE$PREFIX"
echo "Готово: $STAGE$PREFIX"
