# Готовый x86_64 keg jpeg-turbo 3.2.1, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (параметры как у формулы homebrew-core).
class JpegTurbo < Formula
  desc "JPEG image codec that aids compression and decompression (prebuilt x86_64 keg)"
  homepage "https://www.libjpeg-turbo.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/jpeg-turbo-3.2.1/jpeg-turbo-3.2.1-x86_64-macos.tar.gz"
  version "3.2.1"
  sha256 "33e8750ff33ec65476aa931133ffeebdf7914089177437c5a2e6afd2f8454035"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libjpeg.8.dylib"
    assert_path_exists bin/"jpegtran"
  end
end
