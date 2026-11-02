# Готовый x86_64 keg libzip 1.12.1, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Libzip < Formula
  desc "C library for reading, creating, and modifying zip archives"
  homepage "https://libzip.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/libzip-1.12.1/libzip-1.12.1-x86_64-macos.tar.gz"
  version "1.12.1"
  sha256 "e6fe2ecbabcba57803641dc39d8333d70d4ab2cc6a18717c8a6075456ea9fd2c"
  license "BSD-3-Clause"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "xz"
  depends_on "zstd"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libzip.dylib"
  end
end
