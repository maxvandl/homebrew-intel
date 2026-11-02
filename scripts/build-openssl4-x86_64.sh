#!/bin/bash
# Нативная кросс-сборка openssl@4 под x86_64 macOS на Apple Silicon.
# Конфигурация повторяет формулу homebrew-core (darwin64-x86_64-cc enable-ec_nistp_64_gcc_128,
# openssldir в etc/openssl@4). Компилятор — arm64 clang из CLT с "-arch x86_64"; SDK macOS 26.
set -euo pipefail
VER=4.1.0
ROOT=/Users/lin/llvm/openssl
SRC=$ROOT/openssl-$VER
PREFIX=/usr/local/Cellar/openssl@4/$VER
STAGE=$ROOT/stage4
CLT=/Library/Developer/CommandLineTools

export SDKROOT=$CLT/SDKs/MacOSX26.sdk
export PATH=$CLT/usr/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
export CC="$CLT/usr/bin/clang -arch x86_64"
export MACOSX_DEPLOYMENT_TARGET=26.0

cd "$ROOT"
[ -d "$SRC" ] || { curl -LO "https://github.com/openssl/openssl/releases/download/openssl-$VER/openssl-$VER.tar.gz"; tar xzf "openssl-$VER.tar.gz"; }

rm -rf "$STAGE"; cd "$SRC"; make distclean >/dev/null 2>&1 || true
perl ./Configure darwin64-x86_64-cc enable-ec_nistp_64_gcc_128 --prefix="$PREFIX" \
  --openssldir=/usr/local/etc/openssl@4 --libdir=lib
make -j"$(sysctl -n hw.ncpu)"
make install_sw install_ssldirs DESTDIR="$STAGE"
# openssl.cnf кладём в keg как .dist, в etc его ставит формула; cert.pem — через ca-certificates
cp "$STAGE/usr/local/etc/openssl@4/openssl.cnf.dist" "$STAGE$PREFIX/openssl.cnf.dist"
rm -rf "$STAGE/usr/local/etc"
echo "Готово: $STAGE$PREFIX"
file "$STAGE$PREFIX/lib/libssl.4.dylib" "$STAGE$PREFIX/bin/openssl"
