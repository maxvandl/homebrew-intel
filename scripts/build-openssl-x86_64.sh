#!/bin/bash
# Нативная кросс-сборка openssl@3 под x86_64 macOS на Apple Silicon.
# Конфигурация повторяет формулу homebrew-core (no-ssl3, no-zlib, darwin64-x86_64-cc).
# Компилятор — arm64 clang из CLT с "-arch x86_64"; SDK macOS 26 (как в glib).
set -euo pipefail
VER=3.6.5
ROOT=/Users/lin/llvm/openssl
SRC=$ROOT/openssl-$VER
PREFIX=/usr/local/Cellar/openssl@3/$VER
STAGE=$ROOT/stage
CLT=/Library/Developer/CommandLineTools

export SDKROOT=$CLT/SDKs/MacOSX26.sdk
export PATH=$CLT/usr/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
export CC="$CLT/usr/bin/clang -arch x86_64"
export MACOSX_DEPLOYMENT_TARGET=26.0

rm -rf "$STAGE"; cd "$SRC"; make distclean >/dev/null 2>&1 || true
perl ./Configure darwin64-x86_64-cc --prefix="$PREFIX" --openssldir=/usr/local/etc/openssl@3 \
  --libdir=lib no-ssl3 no-ssl3-method no-zlib
make -j"$(sysctl -n hw.ncpu)"
make install_sw install_ssldirs DESTDIR="$STAGE"
# cert.pem/certs ставит формула через ca-certificates
rm -rf "$STAGE/usr/local/etc"
echo "Готово: $STAGE$PREFIX"
file "$STAGE$PREFIX/lib/libssl.3.dylib" "$STAGE$PREFIX/bin/openssl"
