# Готовый x86_64 keg flock 0.4.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Flock < Formula
  desc "Lock file during command (prebuilt x86_64 keg)"
  homepage "https://github.com/discoteq/flock"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/flock-0.4.0/flock-0.4.0-x86_64-macos.tar.gz"
  version "0.4.0"
  sha256 "4ab67fd70404a96f1834b5c3856dd4116dd31352c053a3033fbd5dbe1dc2f242"
  license "ISC"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    system bin/"flock", "--version"
  end
end
