# Готовый x86_64 keg vacuum 0.36.2, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-go-x86_64.sh (параметры как у формулы homebrew-core).
class Vacuum < Formula
  desc "World's fastest OpenAPI & Swagger linter (prebuilt x86_64 keg)"
  homepage "https://quobix.com/vacuum/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/vacuum-0.36.2/vacuum-0.36.2-x86_64-macos.tar.gz"
  version "0.36.2"
  sha256 "746f8718058fca1570afb24b75cdc5b8091c329ec31bf4653ff6b64ee7cc721d"
  license "MIT"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vacuum version")
  end
end
