# Готовый x86_64 keg act 0.2.94, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-go-x86_64.sh (параметры как у формулы homebrew-core).
class Act < Formula
  desc "Run your GitHub Actions locally (prebuilt x86_64 keg)"
  homepage "https://nektosact.com"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/act-0.2.94/act-0.2.94-x86_64-macos.tar.gz"
  version "0.2.94"
  sha256 "774572b53d3dee88ec22a9c727de717878ed731b3eb0af578096854303410167"
  license "MIT"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/act --version")
  end
end
