# Готовый x86_64 keg maturin 1.16.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-rust-x86_64.sh (параметры как у формулы homebrew-core).
class Maturin < Formula
  desc "Build and publish Rust crates as Python packages (prebuilt x86_64 keg)"
  homepage "https://github.com/PyO3/maturin"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/maturin-1.16.0/maturin-1.16.0-x86_64-macos.tar.gz"
  version "1.16.0"
  sha256 "7fd0e4837aa451245d47d04839b71e397e9446084bb7a793b0a1545c2302ef36"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "xz"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/maturin --version")
  end
end
