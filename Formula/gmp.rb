# Готовый x86_64 keg gmp 6.3.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh), --build=nehalem-apple-darwin27 (параметры как у формулы homebrew-core).
class Gmp < Formula
  desc "GNU multiple precision arithmetic library (prebuilt x86_64 keg)"
  homepage "https://gmplib.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/gmp-6.3.0/gmp-6.3.0-x86_64-macos.tar.gz"
  version "6.3.0"
  sha256 "798ef42cc1a94517c1704da67d4c944d9fcb176151833659dc40c791506820e6"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libgmp.dylib"
    assert_path_exists lib/"libgmpxx.dylib"
  end
end
