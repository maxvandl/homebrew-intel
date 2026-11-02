# Готовый x86_64 keg libngtcp2 1.25.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Libngtcp2 < Formula
  desc "IETF QUIC protocol implementation (prebuilt x86_64 keg)"
  homepage "https://nghttp2.org/ngtcp2/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/libngtcp2-1.25.0/libngtcp2-1.25.0-x86_64-macos.tar.gz"
  version "1.25.0"
  sha256 "cf410c268a5491385ffbdc8d58aeaef1e0666dc11746cc9e3c976b9e715be35a"
  license "MIT"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/openssl@4"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libngtcp2.dylib"
  end
end
