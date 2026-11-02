#!/bin/bash
# Кросс-сборка Rust-формул под x86_64 macOS на Apple Silicon: cargo install --target x86_64-apple-darwin
# (как std_cargo_args: --locked --root <keg> --path .), C-зависимости (openssl@4, xz) из /usr/local/opt.
# usage: build-rust-x86_64.sh name [name...]
set -uo pipefail
R=/Users/lin/llvm
CLT=/Library/Developer/CommandLineTools
export SDKROOT=$CLT/SDKs/MacOSX26.sdk MACOSX_DEPLOYMENT_TARGET=26.0
export PATH=/opt/homebrew/opt/rustup/bin:$CLT/usr/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
export CC_x86_64_apple_darwin="$CLT/usr/bin/clang" CXX_x86_64_apple_darwin="$CLT/usr/bin/clang++"
export CARGO_TARGET_X86_64_APPLE_DARWIN_LINKER="$CLT/usr/bin/clang"
export CARGO_TARGET_X86_64_APPLE_DARWIN_RUSTFLAGS="-C link-arg=-Wl,-headerpad_max_install_names"
export PKG_CONFIG=/opt/homebrew/bin/pkgconf PKG_CONFIG_ALLOW_CROSS=1
T=x86_64-apple-darwin
get() { mkdir -p "$R/$1"; cd "$R/$1"; [ -f "$(basename "$2")" ] || curl -sfLO "$2"; rm -rf src; mkdir src; tar xf "$(basename "$2")" -C src --strip-components 1; cd src; }
K() { echo "$R/$1/stage/usr/local/Cellar/$1/$2"; }
for x in "$@"; do L=$R/$x/build.log; mkdir -p $R/$x; (set -e; case $x in
maturin) V=1.16.0; get maturin https://github.com/PyO3/maturin/archive/refs/tags/v$V.tar.gz; k=$(K maturin $V); rm -rf $R/maturin/stage
  export PKG_CONFIG_LIBDIR=/usr/local/opt/xz/lib/pkgconfig
  cargo install --locked --target $T --root $k --path .
  rm -f $k/.crates.toml $k/.crates2.json
  mkdir -p $k/etc/bash_completion.d $k/share/zsh/site-functions $k/share/fish/vendor_completions.d
  $k/bin/maturin completions bash > $k/etc/bash_completion.d/maturin
  $k/bin/maturin completions zsh > $k/share/zsh/site-functions/_maturin
  $k/bin/maturin completions fish > $k/share/fish/vendor_completions.d/maturin.fish
  # python-пакет maturin: в site-packages новейшего python, для остальных — симлинки (как в core)
  sp=$k/lib/python3.15/site-packages; mkdir -p $sp; cp -R maturin $sp/
  for v in 3.10 3.11 3.12 3.13 3.14; do mkdir -p $k/lib/python$v/site-packages/maturin
    for f in $sp/maturin/*; do ln -sf ../../../python3.15/site-packages/maturin/$(basename $f) $k/lib/python$v/site-packages/maturin/; done; done ;;
trunk) V=0.22.1; get trunk https://github.com/trunk-rs/trunk/archive/refs/tags/v$V.tar.gz; k=$(K trunk $V); rm -rf $R/trunk/stage
  export OPENSSL_DIR=/usr/local/opt/openssl@4
  cargo install --locked --target $T --root $k --path . --no-default-features --features native-tls
  rm -f $k/.crates.toml $k/.crates2.json ;;
*) echo "unknown $x"; exit 1 ;;
esac) > $L 2>&1; r=$?
  k=$(ls -d $R/$x/stage/usr/local/Cellar/$x/* 2>/dev/null | tail -1); [ -n "$k" ] && $R/homebrew-intel/scripts/fix-opt-paths.sh $k >> $L 2>&1
  echo "$x $r"; done
