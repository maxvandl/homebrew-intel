# Готовый x86_64 keg libevent 2.1.13, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Libevent < Formula
  desc "Asynchronous event library (prebuilt x86_64 keg)"
  homepage "https://libevent.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/libevent-2.1.13/libevent-2.1.13-x86_64-macos.tar.gz"
  version "2.1.13"
  sha256 "eff9f117e53d1067d66f00ff5927e46c6db0fe6a19aabe2ebc5f641b71e189de"
  license "BSD-3-Clause"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/openssl@4"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libevent.dylib"
  end
end
