# Готовый x86_64 keg jemalloc 5.4.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Jemalloc < Formula
  desc "Implementation of malloc emphasizing fragmentation avoidance"
  homepage "https://jemalloc.net/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/jemalloc-5.4.0/jemalloc-5.4.0-x86_64-macos.tar.gz"
  version "5.4.0"
  sha256 "d26489b2751b686decb0eb891caf87283463ef02b87118045e6ce7e1f80a30ef"
  license "BSD-2-Clause"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libjemalloc.dylib"
  end
end
