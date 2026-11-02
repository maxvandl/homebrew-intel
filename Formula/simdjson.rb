# Готовый x86_64 keg simdjson 5.1.1, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (параметры как у формулы homebrew-core).
class Simdjson < Formula
  desc "SIMD-accelerated C++ JSON parser (prebuilt x86_64 keg)"
  homepage "https://simdjson.org"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/simdjson-5.1.1/simdjson-5.1.1-x86_64-macos.tar.gz"
  version "5.1.1"
  sha256 "6af8970b5dfab115105e471ddf7ba288f3f259fa32040f387f5b39626437b48c"
  license "Apache-2.0"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libsimdjson.dylib"
    assert_path_exists include/"simdjson.h"
  end
end
