# Готовый x86_64 keg doctl 2.1.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-go-x86_64.sh (параметры как у формулы homebrew-core).
class Doctl < Formula
  desc "Command-line tool for DigitalOcean (prebuilt x86_64 keg)"
  homepage "https://docs.digitalocean.com/reference/doctl/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/doctl-2.1.0/doctl-2.1.0-x86_64-macos.tar.gz"
  version "2.1.0"
  sha256 "3d2136e4353d4ef9046d18b0975243194b5d02e0e2a70aedd97bee451676d8e3"
  license "Apache-2.0"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match "doctl version #{version}", shell_output("#{bin}/doctl version")
  end
end
