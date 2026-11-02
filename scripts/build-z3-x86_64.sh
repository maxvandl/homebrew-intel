#!/bin/bash
# Сборка z3 (как в homebrew-core: LTO, python-биндинги в lib/python3.15/site-packages, qprofdiff, examples)
# через общий scripts/build-cmakeproj-x86_64.sh.
set -euo pipefail
R=/Users/lin/llvm; mkdir -p $R/z3/src; cd $R/z3
[ -f z3-5.3.3.tar.gz ] || curl -sfLO https://github.com/Z3Prover/z3/archive/refs/tags/z3-5.3.3.tar.gz
rm -rf src/*; tar xzf z3-5.3.3.tar.gz -C src --strip-components 1
$R/homebrew-intel/scripts/build-cmakeproj-x86_64.sh z3 5.3.3 $R/z3/src \
  -DZ3_LINK_TIME_OPTIMIZATION=ON -DZ3_INCLUDE_GIT_DESCRIBE=OFF -DZ3_INCLUDE_GIT_HASH=OFF \
  -DZ3_INSTALL_PYTHON_BINDINGS=ON -DZ3_BUILD_EXECUTABLE=ON -DZ3_BUILD_TEST_EXECUTABLES=OFF \
  -DZ3_BUILD_PYTHON_BINDINGS=ON -DZ3_BUILD_DOTNET_BINDINGS=OFF -DZ3_BUILD_JAVA_BINDINGS=OFF \
  -DZ3_USE_LIB_GMP=OFF -DPYTHON_EXECUTABLE=/opt/homebrew/bin/python3.15 \
  -DCMAKE_INSTALL_PYTHON_PKG_DIR=lib/python3.15/site-packages
K=$R/z3/stage/usr/local/Cellar/z3/5.3.3
CLT=/Library/Developer/CommandLineTools
make -C src/contrib/qprofdiff CXX="$CLT/usr/bin/clang++ -arch x86_64 -isysroot $CLT/SDKs/MacOSX26.sdk"
install -m 755 src/contrib/qprofdiff/qprofdiff $K/bin/
mkdir -p $K/share/z3; cp -R src/examples $K/share/z3/
