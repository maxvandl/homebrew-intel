# Готовый x86_64 keg httpd 2.4.69, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-httpd-x86_64.sh (параметры как у формулы homebrew-core).
class Httpd < Formula
  desc "Apache HTTP server (prebuilt x86_64 keg)"
  homepage "https://httpd.apache.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/httpd-2.4.69/httpd-2.4.69-x86_64-macos.tar.gz"
  version "2.4.69"
  sha256 "62dc49153553c47eb5db6f45cd8c89de070019970f120bb285785f2385764135"
  license "Apache-2.0"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/apr"
  depends_on "maxvandl/intel/apr-util"
  depends_on "maxvandl/intel/brotli"
  depends_on "maxvandl/intel/libnghttp2"
  depends_on "maxvandl/intel/openssl@4"
  depends_on "pcre2"

  def install
    prefix.install Dir["*"]
    (etc/"httpd").install Dir[prefix/"etc_dist/httpd/*"]
    (var/"www").install Dir[prefix/"var_dist/www/*"]
    rm_r prefix/"etc_dist"
    rm_r prefix/"var_dist"
    (var/"cache/httpd").mkpath
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/httpd -v")
  end
end
