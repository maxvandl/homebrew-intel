# Готовый x86_64 keg krb5 1.22.2, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (SUBDIR=src, WARN_CFLAGS=-Wall) (параметры как у формулы homebrew-core).
class Krb5 < Formula
  desc "Network authentication protocol (prebuilt x86_64 keg)"
  homepage "https://web.mit.edu/kerberos/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/krb5-1.22.2/krb5-1.22.2-x86_64-macos.tar.gz"
  version "1.22.2"
  sha256 "8585270d5b42abb75443a62eafd11015f1542506fd89abc7b44bea99dac9413c"

  keg_only :provided_by_macos

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/openssl@4"

  def install
    prefix.install Dir["*"]
  end

  test do
    system bin/"krb5-config", "--version"
  end
end
