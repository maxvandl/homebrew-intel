#!/bin/bash
# Нативная кросс-сборка glib (с gobject-introspection) под x86_64 macOS на Apple Silicon.
# Повторяет трёхстадийную схему формулы homebrew-core:
#   1) glib без introspection -> STAGING
#   2) gobject-introspection против STAGING-glib -> STAGING
#   3) glib с introspection -> PREFIX (через DESTDIR в STAGE)
# meson запускается x86_64-питоном из Intel-brew под Rosetta, поэтому build==host==x86_64.
# Компилятор — настоящий arm64 clang из CLT с "-arch x86_64"; CLT/usr/bin первым в PATH,
# т.к. обёртки /usr/bin/{ld,ar,install_name_tool,...} под x86_64 не работают (CLT 27 без x86_64).
set -euo pipefail
VER=2.90.0; GI_VER=1.86.0
ROOT=/Users/lin/llvm/glib
SRC=$ROOT/glib-$VER
GISRC=$ROOT/gobject-introspection-$GI_VER
PREFIX=/usr/local/Cellar/glib/$VER
STAGE=$ROOT/stage
STAGING=$ROOT/staging
CLT=$(xcode-select -p)
PY=/usr/local/opt/python@3.13/bin/python3.13          # x86_64 python из Intel-brew (шебанг g-ir-scanner, _giscanner.so)

export SDKROOT=$CLT/SDKs/MacOSX26.sdk   # НЕ MacOSX.sdk: в CLT 27 это SDK 27 с pipe2 и т.п., которых нет на macOS 26
export PATH=/opt/homebrew/opt/bison/bin:$CLT/usr/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
export CC="$CLT/usr/bin/clang -arch x86_64" CXX="$CLT/usr/bin/clang++ -arch x86_64"
export OBJC="$CC"
export CFLAGS="-I/usr/local/opt/gettext/include"
export CXXFLAGS="$CFLAGS" OBJCFLAGS="$CFLAGS" CPPFLAGS="$CFLAGS" LDFLAGS="-L/usr/local/opt/gettext/lib"
export PKG_CONFIG=/opt/homebrew/bin/pkgconf
export PKG_CONFIG_LIBDIR=/usr/local/opt/pcre2/lib/pkgconfig:/usr/local/Homebrew/Library/Homebrew/os/mac/pkgconfig/26
export MACOSX_DEPLOYMENT_TARGET=26.0
MESON="arch -x86_64 $ROOT/venv/bin/meson"
STD="--buildtype=release --libdir=lib --wrap-mode=nofallback"
ARGS="--localstatedir=/usr/local/var -Dgio_module_dir=/usr/local/lib/gio/modules -Dbsymbolic_functions=false -Ddtrace=disabled -Druntime_dir=/usr/local/var/run -Dtests=false"

rm -rf "$STAGING" "$STAGE" "$SRC/build_staging" "$SRC/build" "$GISRC/build"

echo "### stage 1: glib -> staging"
$MESON setup "$SRC/build_staging" "$SRC" --prefix="$STAGING" $STD $ARGS -Dintrospection=disabled
$MESON compile -C "$SRC/build_staging"
$MESON install -C "$SRC/build_staging"

export PKG_CONFIG_LIBDIR=$STAGING/lib/pkgconfig:$PKG_CONFIG_LIBDIR
export PATH=$STAGING/bin:$PATH

echo "### stage 2: gobject-introspection -> staging"
$MESON setup "$GISRC/build" "$GISRC" --prefix="$STAGING" $STD -Dcairo=disabled -Ddoctool=disabled -Dtests=false -Dpython="$PY"
$MESON compile -C "$GISRC/build"
$MESON install -C "$GISRC/build"

echo "### stage 3: glib + introspection -> $PREFIX"
$MESON setup "$SRC/build" "$SRC" --prefix="$PREFIX" $STD $ARGS --default-library=both -Dintrospection=enabled
$MESON compile -C "$SRC/build"
DESTDIR="$STAGE" $MESON install -C "$SRC/build"

echo "Готово: $STAGE$PREFIX"
file "$STAGE$PREFIX/lib/libglib-2.0.0.dylib"
