# Готовый x86_64 keg mole 1.67.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-go-x86_64.sh (параметры как у формулы homebrew-core).
class Mole < Formula
  desc "Deep clean and optimize your Mac (prebuilt x86_64 keg)"
  homepage "https://mole.fit"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/mole-1.67.0/mole-1.67.0-x86_64-macos.tar.gz"
  version "1.67.0"
  sha256 "a090c642b659edc51f7548ea2ca8fe41447dc574c09f297cec2b5fcc2712b51b"
  license "GPL-3.0-or-later"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mole --version")
  end
end
