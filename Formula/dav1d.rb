# Готовый x86_64 keg dav1d 1.5.4, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-meson-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Dav1d < Formula
  desc "AV1 decoder targeted to be small and fast (prebuilt x86_64 keg)"
  homepage "https://code.videolan.org/videolan/dav1d"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/dav1d-1.5.4/dav1d-1.5.4-x86_64-macos.tar.gz"
  version "1.5.4"
  sha256 "a9186386e2ed7d85863837e0622e7bc041f37bacd16f70878be97abea0bb65c4"
  license "BSD-2-Clause"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dav1d --version 2>&1")
  end
end
