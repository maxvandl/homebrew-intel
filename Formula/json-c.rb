# Готовый x86_64 keg json-c 0.19, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class JsonC < Formula
  desc "JSON parser for C (prebuilt x86_64 keg)"
  homepage "https://github.com/json-c/json-c/wiki"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/json-c-0.19/json-c-0.19-x86_64-macos.tar.gz"
  version "0.19"
  sha256 "4cdb91b47e50465aadd12516c1cf9eeca47ae710af859626b547dbf3af39e6b6"
  license "MIT"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libjson-c.dylib"
  end
end
