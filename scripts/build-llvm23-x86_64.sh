#!/bin/bash
# Нативная кросс-сборка LLVM 23.1.1 под x86_64 macOS на Apple Silicon (M2).
# Компилятор — arm64 (Apple clang), результат — x86_64. Rosetta нужна только
# чтобы cmake мог запускать тестовые x86_64-бинарники на этапе configure.
set -euo pipefail

VER=23.1.1
ROOT=/Users/lin/llvm
SRC=$ROOT/llvm-project-$VER.src
BUILD=$ROOT/build-x86_64-23
PREFIX=/usr/local/Cellar/llvm@23/$VER  # как у Homebrew (std_cmake_args); реальная установка идёт в STAGE
STAGE=$ROOT/stage-23
NATIVE=/opt/homebrew/opt/llvm/bin      # arm64 llvm 23.1.1: отсюда берём tblgen'ы (та же версия!)
CLT=$(xcode-select -p)                 # runtimes собирает свежий x86_64 clang под Rosetta; /usr/bin/ld (xcrun-shim)
                                       # там не работает, поэтому указываем настоящий ld через -B

command -v ninja >/dev/null || brew install ninja      # arm64 brew

# tblgen'ы обязаны совпадать по версии с исходниками
"$NATIVE/llvm-tblgen" --version | grep -q "$VER" || { echo "ERROR: $NATIVE/llvm-tblgen != $VER"; exit 1; }

cd "$ROOT"
if [ ! -d "$SRC" ]; then
  [ -f "llvm-project-$VER.src.tar.xz" ] || \
    curl -LO "https://github.com/llvm/llvm-project/releases/download/llvmorg-$VER/llvm-project-$VER.src.tar.xz"
  tar xf "llvm-project-$VER.src.tar.xz"
fi

cmake -G Ninja -S "$SRC/llvm" -B "$BUILD" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_C_COMPILER="$(xcrun -f clang)" \
  -DCMAKE_CXX_COMPILER="$(xcrun -f clang++)" \
  -DCMAKE_OSX_SYSROOT="$(xcrun --show-sdk-path)" \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DLLVM_HOST_TRIPLE=x86_64-apple-darwin \
  -DLLVM_DEFAULT_TARGET_TRIPLE=x86_64-apple-darwin \
  -DLLVM_NATIVE_TOOL_DIR="$NATIVE" \
  -DLLVM_TARGETS_TO_BUILD="X86;AArch64" \
  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;mlir;polly" \
  -DLLVM_ENABLE_RUNTIMES="compiler-rt;libcxx;libcxxabi;libunwind" \
  -DRUNTIMES_CMAKE_ARGS="-DCMAKE_OSX_ARCHITECTURES=x86_64;-DCMAKE_C_FLAGS=-B$CLT/usr/bin;-DCMAKE_CXX_FLAGS=-B$CLT/usr/bin;-DCMAKE_ASM_FLAGS=-B$CLT/usr/bin;-DDARWIN_osx_ARCHS=x86_64" \
  -DCOMPILER_RT_ENABLE_IOS=OFF -DCOMPILER_RT_ENABLE_WATCHOS=OFF \
  -DCOMPILER_RT_ENABLE_TVOS=OFF -DCOMPILER_RT_ENABLE_XROS=OFF \
  -DLLVM_LINK_LLVM_DYLIB=ON -DCLANG_LINK_CLANG_DYLIB=ON \
  -DLLVM_ENABLE_ZSTD=ON -Dzstd_ROOT=/usr/local/opt/zstd \
  -DLLVM_ENABLE_LIBXML2=OFF -DLLVM_ENABLE_LIBEDIT=OFF -DLLVM_ENABLE_TERMINFO=OFF \
  -DLLVM_INCLUDE_TESTS=OFF -DLLVM_INCLUDE_BENCHMARKS=OFF -DLLVM_INCLUDE_EXAMPLES=OFF \
  -DCLANG_CONFIG_FILE_SYSTEM_DIR=../etc/clang -DCLANG_CONFIG_FILE_USER_DIR=~/.config/clang \
  -DLLVM_PARALLEL_LINK_JOBS=2

ninja -C "$BUILD" -j10
rm -rf "$STAGE"
DESTDIR="$STAGE" ninja -C "$BUILD" install

echo "Готово: $STAGE$PREFIX"
file "$STAGE$PREFIX/bin/clang"
