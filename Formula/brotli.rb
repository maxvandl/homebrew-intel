# Готовый x86_64 keg brotli 1.2.1, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (параметры как у формулы homebrew-core).
class Brotli < Formula
  desc "Generic-purpose lossless compression algorithm by Google (prebuilt x86_64 keg)"
  homepage "https://github.com/google/brotli"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/brotli-1.2.1/brotli-1.2.1-x86_64-macos.tar.gz"
  version "1.2.1"
  sha256 "685148d138164fd9979ce77c7188f269b9e4c37b99a5f1c9998081138b8d9540"
  license "MIT"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    (testpath/"file.txt").write("Hello, World!")
    system bin/"brotli", "file.txt"
    system bin/"brotli", "file.txt.br", "--output=out.txt", "--decompress"
    assert_equal "Hello, World!", (testpath/"out.txt").read
  end
end
