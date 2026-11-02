#!/bin/bash
# Нативная кросс-сборка php под x86_64 macOS на Apple Silicon, как формула homebrew-core:
# те же inreplace и аргументы configure (apxs2 от httpd, внешние gd/pcre, ldap+sasl, pdo-dblib/odbc/pgsql,
# snmp, sodium, tidy, argon2, intl на icu4c@79, dtrace). configure под Rosetta, компилятор — arm64 clang
# из CLT с "-arch x86_64". Зависимости из этого tap, ещё не установленные в Intel-brew, на время сборки
# подставляются в /usr/local/opt как ссылки на staged keg'и. Конфиги (etc/php/X.Y) кладутся в keg как etc_dist.
set -euo pipefail
[ "$(uname -m)" = x86_64 ] || exec arch -x86_64 /bin/bash "$0" "$@"
VER=8.5.12
MM=${VER%.*}
ROOT=/Users/lin/llvm
W=$ROOT/php
SRC=$W/src
P=/usr/local/Cellar/php/$VER
CFG=/usr/local/etc/php/$MM
STAGE=$W/stage
CLT=/Library/Developer/CommandLineTools; export DEVELOPER_DIR=$CLT
SDK=$CLT/SDKs/MacOSX26.sdk
export SDKROOT=$SDK MACOSX_DEPLOYMENT_TARGET=26.0
export PATH=$ROOT/deps/armbin:$CLT/usr/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
export CC="$CLT/usr/bin/clang -arch x86_64" CXX="$CLT/usr/bin/clang++ -arch x86_64"
export PKG_CONFIG=/opt/homebrew/bin/pkgconf
# dtrace (--enable-dtrace) зовёт cpp через xcrun, а libxcrun в CLT 27 только arm64: запускаем его как arm64
mkdir -p "$ROOT/deps/armbin"; printf '#!/bin/sh\nexec arch -arm64 /usr/sbin/dtrace "$@"\n' > "$ROOT/deps/armbin/dtrace"; chmod +x "$ROOT/deps/armbin/dtrace"
DEPS="apr apr-util argon2 curl freetds gd gmp icu4c@79 libpq libsodium libzip net-snmp oniguruma openldap openssl@4 pcre2 sqlite tidy-html5 unixodbc gettext"

