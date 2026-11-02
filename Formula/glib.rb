# Готовый x86_64 glib 2.90.1 с gobject-introspection 1.86.0, кросс-собранный
# нативно на Apple Silicon скриптом scripts/build-glib-x86_64.sh по трёхстадийной
# схеме формулы homebrew-core (g-ir-scanner, как и у Homebrew, живёт в отдельной
# формуле gobject-introspection; сюда входит встроенный gi-compile-repository).
class Glib < Formula
  desc "Core application library for C (prebuilt x86_64 keg)"
  homepage "https://gitlab.gnome.org/GNOME/glib"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/glib-2.90.1/glib-2.90.1-x86_64-macos.tar.gz"
  version "2.90.1"
  sha256 "126cc2e23a7912aa9fabd1013b19766dbf7998722c7dbd7158cd34f9d2472903"
  license "LGPL-2.1-or-later"

  depends_on arch: :x86_64
  depends_on "gettext"
  depends_on :macos
  depends_on "pcre2"
  uses_from_macos "libffi"

  def install
    prefix.install Dir["*"]

    # Как в homebrew-core: giomoduledir через ${libdir}, gettext в flags glib-2.0.pc
    inreplace lib/"pkgconfig/gio-2.0.pc",
              "giomoduledir=#{HOMEBREW_PREFIX}/lib/gio/modules",
              "giomoduledir=${libdir}/gio/modules"
    inreplace lib/"pkgconfig/glib-2.0.pc" do |s|
      s.gsub! "Libs: -L${libdir} -lglib-2.0 -lintl",
              "Libs: -L${libdir} -lglib-2.0 -L#{formula_opt_lib("gettext")} -lintl"
      s.gsub! "Cflags: -I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include",
              "Cflags: -I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include -I#{formula_opt_include("gettext")}"
    end
    bash_completion.install (share/"bash-completion/completions").children
  end

  post_install_steps do
    mkdir_p "lib/gio/modules", base: :homebrew_prefix
  end

  test do
    (testpath/"test.c").write <<~C
      #include <glib.h>
      int main(void) { GString *s = g_string_new("hello"); g_string_append(s, " glib"); g_print("%s\\n", s->str); return 0; }
    C
    flags = shell_output("pkg-config --cflags --libs glib-2.0").chomp.split
    system ENV.cc, "test.c", "-o", "test", *flags
    assert_equal "hello glib", shell_output("./test").strip
  end
end
