# Готовый x86_64 keg libssh2 1.11.1, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Libssh2 < Formula
  desc "C library implementing the SSH2 protocol (prebuilt x86_64 keg)"
  homepage "https://libssh2.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/libssh2-1.11.1/libssh2-1.11.1-x86_64-macos.tar.gz"
  version "1.11.1"
  sha256 "e1a235b6c8e9985503914864b727dc707f6473a9b41af530b6b821ef8c1b805d"
  license "BSD-3-Clause"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/openssl@4"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libssh2.dylib"
  end
end
