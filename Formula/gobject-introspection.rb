# Готовый x86_64 keg gobject-introspection 1.86.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-gi-x86_64.sh (параметры как у формулы homebrew-core).
class GobjectIntrospection < Formula
  desc "Generate introspection data for GObject libraries (prebuilt x86_64 keg)"
  homepage "https://gi.readthedocs.io/en/latest/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/gobject-introspection-1.86.0/gobject-introspection-1.86.0-x86_64-macos.tar.gz"
  version "1.86.0"
  sha256 "aa951d5a358f99c20fa9c423c491adfd1566220e987a2171cb87ec34a1c5e3af"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/cairo"
  depends_on "maxvandl/intel/glib"
  depends_on "maxvandl/intel/python@3.15"
  depends_on "pkgconf"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/g-ir-compiler --version")
    system bin/"g-ir-scanner", "--help"
  end
end
