# Готовый x86_64 harfbuzz с introspection, кросс-собранный нативно на Apple Silicon
# (scripts/build-meson-x86_64.sh harfbuzz ...). Слинкован с glib и cairo из этого tap
# и с icu4c@76 из Intel-brew (в homebrew-core сейчас icu4c@78, которого там нет).
class Harfbuzz < Formula
  desc "OpenType text shaping engine (prebuilt x86_64 keg)"
  homepage "https://github.com/harfbuzz/harfbuzz"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/harfbuzz-14.4.0/harfbuzz-14.4.0-x86_64-macos.tar.gz"
  version "14.4.0"
  sha256 "77988ec6fb0474afeae76fa023f6f32b3952489d8cc9d22fd411ed6107c87ad9"
  license "MIT"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/cairo"
  depends_on "freetype"
  depends_on "maxvandl/intel/glib"
  depends_on "graphite2"
  depends_on "icu4c@76"
  depends_on "libpng"

  def install
    prefix.install Dir["*"]
  end

  test do
    system bin/"hb-shape", "--version"
  end
end
