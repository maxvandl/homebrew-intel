# Готовый x86_64 keg libnghttp3 1.18.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Libnghttp3 < Formula
  desc "HTTP/3 library written in C (prebuilt x86_64 keg)"
  homepage "https://nghttp2.org/nghttp3/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/libnghttp3-1.18.0/libnghttp3-1.18.0-x86_64-macos.tar.gz"
  version "1.18.0"
  sha256 "4db37cc145c0d7e6fcb9293228d8f6a94556eade837abfe2f823679fb4976ee2"
  license "MIT"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libnghttp3.dylib"
  end
end
