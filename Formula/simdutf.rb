# Готовый x86_64 keg simdutf 9.3.3, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (параметры как у формулы homebrew-core).
class Simdutf < Formula
  desc "Unicode conversion routines, fast (prebuilt x86_64 keg)"
  homepage "https://simdutf.github.io/simdutf/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/simdutf-9.3.3/simdutf-9.3.3-x86_64-macos.tar.gz"
  version "9.3.3"
  sha256 "0ce21ddcc01f0b198663d2ef22d61f4af9ac5cc8be3a60a62b93f3f61370213e"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/icu4c@79"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libsimdutf.dylib"
    system bin/"sutf-benchmark", "--help"
  end
end
