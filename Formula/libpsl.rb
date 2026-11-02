# Готовый x86_64 keg libpsl 0.23.3, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Libpsl < Formula
  desc "C library for the Public Suffix List (prebuilt x86_64 keg)"
  homepage "https://rockdaboot.github.io/libpsl"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/libpsl-0.23.3/libpsl-0.23.3-x86_64-macos.tar.gz"
  version "0.23.3"
  sha256 "c30b7a5a05efad07f8644b192f60ec414301f742d42245b60749b2bf433082d7"
  license "MIT"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match "Public Suffix List", shell_output("#{bin}/psl --version 2>&1")
  end
end
