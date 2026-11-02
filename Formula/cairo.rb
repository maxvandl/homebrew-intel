# Готовый x86_64 cairo, кросс-собранный нативно на Apple Silicon
# (scripts/build-meson-x86_64.sh cairo ...). Слинкован с glib из этого tap
# и с x86_64-библиотеками Intel-brew (fontconfig, freetype, libpng, pixman, X11).
class Cairo < Formula
  desc "Vector graphics library with cross-device output support (prebuilt x86_64 keg)"
  homepage "https://cairographics.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/cairo-1.18.6/cairo-1.18.6-x86_64-macos.tar.gz"
  version "1.18.6"
  sha256 "81d370282b1426d3ae8b3d021adddd2e913e918bf10dd0bc1c58341b0af1b3a9"
  license any_of: ["LGPL-2.1-only", "MPL-1.1"]

  depends_on arch: :x86_64
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "libpng"
  depends_on "libx11"
  depends_on "libxcb"
  depends_on "libxext"
  depends_on "libxrender"
  depends_on "lzo"
  depends_on :macos
  depends_on "maxvandl/intel/glib"
  depends_on "pixman"

  def install
    prefix.install Dir["*"]
  end

  test do
    (testpath/"test.c").write <<~C
      #include <cairo.h>
      int main(void) { cairo_surface_t *s = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 10, 10); cairo_surface_destroy(s); return 0; }
    C
    flags = shell_output("pkg-config --cflags --libs cairo").chomp.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
