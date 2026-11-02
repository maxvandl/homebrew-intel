# Готовый x86_64 keg gascity 1.5.1, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-go-x86_64.sh (параметры как у формулы homebrew-core).
class Gascity < Formula
  desc "Orchestration-builder SDK for multi-agent coding workflows"
  homepage "https://github.com/gastownhall/gascity"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/gascity-1.5.1/gascity-1.5.1-x86_64-macos.tar.gz"
  version "1.5.1"
  sha256 "ed378b82e244586a415a9acaf35e45e67d6e1e63b4685392c9371ca2beb02fd6"
  license "MIT"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/beads"
  depends_on "maxvandl/intel/dolt"
  depends_on "maxvandl/intel/flock"
  depends_on "maxvandl/intel/icu4c@79"
  depends_on "maxvandl/intel/jq"
  depends_on "tmux"

  def install
    prefix.install Dir["*"]
  end

  test do
    system bin/"gc", "--help"
  end
end
