# Готовый x86_64 keg ncurses 6.6, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh), with homebrew-core libncurses symlinks (параметры как у формулы homebrew-core).
class Ncurses < Formula
  desc "Text-based UI library (prebuilt x86_64 keg)"
  homepage "https://invisible-island.net/ncurses/announce.html"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/ncurses-6.6/ncurses-6.6-x86_64-macos.tar.gz"
  version "6.6"
  sha256 "271f208f10cc1e6b898ea064d8e8dd7783e041381e4f62c1ed58b0923bc93e26"
  license "X11-distribute-modifications-variant"

  keg_only :provided_by_macos

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    system bin/"ncursesw6-config", "--version"
  end
end
