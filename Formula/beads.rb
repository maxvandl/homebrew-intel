# Готовый x86_64 keg beads 1.3.2, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-go-x86_64.sh (параметры как у формулы homebrew-core).
class Beads < Formula
  desc "Memory upgrade for your coding agent (prebuilt x86_64 keg)"
  homepage "https://github.com/gastownhall/beads"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/beads-1.3.2/beads-1.3.2-x86_64-macos.tar.gz"
  version "1.3.2"
  sha256 "2c5d828f7de09f34161de40ed6b2ab37b6a443741853e906a25ecc5f7a826e1e"
  license "MIT"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/dolt"
  depends_on "maxvandl/intel/icu4c@79"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bd version")
  end
end
