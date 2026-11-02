# Готовый x86_64 keg unixodbc 2.3.14, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (параметры как у формулы homebrew-core).
class Unixodbc < Formula
  desc "ODBC 3 connectivity for UNIX (prebuilt x86_64 keg)"
  homepage "https://www.unixodbc.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/unixodbc-2.3.14/unixodbc-2.3.14-x86_64-macos.tar.gz"
  version "2.3.14"
  sha256 "50af6fae2998aef4ea417f570808c93ea7e8dd10d05c8f6977d1db3cafca88be"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
    etc.install Dir[prefix/"etc_dist/*"]
    rm_r prefix/"etc_dist"
  end

  test do
    system bin/"odbcinst", "-j"
  end
end
