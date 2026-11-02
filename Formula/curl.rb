# Готовый x86_64 keg curl 8.23.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Curl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server (prebuilt x86_64 keg)"
  homepage "https://curl.se"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/curl-8.23.0/curl-8.23.0-x86_64-macos.tar.gz"
  version "8.23.0"
  sha256 "57a9794cd7d96b74581d5bccaa9c21e533e9c553cd1831b28931aec38b6d2f64"
  license "curl"

  keg_only :provided_by_macos

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/brotli"
  depends_on "maxvandl/intel/libnghttp2"
  depends_on "maxvandl/intel/libnghttp3"
  depends_on "maxvandl/intel/libngtcp2"
  depends_on "maxvandl/intel/libpsl"
  depends_on "maxvandl/intel/libssh2"
  depends_on "maxvandl/intel/openssl@4"
  depends_on "zstd"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/curl --version")
    assert_match "OpenSSL/4", shell_output("#{bin}/curl --version")
  end
end
