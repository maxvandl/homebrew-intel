# Готовый x86_64 keg fribidi 1.0.18, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (параметры как у формулы homebrew-core).
class Fribidi < Formula
  desc "Implementation of the Unicode BiDi algorithm (prebuilt x86_64 keg)"
  homepage "https://github.com/fribidi/fribidi"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/fribidi-1.0.18/fribidi-1.0.18-x86_64-macos.tar.gz"
  version "1.0.18"
  sha256 "85d087dd49ca050d32af00579c72c78207e461bf84a78e5098cfadbc5ec629bd"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    (testpath/"test.input").write "a _lsimple _RteST_o th_oat"
    assert_match "a simple TSet that", shell_output("#{bin}/fribidi --charset=CapRTL --clean test.input")
  end
end
