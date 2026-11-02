# Готовый x86_64 keg trunk 0.22.1, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-rust-x86_64.sh (параметры как у формулы homebrew-core).
class Trunk < Formula
  desc "Build, bundle & ship your Rust WASM application to the web"
  homepage "https://trunk-rs.github.io/trunk"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/trunk-0.22.1/trunk-0.22.1-x86_64-macos.tar.gz"
  version "0.22.1"
  sha256 "1862722974b6dc7261f6d5862e8430f71bf70ccece11a5ed58f045c112b3f5db"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/openssl@4"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/trunk --version")
  end
end
