#!/bin/bash
# Нативная кросс-сборка httpd под x86_64 macOS на Apple Silicon, как формула homebrew-core
# (Slackware-FHS layout, все MPM/модули shared, prefork, порты 8080/8443, apr/apr-util/brotli/nghttp2/
# openssl@4/pcre2 через opt, Cellar-пути в apxs/apachectl/build-файлах заменены на opt).
# Нужен php (apxs, libphp.so). Конфиги из etc/httpd кладутся в keg как etc_dist.
set -euo pipefail
VER=2.4.69
ROOT=/Users/lin/llvm
W=$ROOT/httpd
SRC=$W/src
P=/usr/local/Cellar/httpd/$VER
OPT=/usr/local/opt/httpd
STAGE=$W/stage
SDK=/Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk

mkdir -p "$W"; cd "$W"
[ -f "httpd-$VER.tar.bz2" ] || curl -fLO "https://archive.apache.org/dist/httpd/httpd-$VER.tar.bz2"
rm -rf "$SRC"; mkdir -p "$SRC"; tar xf "httpd-$VER.tar.bz2" -C "$SRC" --strip-components 1
cd "$SRC"
sed -i '' "s|#@@ServerRoot@@#\$(prefix)#|#@@ServerRoot@@#$OPT#|" Makefile.in
sed -i '' "s|@exp_iconsdir@|$OPT/share/httpd/icons|" docs/conf/extra/httpd-autoindex.conf.in
sed -i '' "s|@exp_errordir@|$OPT/share/httpd/error|" docs/conf/extra/httpd-multilang-errordoc.conf.in
sed -i '' -E 's/(User|Group) daemon/\1 _www/' docs/conf/httpd.conf.in
sed -i '' -e 's|${datadir}/htdocs|${datadir}|' -e "s|\${htdocsdir}/manual|$P/share/httpd/manual|" \
  -e "s|\${datadir}/error|$P/share/httpd/error|" -e "s|\${datadir}/icons|$P/share/httpd/icons|" config.layout

DEPS="apr apr-util brotli libnghttp2 openssl@4 pcre2" "$ROOT/homebrew-intel/scripts/build-autotools-x86_64.sh" httpd "$VER" "$SRC" \
  --enable-layout=Slackware-FHS --sbindir=$P/bin --mandir=$P/share/man --sysconfdir=/usr/local/etc/httpd \
  --datadir=/usr/local/var/www --localstatedir=/usr/local/var --enable-mpms-shared=all --enable-mods-shared=all \
  --enable-authnz-fcgi --enable-cgi --enable-pie --enable-suexec --with-suexec-bin=$OPT/bin/suexec \
  --with-suexec-caller=_www --with-port=8080 --with-sslport=8443 --with-apr=/usr/local/opt/apr \
  --with-apr-util=/usr/local/opt/apr-util --with-brotli=/usr/local/opt/brotli --with-libxml2=$SDK/usr \
  --with-mpm=prefork --with-nghttp2=/usr/local/opt/libnghttp2 --with-ssl=/usr/local/opt/openssl@4 \
  --with-pcre=/usr/local/opt/pcre2/bin/pcre2-config --with-z=$SDK/usr --disable-lua --disable-luajit

K=$STAGE$P
install -m 755 support/suexec "$K/bin/"
rm -f "$K/bin/envvars" "$K/bin/envvars-std"
for f in "$K/include/httpd/ap_config_layout.h" "$K/lib/httpd/build/config_vars.mk"; do
  sed -i '' "s|$P/lib/httpd/modules|/usr/local/lib/httpd/modules|g" "$f"
done
for f in "$K/bin/apachectl" "$K/bin/apxs" "$K/include/httpd/ap_config_auto.h" "$K/include/httpd/ap_config_layout.h" \
         "$K/lib/httpd/build/config_vars.mk" "$K/lib/httpd/build/config.nice"; do
  sed -i '' "s|$P|$OPT|g" "$f"
done
sed -i '' -e 's|/usr/local/Cellar/pcre2/[^/]*|/usr/local/opt/pcre2|g' \
  -e 's|${prefix}/lib/httpd/modules|/usr/local/lib/httpd/modules|g' "$K/lib/httpd/build/config_vars.mk"
# etc/httpd и var/www из DESTDIR -> в keg (ставит формула)
mkdir -p "$K/etc_dist" "$K/var_dist"
cp -R "$STAGE/usr/local/etc/httpd" "$K/etc_dist/"
cp -R "$STAGE/usr/local/var/www" "$K/var_dist/" 2>/dev/null || true
"$ROOT/homebrew-intel/scripts/fix-opt-paths.sh" "$K"
echo "Готово: $K"
