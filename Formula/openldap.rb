# Готовый x86_64 keg openldap 2.7.2, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (OPTLINKS=openssl@4) (параметры как у формулы homebrew-core).
class Openldap < Formula
  desc "Open source suite of directory software (prebuilt x86_64 keg)"
  homepage "https://www.openldap.org/software/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/openldap-2.7.2/openldap-2.7.2-x86_64-macos.tar.gz"
  version "2.7.2"
  sha256 "2fb14faa653de515e0ce35b8d4b8af9dd0e7aeb452334bdd58160561fa2c2a58"
  license "OLDAP-2.8"

  keg_only :provided_by_macos

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/openssl@4"

  def install
    prefix.install Dir["*"]
    # конфиги как у homebrew-core (etc/openldap, пути через opt_prefix); существующие не перезаписываются
    (etc/"openldap").install Dir[prefix/"etc_dist/openldap/*"]
    rm_r prefix/"etc_dist"
    (var/"run").mkpath
    chmod 0755, etc.glob("openldap/*")
    chmod 0755, etc.glob("openldap/schema/*")
  end

  test do
    system sbin/"slappasswd", "-s", "test"
  end
end
