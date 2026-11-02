# Готовый x86_64 keg autoconf 2.73, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Autoconf < Formula
  desc "Automatic configure script builder (prebuilt x86_64 keg)"
  homepage "https://www.gnu.org/software/autoconf/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/autoconf-2.73/autoconf-2.73-x86_64-macos.tar.gz"
  version "2.73"
  sha256 "46c666d4fb61ba98d37b2a0f466cbddc1a996f864d5f62e901824df5212a24bb"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/m4"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/autoconf --version")
  end
end
