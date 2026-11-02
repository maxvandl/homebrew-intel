# Готовый x86_64 keg openjph 0.32.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (параметры как у формулы homebrew-core).
class Openjph < Formula
  desc "Open-source implementation of JPEG2000 Part-15 (or JPH or HTJ2K)"
  homepage "https://github.com/aous72/OpenJPH"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/openjph-0.32.0/openjph-0.32.0-x86_64-macos.tar.gz"
  version "0.32.0"
  sha256 "6566450959a9c4dd52c4537360de4319a06b28caf2101bcd69b707952e862b80"
  license "BSD-2-Clause"

  depends_on arch: :x86_64
  depends_on "libtiff"
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libopenjph.dylib"
    assert_match "arguments are necessary", shell_output("#{bin}/ojph_compress 2>&1", 255)
  end
end
