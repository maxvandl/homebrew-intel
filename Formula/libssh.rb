# Готовый x86_64 keg libssh 0.12.2, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Libssh < Formula
  desc "C library SSHv1/SSHv2 client and server protocols (prebuilt x86_64 keg)"
  homepage "https://www.libssh.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/libssh-0.12.2/libssh-0.12.2-x86_64-macos.tar.gz"
  version "0.12.2"
  sha256 "e7e01c285ec48472e1237e278bac669aaf0fa4c4bf92388365f2bf294dee8e60"
  license "LGPL-2.1-or-later"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/openssl@4"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libssh.dylib"
    assert_path_exists lib/"libssh.a"
  end
end
