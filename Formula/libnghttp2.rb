# Готовый x86_64 keg libnghttp2 1.70.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-phpdeps-x86_64.sh (lib only) (параметры как у формулы homebrew-core).
class Libnghttp2 < Formula
  desc "HTTP/2 C Library (prebuilt x86_64 keg)"
  homepage "https://nghttp2.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/libnghttp2-1.70.0/libnghttp2-1.70.0-x86_64-macos.tar.gz"
  version "1.70.0"
  sha256 "1b952e930eae8263033be4b8ed3308686f1ac1b4a801b378af56158a0f2e75b5"
  license "MIT"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libnghttp2.dylib"
  end
end
