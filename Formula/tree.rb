# Готовый x86_64 keg tree 2.3.2, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-phpdeps-x86_64.sh (make) (параметры как у формулы homebrew-core).
class Tree < Formula
  desc "Display directories as trees (with optional color/HTML output)"
  homepage "https://oldmanprogrammer.net/source.php?dir=projects/tree"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/tree-2.3.2/tree-2.3.2-x86_64-macos.tar.gz"
  version "2.3.2"
  sha256 "e9fad1958ce9e85fd3d1b28b10031bc0ee5afc8dd8c260f37bed3438c2142204"
  license "GPL-2.0-or-later"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    system bin/"tree", prefix
  end
end