TMPLINKS=""
for f in $DEPS httpd; do
  [ -e "/usr/local/opt/$f" ] && continue
  k=$(ls -d "$ROOT"/*/stage*/usr/local/Cellar/"$f"/* 2>/dev/null | tail -1)
  [ -n "$k" ] || { echo "ERROR: нет $f ни в /usr/local/opt, ни в stage"; exit 1; }
  ln -s "$k" "/usr/local/opt/$f"; TMPLINKS="$TMPLINKS /usr/local/opt/$f"
done
trap 'for l in $TMPLINKS; do rm -f "$l"; done' EXIT

CPPF=""; LDF=""; PC=""
for d in $DEPS; do
  CPPF="$CPPF -I/usr/local/opt/$d/include"; LDF="$LDF -L/usr/local/opt/$d/lib"
done
for d in $DEPS; do for p in lib/pkgconfig share/pkgconfig; do [ -d "/usr/local/opt/$d/$p" ] && PC="$PC:/usr/local/opt/$d/$p"; done; done
# затем все opt-формулы (прямые зависимости выше по приоритету, иначе icu4c@76 перебьёт icu4c@79):
# .pc зависимостей тянут транзитивные (libcurl -> brotli, nghttp2, libssh2, ...)
for p in /usr/local/opt/*/lib/pkgconfig /usr/local/opt/*/share/pkgconfig; do [ -d "$p" ] && PC="$PC:$p"; done
export CPPFLAGS="${CPPF# }" LDFLAGS="${LDF# } -Wl,-headerpad_max_install_names"
export PKG_CONFIG_LIBDIR="${PC#:}:/usr/local/Homebrew/Library/Homebrew/os/mac/pkgconfig/26"
export SASL_CFLAGS="-I$SDK/usr/include/sasl" SASL_LIBS="-lsasl2" PHP_BUILD_PROVIDER=maxvandl

mkdir -p "$W"; cd "$W"
[ -f "php-$VER.tar.xz" ] || curl -fLO "https://www.php.net/distributions/php-$VER.tar.xz"
rm -rf "$SRC" "$STAGE"; mkdir -p "$SRC"; tar xf "php-$VER.tar.xz" -C "$SRC" --strip-components 1
cd "$SRC"
/usr/bin/perl -0pi -e "s{\\\$APXS_HTTPD -V 2>/dev/null \\| grep 'threaded:.\\*yes' >/dev/null 2>&1}{false}g" configure
/usr/bin/perl -0pi -e "s{APXS_LIBEXECDIR='\\\$\\(INSTALL_ROOT\\)'\\\$\\(\\\$APXS -q LIBEXECDIR\\)}{APXS_LIBEXECDIR='\\\$(INSTALL_ROOT)$P/lib/httpd/modules'}g" configure
/usr/bin/perl -0pi -e "s{-z \\\$\\(\\\$APXS -q SYSCONFDIR\\)}{-z ''}g" configure
grep -q "APXS_LIBEXECDIR='\$(INSTALL_ROOT)$P/lib/httpd/modules'" configure
sed -i '' 's/You need to recompile PHP\./Homebrew PHP does not support a thread-safe php binary. To use the PHP apache sapi please change your httpd config to use the prefork MPM/' sapi/apache2handler/sapi_apache2.c
sed -i '' 's/;daemonize = yes/daemonize = no/' sapi/fpm/php-fpm.conf.in

H="=$SDK/usr"
./configure --prefix=$P --localstatedir=/usr/local/var --sysconfdir=$CFG --with-config-file-path=$CFG \
  --with-config-file-scan-dir=$CFG/conf.d --with-pear=$P/share/php/pear \
  --enable-bcmath --enable-calendar --enable-dba --enable-exif --enable-ftp --enable-fpm --enable-gd --enable-intl \
  --enable-mbregex --enable-mbstring --enable-mysqlnd --enable-pcntl --enable-phpdbg --enable-phpdbg-readline \
  --enable-shmop --enable-soap --enable-sockets --enable-sysvmsg --enable-sysvsem --enable-sysvshm \
  --with-apxs2=/usr/local/opt/httpd/bin/apxs --with-bz2$H --with-curl --with-external-gd --with-external-pcre --with-ffi \
  --with-fpm-user=_www --with-fpm-group=_www --with-gettext=/usr/local/opt/gettext --with-gmp=/usr/local/opt/gmp \
  --with-iconv$H --with-layout=GNU --with-ldap-sasl --with-ldap=/usr/local/opt/openldap --with-libedit --with-libxml \
  --with-mhash$H --with-mysql-sock=/tmp/mysql.sock --with-mysqli=mysqlnd --with-ndbm$H --with-openssl \
  --with-password-argon2=/usr/local/opt/argon2 --with-pdo-dblib=/usr/local/opt/freetds --with-pdo-mysql=mysqlnd \
  --with-pdo-odbc=unixODBC,/usr/local/opt/unixodbc --with-pdo-pgsql=/usr/local/opt/libpq --with-pdo-sqlite \
  --with-pgsql=/usr/local/opt/libpq --with-pic --with-snmp=/usr/local/opt/net-snmp --with-sodium --with-sqlite3 \
  --with-tidy=/usr/local/opt/tidy-html5 --with-unixODBC --with-xsl --with-zip --with-zlib --enable-dtrace
make -j"$(sysctl -n hw.ncpu)"
make install INSTALL_ROOT="$STAGE"

K=$STAGE$P
EXT=$(basename "$(sed -n -E "s/^extension_dir=[\"']([^\"']*)[\"']/\1/p" "$K/bin/php-config")")
sed -i '' "s|$P/lib/php|$P/pecl|g" "$K/bin/php-config"
for f in php.ini-development php.ini-production; do
  sed -i '' -E -e "s|; ?extension_dir = \"\./\"|extension_dir = \"/usr/local/lib/php/pecl/$EXT\"|" \
    -e 's|; ?openssl\.cafile=|openssl.cafile = "/usr/local/etc/openssl@4/cert.pem"|' \
    -e 's|; ?openssl\.capath=|openssl.capath = "/usr/local/etc/openssl@4/certs"|' "$f"
done
E=$K/etc_dist; mkdir -p "$E/php-fpm.d"
cp php.ini-development "$E/php.ini"; cp php.ini-production "$E/php.ini-production"
cp sapi/fpm/php-fpm.conf "$E/php-fpm.conf"; cp sapi/fpm/www.conf "$E/php-fpm.d/www.conf"
[ -d "$STAGE$CFG" ] && cp -R "$STAGE$CFG"/. "$E/" 2>/dev/null || true
rm -f "$E/pear.conf"
"$ROOT/homebrew-intel/scripts/fix-opt-paths.sh" "$K"
echo "Готово: $K"
