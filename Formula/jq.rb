# Готовый x86_64 keg jq 1.8.2, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Jq < Formula
  desc "Lightweight and flexible command-line JSON processor (prebuilt x86_64 keg)"
  homepage "https://jqlang.github.io/jq/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/jq-1.8.2/jq-1.8.2-x86_64-macos.tar.gz"
  version "1.8.2"
  sha256 "cd8b2caba828fc935a84c48b7486a74fe889bd49fe437de76052bd5ad2b30d8f"
  license "MIT"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/oniguruma"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_equal "2\n", pipe_output("#{bin}/jq .bar", '{"foo":1, "bar":2}')
  end
end
