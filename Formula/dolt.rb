# Готовый x86_64 keg dolt 2.6.2, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-go-x86_64.sh (параметры как у формулы homebrew-core).
class Dolt < Formula
  desc "Git for Data (prebuilt x86_64 keg)"
  homepage "https://www.dolthub.com"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/dolt-2.6.2/dolt-2.6.2-x86_64-macos.tar.gz"
  version "2.6.2"
  sha256 "4335f0b0b056190c83771dabae5af6f947806434b46192fa6e2d96b2229a84b7"
  license "Apache-2.0"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/icu4c@79"

  def install
    prefix.install Dir["*"]
    (etc/"dolt").install Dir[prefix/"etc_dist/dolt/*"]
    rm_r prefix/"etc_dist"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dolt version")
  end
end
