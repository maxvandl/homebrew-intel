# Готовый x86_64 keg freetds 1.5.20, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (параметры как у формулы homebrew-core).
class Freetds < Formula
  desc "Libraries to talk to Microsoft SQL Server and Sybase databases"
  homepage "https://www.freetds.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/freetds-1.5.20/freetds-1.5.20-x86_64-macos.tar.gz"
  version "1.5.20"
  sha256 "52bda4c283da501ca4676f1e4e4dbedeee5a345f942013fd3b355405428edca1"
  license "GPL-2.0-or-later"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/openssl@4"
  depends_on "maxvandl/intel/unixodbc"

  def install
    prefix.install Dir["*"]
    etc.install Dir[prefix/"etc_dist/*"]
    rm_r prefix/"etc_dist"
  end

  test do
    system bin/"tsql", "-C"
  end
end
