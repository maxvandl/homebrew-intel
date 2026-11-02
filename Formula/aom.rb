# Готовый x86_64 keg aom 3.15.3, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (параметры как у формулы homebrew-core).
class Aom < Formula
  desc "Codec library for encoding and decoding AV1 video streams (prebuilt x86_64 keg)"
  homepage "https://aomedia.googlesource.com/aom"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/aom-3.15.3/aom-3.15.3-x86_64-macos.tar.gz"
  version "3.15.3"
  sha256 "e50758f5ca9aa9bca791efd42ca49716af9cb993b35cb3020fb280f0e5327824"
  license "BSD-2-Clause"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/libvmaf"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libaom.dylib"
    system bin/"aomenc", "--help"
  end
end
