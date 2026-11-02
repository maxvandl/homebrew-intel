# Готовый x86_64 keg libavif 1.4.2, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Libavif < Formula
  desc "Library for encoding and decoding .avif files (prebuilt x86_64 keg)"
  homepage "https://github.com/AOMediaCodec/libavif"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/libavif-1.4.2/libavif-1.4.2-x86_64-macos.tar.gz"
  version "1.4.2"
  sha256 "e27495ef4b30d404b3e07eb01cdcf1c725b625e7f04e55af588e6fe56ac82372"
  license "BSD-2-Clause"

  depends_on arch: :x86_64
  depends_on "libpng"
  depends_on :macos
  depends_on "maxvandl/intel/aom"
  depends_on "maxvandl/intel/dav1d"
  depends_on "maxvandl/intel/jpeg-turbo"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libavif.dylib"
    system bin/"avifenc", "--version"
  end
end
