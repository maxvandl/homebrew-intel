# Готовый x86_64 keg Python 3.15, кросс-собранный нативно на Apple Silicon скриптом
# scripts/build-python-x86_64.sh: повторяет install формулы homebrew-core (framework-сборка
# с PGO+LTO, те же патчи, pip из sdist, sitecustomize.py, EXTERNALLY-MANAGED).
class PythonAT315 < Formula
  desc "Interpreted, interactive, object-oriented language (prebuilt x86_64 keg)"
  homepage "https://www.python.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/python%403.15-3.15.2/python@3.15-3.15.2-x86_64-macos.tar.gz"
  version "3.15.2"
  sha256 "a583db085e9f2da718c2b92cf6bc5bdfe779d3cb395fb5a1291f90cd441f2934"
  license "Python-2.0"

  depends_on arch: :x86_64
  depends_on "ca-certificates"
  depends_on :macos
  depends_on "maxvandl/intel/openssl@4"
  depends_on "mpdecimal"
  depends_on "sqlite"
  depends_on "xz"
  depends_on "zstd"

  link_overwrite "bin/idle3", "bin/pip3", "bin/pydoc3", "bin/python3", "bin/python3-config",
                 "share/man/man1/python3.1", "lib/libpython3.so",
                 "lib/pkgconfig/python3.pc", "lib/pkgconfig/python3-embed.pc",
                 "lib/python3.15/site-packages/pip*",
                 "Frameworks/Python.framework/Headers", "Frameworks/Python.framework/Python",
                 "Frameworks/Python.framework/Resources", "Frameworks/Python.framework/Versions/Current"

  def install
    prefix.install Dir["*"]
  end

  post_install_steps do
    set_permissions "Python.framework/Versions/{{version.major_minor}}/" \
                    "lib/python{{version.major_minor}}/venv/scripts/**/*",
                    "u+w", base: :frameworks, recursive: false
  end

  def caveats
    <<~EOS
      Python is installed as
        #{HOMEBREW_PREFIX}/bin/python3

      Unversioned symlinks `python`, `python-config`, `pip` etc. pointing to
      `python3`, `python3-config`, `pip3` etc., respectively, are installed into
        #{opt_libexec}/bin
    EOS
  end

  test do
    python3 = bin/"python3.15"
    system python3, "-c", "import sqlite3"
    system python3, "-m", "venv", testpath/"myvenv"
    system python3, "-c", "import _ctypes"
    system python3, "-c", "import _decimal"
    system python3, "-c", "import pyexpat"
    system python3, "-c", "import readline"
    system python3, "-c", "import zlib"
    system python3, "-c", "import _zstd"
    assert_match "OpenSSL 4", shell_output("#{python3} -c 'import ssl; print(ssl.OPENSSL_VERSION)'")
    system bin/"pip3", "list", "--format=columns"
  end
end
