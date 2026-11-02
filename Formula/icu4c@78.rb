# Готовый x86_64 keg icu4c@78 78.3, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (SUBDIR=source) (параметры как у формулы homebrew-core).
class Icu4cAT78 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization (prebuilt x86_64 keg)"
  homepage "https://icu.unicode.org/home"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/icu4c%4078-78.3/icu4c@78-78.3-x86_64-macos.tar.gz"
  version "78.3"
  sha256 "55700c51bb0b75ddd62b16e7e4dc1c8ae19eb248ddddcdd181cef8fb7460f221"
  license "Unicode-3.0"

  keg_only :versioned_formula

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    (testpath/"hello").write "hello\nworld\n"
    system bin/"gendict", "--uchars", "hello", "dict"
  end
end
