# Готовый x86_64 keg pkgconf 3.0.10, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Pkgconf < Formula
  desc "Package compiler and linker metadata toolkit (prebuilt x86_64 keg)"
  homepage "https://github.com/pkgconf/pkgconf"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/pkgconf-3.0.10/pkgconf-3.0.10-x86_64-macos.tar.gz"
  version "3.0.10"
  sha256 "2e96fdcc8e854e6b9c23c13f2c6d29488705257f70a90294140867f494881721"
  license "ISC"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pkgconf --version")
  end
end
