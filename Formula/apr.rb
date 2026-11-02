# Готовый x86_64 keg apr 1.7.6, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Apr < Formula
  desc "Apache Portable Runtime library (prebuilt x86_64 keg)"
  homepage "https://apr.apache.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/apr-1.7.6/apr-1.7.6-x86_64-macos.tar.gz"
  version "1.7.6"
  sha256 "133ef3309f6bcc2fcfdc8cf92222df108ec7148466b66f0d0322c4ca7910b53c"
  license "Apache-2.0"

  keg_only :provided_by_macos

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/apr-1-config --version")
  end
end
