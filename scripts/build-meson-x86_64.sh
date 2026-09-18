#!/bin/bash
# Универсальная нативная кросс-сборка meson-проекта под x86_64 macOS на Apple Silicon.
# usage: [DEPS="lzo icu4c@76 ..."] build-meson-x86_64.sh NAME VERSION SRCDIR [meson args...]
#   DEPS — формулы Intel-brew, чьи include/lib добавить в CFLAGS/LDFLAGS (аналог superenv Homebrew)
# Результат: <ROOT>/<NAME>/stage/usr/local/Cellar/<NAME>/<VERSION> (готовый keg для tar).
# Зависимости берутся из Intel-brew (/usr/local/opt/*) и из уже собранных здесь
# keg'ов через переписанные .pc в <ROOT>/deps/pkgconfig (они имеют приоритет).
set -euo pipefail
NAME=$1; VER=$2; SRC=$3; shift 3
ROOT=/Users/lin/llvm
PREFIX=/usr/local/Cellar/$NAME/$VER
STAGE=$ROOT/$NAME/stage
CLT=$(xcode-select -p)

export SDKROOT=$CLT/SDKs/MacOSX26.sdk     # не SDK 27 из CLT 27: слабые символы (pipe2 и т.п.) ломают рантайм на macOS 26
export PATH=/opt/homebrew/opt/bison/bin:$CLT/usr/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
export CC="$CLT/usr/bin/clang -arch x86_64" CXX="$CLT/usr/bin/clang++ -arch x86_64"
export OBJC="$CC" OBJCXX="$CXX"
export CFLAGS="-I/usr/local/opt/gettext/include"
LDF="-L/usr/local/opt/gettext/lib"
for d in ${DEPS:-}; do CFLAGS="$CFLAGS -I/usr/local/opt/$d/include"; LDF="$LDF -L/usr/local/opt/$d/lib"; done
export CXXFLAGS="$CFLAGS" OBJCFLAGS="$CFLAGS" OBJCXXFLAGS="$CFLAGS" CPPFLAGS="$CFLAGS" LDFLAGS="$LDF"
export PKG_CONFIG=/opt/homebrew/bin/pkgconf
PCDIRS=$ROOT/deps/pkgconfig
for d in /usr/local/opt/*/lib/pkgconfig /usr/local/opt/*/share/pkgconfig; do [ -d "$d" ] && PCDIRS=$PCDIRS:$d; done
export PKG_CONFIG_LIBDIR=$PCDIRS:/usr/local/Homebrew/Library/Homebrew/os/mac/pkgconfig/26
export MACOSX_DEPLOYMENT_TARGET=26.0
MESON="$ROOT/glib/venv/bin/meson"      # x86_64-only python => сам идёт под Rosetta, build==host==x86_64 (без arch: он режет DYLD_*)
# Уже собранные здесь keg'и ещё не установлены в /usr/local/Cellar: чтобы тестовые бинарники и
# дамперы introspection могли их загрузить, подсовываем stage-библиотеки по имени через DYLD_LIBRARY_PATH,
# gir-файлы через XDG_DATA_DIRS, g-ir-scanner из staging glib.
DYLD=""; XDG=""
for d in "$ROOT"/*/stage/usr/local/Cellar/*/*; do [ -d "$d/lib" ] && DYLD="$DYLD:$d/lib"; [ -d "$d/share" ] && XDG="$XDG:$d/share"; done
export DYLD_LIBRARY_PATH="${DYLD#:}" XDG_DATA_DIRS="${XDG#:}:/usr/local/share:/usr/share"
export PATH=$ROOT/glib/staging/bin:$PATH
export GI_TYPELIB_PATH=$ROOT/glib/stage/usr/local/Cellar/glib/2.90.0/lib/girepository-1.0

rm -rf "$STAGE" "$SRC/build"
$MESON setup "$SRC/build" "$SRC" --prefix="$PREFIX" --buildtype=release --libdir=lib --wrap-mode=nofallback "$@"
$MESON compile -C "$SRC/build"
DESTDIR="$STAGE" $MESON install -C "$SRC/build"

mkdir -p "$ROOT/deps/pkgconfig"
for pc in "$STAGE$PREFIX"/lib/pkgconfig/*.pc; do
  [ -f "$pc" ] && sed "s|^prefix=$PREFIX|prefix=$STAGE$PREFIX|" "$pc" > "$ROOT/deps/pkgconfig/$(basename "$pc")"
done
echo "Готово: $STAGE$PREFIX"
