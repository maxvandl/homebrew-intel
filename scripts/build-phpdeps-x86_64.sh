#!/bin/bash
# Сборка зависимостей php (и прочих мелких формул) через общие build-autotools/build-cmakeproj/build-meson
# скрипты; аргументы как у формул homebrew-core. usage: build-phpdeps-x86_64.sh name [name...]
set -uo pipefail
R=/Users/lin/llvm; S=$R/homebrew-intel/scripts
A=$S/build-autotools-x86_64.sh; C=$S/build-cmakeproj-x86_64.sh; M=$S/build-meson-x86_64.sh
CLT=/Library/Developer/CommandLineTools
get() { mkdir -p "$R/$1/src"; cd "$R/$1"; [ -f "$(basename "$2")" ] || curl -sfLO "$2"; rm -rf src; mkdir src; tar xf "$(basename "$2")" -C src --strip-components 1; cd "$R"; }
optlink() { local k; k=$(ls -d "$R/$1"/stage/usr/local/Cellar/"$1"/* 2>/dev/null | tail -1); [ -n "$k" ] || return 0
  [ -e "/usr/local/opt/$1" ] || { ln -s "$k" "/usr/local/opt/$1" && echo "/usr/local/opt/$1" >> "$R/deps/session-optlinks.txt"; }; }
K() { echo "$R/$1/stage/usr/local/Cellar/$1/$2"; }
for x in "$@"; do L=$R/$x/build.log; case $x in
m4) get m4 https://ftpmirror.gnu.org/m4/m4-1.4.21.tar.xz
  $A m4 1.4.21 $R/m4/src > $L 2>&1; echo "m4 $?"; optlink m4 ;;
pkgconf) get pkgconf https://distfiles.ariadne.space/pkgconf/pkgconf-3.0.10.tar.xz
  $A pkgconf 3.0.10 $R/pkgconf/src --disable-silent-rules \
    --with-pkg-config-dir=/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:/usr/lib/pkgconfig:/usr/local/Homebrew/Library/Homebrew/os/mac/pkgconfig/27 \
    --with-system-includedir=$CLT/SDKs/MacOSX.sdk/usr/include --with-system-libdir=/usr/lib > $L 2>&1; r=$?
  k=$(K pkgconf 3.0.10); ln -sf pkgconf $k/bin/pkg-config; ln -sf pkgconf.1 $k/share/man/man1/pkg-config.1; echo "pkgconf $r" ;;
argon2) get argon2 https://github.com/P-H-C/phc-winner-argon2/archive/refs/tags/20190702.tar.gz
  k=$(K argon2 20190702); rm -rf $R/argon2/stage
  ( cd $R/argon2/src && export SDKROOT=$CLT/SDKs/MacOSX26.sdk MACOSX_DEPLOYMENT_TARGET=26.0 PATH=$CLT/usr/bin:$PATH
    MK="CC=$CLT/usr/bin/clang -arch x86_64"
    make "$MK" PREFIX=/usr/local/Cellar/argon2/20190702 ARGON2_VERSION=20190702 LIBRARY_REL=lib LDFLAGS=-Wl,-headerpad_max_install_names &&
    make "$MK" install DESTDIR=$R/argon2/stage PREFIX=/usr/local/Cellar/argon2/20190702 ARGON2_VERSION=20190702 LIBRARY_REL=lib &&
    mkdir -p $k/share/doc/argon2 && cp argon2-specs.pdf $k/share/doc/argon2/ ) > $L 2>&1; r=$?
  $S/fix-opt-paths.sh $k >> $L 2>&1; echo "argon2 $r" ;;
libsodium) get libsodium https://download.libsodium.org/libsodium/releases/libsodium-1.0.22.tar.gz
  $A libsodium 1.0.22 $R/libsodium/src > $L 2>&1; echo "libsodium $?" ;;
json-c) get json-c https://s3.amazonaws.com/json-c_releases/releases/json-c-0.19.tar.gz
  $C json-c 0.19 $R/json-c/src -DBUILD_APPS=OFF > $L 2>&1; echo "json-c $?" ;;
libpsl) get libpsl https://github.com/rockdaboot/libpsl/releases/download/0.23.3/libpsl-0.23.3.tar.gz
  $A libpsl 0.23.3 $R/libpsl/src --disable-silent-rules --enable-builtin --enable-runtime=libicucore am_cv_func_iconv_works=yes > $L 2>&1; echo "libpsl $?" ;;
libssh2) get libssh2 https://libssh2.org/download/libssh2-1.11.1.tar.gz
  DEPS=openssl@4 $A libssh2 1.11.1 $R/libssh2/src --disable-silent-rules --disable-examples-build --with-openssl --with-libz \
    --with-libssl-prefix=/usr/local/opt/openssl@4 > $L 2>&1; echo "libssh2 $?" ;;
gmp) get gmp https://ftpmirror.gnu.org/gmp/gmp-6.3.0.tar.xz
  (cd $R/gmp/src && /opt/homebrew/bin/autoreconf -i -s) > $L 2>&1
  $A gmp 6.3.0 $R/gmp/src --enable-cxx --with-pic --build=nehalem-apple-darwin27 >> $L 2>&1; echo "gmp $?" ;;
oniguruma) get oniguruma https://github.com/kkos/oniguruma/releases/download/v6.9.10/onig-6.9.10.tar.gz
  (cd $R/oniguruma/src && /opt/homebrew/bin/autoreconf --force --install) > $L 2>&1
  $A oniguruma 6.9.10 $R/oniguruma/src >> $L 2>&1; echo "oniguruma $?" ;;
autoconf) get autoconf https://ftpmirror.gnu.org/autoconf/autoconf-2.73.tar.gz
  sed -i '' 's/libtoolize/glibtoolize/g' $R/autoconf/src/bin/autoreconf.in $R/autoconf/src/man/autoreconf.1
  PERL=/usr/bin/perl M4=/usr/local/opt/m4/bin/m4 $A autoconf 2.73 $R/autoconf/src --with-lispdir=/usr/local/Cellar/autoconf/2.73/share/emacs/site-lisp/autoconf > $L 2>&1; r=$?
  rm -f $(K autoconf 2.73)/share/info/standards.info; echo "autoconf $r" ;;
libtool) get libtool https://ftpmirror.gnu.org/libtool/libtool-2.6.2.tar.xz
  M4=/usr/local/opt/m4/bin/m4 $A libtool 2.6.2 $R/libtool/src --disable-silent-rules --enable-ltdl-install --program-prefix=g > $L 2>&1; r=$?
  k=$(K libtool 2.6.2); mkdir -p $k/libexec/gnubin $k/libexec/gnuman/man1
  for p in libtool libtoolize; do ln -sf ../../bin/g$p $k/libexec/gnubin/$p; ln -sf ../../../share/man/man1/g$p.1 $k/libexec/gnuman/man1/$p.1; done
  ln -sf ../gnuman $k/libexec/gnubin/man; echo "libtool $r" ;;
libnghttp2) get libnghttp2 https://github.com/nghttp2/nghttp2/releases/download/v1.70.0/nghttp2-1.70.0.tar.gz
  k=$(K libnghttp2 1.70.0)
  # как в core: только lib (make -C lib install)
  (cd $R/libnghttp2/src && arch -x86_64 /bin/bash -c "export PATH=$CLT/usr/bin:/opt/homebrew/bin:/usr/bin:/bin SDKROOT=$CLT/SDKs/MacOSX26.sdk MACOSX_DEPLOYMENT_TARGET=26.0 CC='$CLT/usr/bin/clang -arch x86_64' CXX='$CLT/usr/bin/clang++ -arch x86_64' LDFLAGS=-Wl,-headerpad_max_install_names PKG_CONFIG=/opt/homebrew/bin/pkgconf
    ./configure --disable-debug --disable-dependency-tracking --prefix=/usr/local/Cellar/libnghttp2/1.70.0 --libdir=/usr/local/Cellar/libnghttp2/1.70.0/lib --enable-lib-only &&
    make -j10 -C lib && rm -rf $R/libnghttp2/stage && make -C lib install DESTDIR=$R/libnghttp2/stage") > $L 2>&1; r=$?
  $S/fix-opt-paths.sh $k >> $L 2>&1; echo "libnghttp2 $r"; optlink libnghttp2 ;;
libnghttp3) get libnghttp3 https://github.com/ngtcp2/nghttp3/releases/download/v1.18.0/nghttp3-1.18.0.tar.xz
  $C libnghttp3 1.18.0 $R/libnghttp3/src -DENABLE_LIB_ONLY=1 > $L 2>&1; echo "libnghttp3 $?"; optlink libnghttp3 ;;
libngtcp2) get libngtcp2 https://github.com/ngtcp2/ngtcp2/releases/download/v1.25.0/ngtcp2-1.25.0.tar.xz
  DEPS=openssl@4 $A libngtcp2 1.25.0 $R/libngtcp2/src --disable-silent-rules > $L 2>&1; echo "libngtcp2 $?"; optlink libngtcp2 ;;
curl) get curl https://curl.se/download/curl-8.23.0.tar.bz2
  sed -i '' 's|CMD="curl "|CMD="/usr/local/opt/curl/bin/curl "|' $R/curl/src/scripts/wcurl
  P=/usr/local/Cellar/curl/8.23.0
  DEPS="openssl@4 brotli libnghttp2 libnghttp3 libngtcp2 libpsl libssh2 zstd" $A curl 8.23.0 $R/curl/src --disable-silent-rules \
    --with-ssl=/usr/local/opt/openssl@4 --without-ca-bundle --without-ca-path --with-ca-fallback --with-default-ssl-backend=openssl \
    --with-libssh2 --with-nghttp3 --with-ngtcp2 --with-libpsl --with-zsh-functions-dir=$P/share/zsh/site-functions \
    --with-fish-functions-dir=$P/share/fish/vendor_completions.d --with-apple-sectrust --with-gssapi --with-apple-idn --without-libidn2 > $L 2>&1; r=$?
  (cd $R/curl/src && arch -x86_64 /usr/bin/make -C scripts install DESTDIR=$R/curl/stage) >> $L 2>&1
  mkdir -p $(K curl 8.23.0)/libexec && cp $R/curl/src/scripts/mk-ca-bundle.pl $(K curl 8.23.0)/libexec/; echo "curl $r" ;;
dav1d) get dav1d https://code.videolan.org/videolan/dav1d/-/archive/1.5.4/dav1d-1.5.4.tar.bz2
  $M dav1d 1.5.4 $R/dav1d/src > $L 2>&1; r=$?; $S/fix-opt-paths.sh $(K dav1d 1.5.4) >> $L 2>&1; echo "dav1d $r"; optlink dav1d ;;
libavif) get libavif https://github.com/AOMediaCodec/libavif/archive/refs/tags/v1.4.2.tar.gz
  mkdir -p $R/libavif/src/ext/libargparse && curl -sfL https://github.com/kmurray/libargparse/archive/ee74d1b53bd680748af14e737378de57e2a0a954.tar.gz | tar xz -C $R/libavif/src/ext/libargparse --strip-components 1
  DEPS="aom dav1d jpeg-turbo libpng" OPTLINKS="aom jpeg-turbo" $C libavif 1.4.2 $R/libavif/src -DCMAKE_INSTALL_RPATH=@loader_path/../lib \
    -DAVIF_CODEC_AOM=SYSTEM -DAVIF_BUILD_APPS=ON -DAVIF_CODEC_DAV1D=SYSTEM -DAVIF_BUILD_EXAMPLES=OFF -DAVIF_BUILD_TESTS=OFF -DAVIF_LIBYUV=OFF > $L 2>&1; r=$?
  mkdir -p $(K libavif 1.4.2)/share/libavif && cp -R $R/libavif/src/examples $(K libavif 1.4.2)/share/libavif/; echo "libavif $r"; optlink libavif ;;
gd) get gd https://github.com/libgd/libgd/releases/download/gd-2.3.3/libgd-2.3.3.tar.xz
  OPTLINKS="jpeg-turbo" DEPS="fontconfig freetype jpeg-turbo libavif libpng libtiff webp" $A gd 2.3.3 $R/gd/src \
    --with-fontconfig=/usr/local/opt/fontconfig --with-freetype=/usr/local/opt/freetype --with-jpeg=/usr/local/opt/jpeg-turbo \
    --with-avif=/usr/local/opt/libavif --with-png=/usr/local/opt/libpng --with-tiff=/usr/local/opt/libtiff --with-webp=/usr/local/opt/webp \
    --without-x --without-xpm > $L 2>&1; echo "gd $?"; optlink gd ;;
libzip) get libzip https://libzip.org/download/libzip-1.12.1.tar.xz
  DEPS="xz zstd" $C libzip 1.12.1 $R/libzip/src -DENABLE_GNUTLS=OFF -DENABLE_MBEDTLS=OFF -DBUILD_REGRESS=OFF -DBUILD_EXAMPLES=OFF -DENABLE_OPENSSL=OFF > $L 2>&1; echo "libzip $?" ;;
tidy-html5) get tidy-html5 https://github.com/htacg/tidy-html5/archive/refs/tags/5.8.0.tar.gz
  CMAKE_POLICY_VERSION_MINIMUM=3.5 $C tidy-html5 5.8.0 $R/tidy-html5/src > $L 2>&1; echo "tidy-html5 $?" ;;
apr) get apr "https://archive.apache.org/dist/apr/apr-1.7.6.tar.bz2"
  MAKEARGS=-j1 $A apr 1.7.6 $R/apr/src > $L 2>&1; r=$?; k=$(K apr 1.7.6)
  rm -f $k/lib/*.la $k/lib/*.exp; sed -i '' "s|/usr/local/Cellar/apr/1.7.6|/usr/local/opt/apr|g" $k/bin/apr-1-config; echo "apr $r"; optlink apr ;;
apr-util) get apr-util "https://archive.apache.org/dist/apr/apr-util-1.6.5.tar.bz2"
  DEPS="openssl@4" $A apr-util 1.6.5 $R/apr-util/src --with-apr=/usr/local/opt/apr --with-crypto --with-openssl=/usr/local/opt/openssl@4 --without-pgsql > $L 2>&1; r=$?
  k=$(K apr-util 1.6.5); mkdir -p $k/libexec/lib; for f in $k/lib/*.dylib; do ln -sf ../../lib/$(basename $f) $k/libexec/lib/; done
  find $k/lib \( -name '*.la' -o -name '*.exp' \) -delete; sed -i '' "s|/usr/local/Cellar/apr-util/1.6.5|/usr/local/opt/apr-util|g" $k/bin/apu-1-config; echo "apr-util $r"; optlink apr-util ;;
net-snmp) get net-snmp https://downloads.sourceforge.net/project/net-snmp/net-snmp/5.9.5.2/net-snmp-5.9.5.2.tar.gz
  CFLAGS="-g -O2 -Wno-error=declaration-after-statement" DEPS="openssl@4" $A net-snmp 5.9.5.2 $R/net-snmp/src --disable-debugging --enable-ipv6 --with-defaults \
    --with-persistent-directory=/usr/local/var/db/net-snmp --with-logfile=/usr/local/var/log/snmpd.log \
    "--with-mib-modules=host ucd-snmp/diskio" --without-rpm --without-kmem-usage --disable-embedded-perl --without-perl-modules \
    --with-openssl=/usr/local/opt/openssl@4 > $L 2>&1; echo "net-snmp $?"; optlink net-snmp ;;
*) echo "unknown $x" ;;
esac; done
