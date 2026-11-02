# Готовый x86_64 keg gd 2.3.3, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Gd < Formula
  desc "Graphics library to dynamically manipulate images (prebuilt x86_64 keg)"
  homepage "https://libgd.github.io/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/gd-2.3.3/gd-2.3.3-x86_64-macos.tar.gz"
  version "2.3.3"
  sha256 "d57aa341269491de92e12e1134081ac707cc6568b74abc4cb20531d8de803ad5"
  license "GD"

  depends_on arch: :x86_64
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on :macos
  depends_on "maxvandl/intel/jpeg-turbo"
  depends_on "maxvandl/intel/libavif"
  depends_on "webp"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libgd.dylib"
  end
end
