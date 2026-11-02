# Готовый x86_64 keg gemini-cli 0.66.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-gemini-cli-x86_64.sh (параметры как у формулы homebrew-core).
class GeminiCli < Formula
  desc "Interact with Google Gemini AI models from the command-line"
  homepage "https://geminicli.com"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/gemini-cli-0.66.0/gemini-cli-0.66.0-x86_64-macos.tar.gz"
  version "0.66.0"
  sha256 "6113c79ea74ccf0bf71bf45544c527757ebd471f130aed4ef450f3fdb5972b03"
  license "Apache-2.0"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/node"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gemini --version")
  end
end
