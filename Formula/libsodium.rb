# Готовый x86_64 keg libsodium 1.0.22, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Libsodium < Formula
  desc "NaCl networking and cryptography library (prebuilt x86_64 keg)"
  homepage "https://libsodium.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/libsodium-1.0.22/libsodium-1.0.22-x86_64-macos.tar.gz"
  version "1.0.22"
  sha256 "5a24c6624b99892cd9edb0ea1afb0968b4fa9d6a4ccd0d14b274e1148e8be233"
  license "ISC"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libsodium.dylib"
  end
end
