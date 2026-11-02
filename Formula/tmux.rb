# Готовый x86_64 keg tmux 3.8, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh), --enable-jemalloc (параметры как у формулы homebrew-core).
class Tmux < Formula
  desc "Terminal multiplexer (prebuilt x86_64 keg)"
  homepage "https://tmux.github.io/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/tmux-3.8/tmux-3.8-x86_64-macos.tar.gz"
  version "3.8"
  sha256 "a02a8a1e89c55dd3570fda186792c8094c4c649154731ae787c67763906b987d"
  license "ISC"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/jemalloc"
  depends_on "maxvandl/intel/libevent"
  depends_on "maxvandl/intel/ncurses"
  depends_on "maxvandl/intel/utf8proc"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tmux -V")
  end
end
