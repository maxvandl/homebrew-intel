# Готовый x86_64 keg libtool 2.6.2, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh), --program-prefix=g (параметры как у формулы homebrew-core).
class Libtool < Formula
  desc "Generic library support script (prebuilt x86_64 keg)"
  homepage "https://www.gnu.org/software/libtool/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/libtool-2.6.2/libtool-2.6.2-x86_64-macos.tar.gz"
  version "2.6.2"
  sha256 "40979c8b66366adfe5f9d9f77f03c1ed29136fbe4ba5c82a657b23c69b860d12"
  license "GPL-2.0-or-later"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/m4"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/glibtool --version")
  end
end
