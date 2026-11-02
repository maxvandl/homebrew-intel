# Готовый x86_64 keg oniguruma 6.9.10, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Oniguruma < Formula
  desc "Regular expressions library (prebuilt x86_64 keg)"
  homepage "https://github.com/kkos/oniguruma/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/oniguruma-6.9.10/oniguruma-6.9.10-x86_64-macos.tar.gz"
  version "6.9.10"
  sha256 "368cd222359428c2e9c607d3f8b92a5cede4a62cc69f5edc8f980b73a406614e"
  license "BSD-2-Clause"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/onig-config --version")
  end
end
