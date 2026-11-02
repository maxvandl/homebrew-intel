# Готовый x86_64 keg tidy-html5 5.8.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class TidyHtml5 < Formula
  desc "Granddaddy of HTML tools, with support for modern standards"
  homepage "https://www.html-tidy.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/tidy-html5-5.8.0/tidy-html5-5.8.0-x86_64-macos.tar.gz"
  version "5.8.0"
  sha256 "8cc65a0262257721c26fa713c65ecb237161d19c8716e4d8f45155a37c3651ee"
  license "Zlib"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tidy --version")
  end
end
