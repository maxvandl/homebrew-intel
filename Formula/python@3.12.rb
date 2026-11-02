# Готовый x86_64 keg Python 3.12, кросс-собранный нативно на Apple Silicon скриптом
# scripts/build-python-x86_64.sh: повторяет install формулы homebrew-core (framework-сборка
# с PGO+LTO, openssl@3, те же патчи, pip из sdist, sitecustomize.py, EXTERNALLY-MANAGED).
class PythonAT312 < Formula
  desc "Interpreted, interactive, object-oriented language (prebuilt x86_64 keg)"
  homepage "https://www.python.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/python%403.12-3.12.16/python@3.12-3.12.16-x86_64-macos.tar.gz"
  version "3.12.16"
  sha256 "ba3d43dcb93368f4f87658e66a5a21aeb1bbe6cad6ef2d6810907917b9b3dd93"
  license "Python-2.0"

  depends_on arch: :x86_64
  depends_on "ca-certificates"
  depends_on :macos
  depends_on "maxvandl/intel/openssl@3"
  depends_on "mpdecimal"
  depends_on "sqlite"
  depends_on "xz"

  link_overwrite "lib/python3.12/site-packages/pip*", "lib/python3.12/site-packages/wheel*"

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
        #{HOMEBREW_PREFIX}/bin/python3.12

      Unversioned and major-versioned symlinks `python`, `python3`, `pip`, `pip3` etc. pointing to
      `python3.12`, `pip3.12` etc., respectively, are installed into
        #{opt_libexec}/bin
    EOS
  end

  test do
    python3 = bin/"python3.12"
    system python3, "-c", "import sqlite3"
    system python3, "-m", "venv", testpath/"myvenv"
    system python3, "-c", "import _ctypes"
    system python3, "-c", "import _decimal"
    system python3, "-c", "import pyexpat"
    system python3, "-c", "import readline"
    system python3, "-c", "import zlib"
    assert_match "OpenSSL 3", shell_output("#{python3} -c 'import ssl; print(ssl.OPENSSL_VERSION)'")
    system bin/"pip3.12", "list", "--format=columns"
  end
end
