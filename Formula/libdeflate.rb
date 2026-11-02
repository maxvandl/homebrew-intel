# Готовый x86_64 keg libdeflate 1.26, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (параметры как у формулы homebrew-core).
class Libdeflate < Formula
  desc "Heavily optimized DEFLATE/zlib/gzip compression and decompression"
  homepage "https://github.com/ebiggers/libdeflate"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/libdeflate-1.26/libdeflate-1.26-x86_64-macos.tar.gz"
  version "1.26"
  sha256 "3295a5764e72ce687187fa14bbe7a1b303c19c1d638bd52066d0c2faa88f559c"
  license "MIT"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    (testpath/"foo").write "test"
    system bin/"libdeflate-gzip", "foo"
    system bin/"libdeflate-gunzip", "-d", "foo.gz"
    assert_equal "test", (testpath/"foo").read
  end
end
