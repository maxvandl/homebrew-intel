# Готовый x86_64 keg php 8.5.12, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-php-x86_64.sh (параметры как у формулы homebrew-core).
class Php < Formula
  desc "General-purpose scripting language (prebuilt x86_64 keg)"
  homepage "https://www.php.net/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/php-8.5.12/php-8.5.12-x86_64-macos.tar.gz"
  version "8.5.12"
  sha256 "40753bae14a25f7ac8b9eaeba39d32799c55fbefbc7e5b571ea71be60b3e9af5"

  depends_on arch: :x86_64
  depends_on "gettext"
  depends_on :macos
  depends_on "maxvandl/intel/apr"
  depends_on "maxvandl/intel/apr-util"
  depends_on "maxvandl/intel/argon2"
  depends_on "maxvandl/intel/autoconf"
  depends_on "maxvandl/intel/curl"
  depends_on "maxvandl/intel/freetds"
  depends_on "maxvandl/intel/gd"
  depends_on "maxvandl/intel/gmp"
  depends_on "maxvandl/intel/icu4c@79"
  depends_on "maxvandl/intel/libpq"
  depends_on "maxvandl/intel/libsodium"
  depends_on "maxvandl/intel/libzip"
  depends_on "maxvandl/intel/net-snmp"
  depends_on "maxvandl/intel/oniguruma"
  depends_on "maxvandl/intel/openldap"
  depends_on "maxvandl/intel/openssl@4"
  depends_on "maxvandl/intel/tidy-html5"
  depends_on "maxvandl/intel/unixodbc"
  depends_on "pcre2"
  depends_on "sqlite"

  def install
    prefix.install Dir["*"]
    (etc/"php/#{version.major_minor}").install Dir[prefix/"etc_dist/*"]
    rm_r prefix/"etc_dist"
    unless (var/"log/php-fpm.log").exist?
      (var/"log").mkpath
      touch var/"log/php-fpm.log"
    end
  end

  post_install_steps do
    configure_php
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/php -v")
    assert_match "intl", shell_output("#{bin}/php -m")
    system sbin/"php-fpm", "-t", "-y", etc/"php/#{version.major_minor}/php-fpm.conf"
  end
end
