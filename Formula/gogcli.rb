# Готовый x86_64 keg gogcli 0.47.1, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-go-x86_64.sh (параметры как у формулы homebrew-core).
class Gogcli < Formula
  desc "Google Suite CLI (prebuilt x86_64 keg)"
  homepage "https://gogcli.sh"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/gogcli-0.47.1/gogcli-0.47.1-x86_64-macos.tar.gz"
  version "0.47.1"
  sha256 "129183db3be0e717f8384fa26979540e08ddb01aa77ea2cc923e531c2c8cb9a4"
  license "MIT"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gog --version")
  end
end
