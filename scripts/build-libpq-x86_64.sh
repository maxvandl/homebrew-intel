#!/bin/bash
# Нативная кросс-сборка libpq (клиентская часть PostgreSQL) под x86_64 macOS на Apple Silicon,
# как формула homebrew-core: --with-gssapi (krb5) --with-libcurl --with-openssl (openssl@4),
# libdir/includedir через opt, установка только src/bin, include, interfaces, common, port, doc.
# configure под Rosetta (arch -x86_64), компилятор — arm64 clang из CLT с "-arch x86_64".
set -euo pipefail
[ "$(uname -m)" = x86_64 ] || exec arch -x86_64 /bin/bash "$0" "$@"
VER=18.6
ROOT=/Users/lin/llvm
W=$ROOT/libpq
SRC=$W/src
PREFIX=/usr/local/Cellar/libpq/$VER
STAGE=$W/stage
CLT=/Library/Developer/CommandLineTools; export DEVELOPER_DIR=$CLT
export SDKROOT=$CLT/SDKs/MacOSX26.sdk MACOSX_DEPLOYMENT_TARGET=26.0
export PATH=$ROOT/deps/armbin:$CLT/usr/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
export CC="$CLT/usr/bin/clang -arch x86_64" CXX="$CLT/usr/bin/clang++ -arch x86_64"
export PKG_CONFIG=/opt/homebrew/bin/pkgconf
export XML_CATALOG_FILES=/opt/homebrew/etc/xml/catalog   # docbook/docbook-xsl из arm64-brew (для doc)
DEPS="readline icu4c@79 krb5 openssl@4"
CPPF=""; LDF=""; PC=""
for d in $DEPS; do CPPF="$CPPF -I/usr/local/opt/$d/include"; LDF="$LDF -L/usr/local/opt/$d/lib"; PC="$PC:/usr/local/opt/$d/lib/pkgconfig"; done
export CPPFLAGS="${CPPF# }" LDFLAGS="${LDF# } -Wl,-headerpad_max_install_names"
export PKG_CONFIG_LIBDIR="${PC#:}:/usr/local/Homebrew/Library/Homebrew/os/mac/pkgconfig/26"

mkdir -p "$W"; cd "$W"
[ -f "postgresql-$VER.tar.bz2" ] || curl -fLO "https://ftp.postgresql.org/pub/source/v$VER/postgresql-$VER.tar.bz2"
rm -rf "$SRC" "$STAGE"; mkdir -p "$SRC"; tar xf "postgresql-$VER.tar.bz2" -C "$SRC" --strip-components 1
cd "$SRC"
./configure --disable-debug --prefix="$PREFIX" --with-gssapi --with-libcurl --with-openssl \
  --libdir=/usr/local/opt/libpq/lib --includedir=/usr/local/opt/libpq/include
DIRS="libdir=$PREFIX/lib includedir=$PREFIX/include pkgincludedir=$PREFIX/include/postgresql \
includedir_server=$PREFIX/include/postgresql/server includedir_internal=$PREFIX/include/postgresql/internal"
make -j"$(sysctl -n hw.ncpu)"
for d in src/bin src/include src/interfaces src/common src/port doc; do
  make -C "$d" install DESTDIR="$STAGE" $DIRS
done
"$ROOT/homebrew-intel/scripts/fix-opt-paths.sh" "$STAGE$PREFIX"
echo "Готово: $STAGE$PREFIX"
