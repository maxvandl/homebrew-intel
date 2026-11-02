# Готовый x86_64 keg openexr 3.5.3, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (параметры как у формулы homebrew-core).
class Openexr < Formula
  desc "High dynamic-range image file format (prebuilt x86_64 keg)"
  homepage "https://www.openexr.com/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/openexr-3.5.3/openexr-3.5.3-x86_64-macos.tar.gz"
  version "3.5.3"
  sha256 "c0594653de3c223669f08265051709778fe07f3e2da48b392bbe32b62c055933"
  license "BSD-3-Clause"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/imath"
  depends_on "maxvandl/intel/libdeflate"
  depends_on "maxvandl/intel/openjph"
  depends_on "zstd"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libOpenEXR.dylib"
    assert_match "Usage", shell_output("#{bin}/exrheader 2>&1", 1)
  end
end
