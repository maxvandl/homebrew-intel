# Готовый x86_64 keg icu4c@79 79.1, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (SUBDIR=source) (параметры как у формулы homebrew-core).
class Icu4cAT79 < Formula
  desc "C/C++ and Java libraries for Unicode and globalization (prebuilt x86_64 keg)"
  homepage "https://icu.unicode.org/home"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/icu4c%4079-79.1/icu4c@79-79.1-x86_64-macos.tar.gz"
  version "79.1"
  sha256 "ee9f0ce4a7af939f8e2f0968f273a5186f610f23c6f8162e0f3bc440a59279c8"
  license "Unicode-3.0"

  keg_only :shadowed_by_macos

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
