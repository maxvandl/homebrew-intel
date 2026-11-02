# Готовый x86_64 keg apr-util 1.6.5, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class AprUtil < Formula
  desc "Companion library to apr, the Apache Portable Runtime library"
  homepage "https://apr.apache.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/apr-util-1.6.5/apr-util-1.6.5-x86_64-macos.tar.gz"
  version "1.6.5"
  sha256 "b2473b8ddb9b9db9f6d4c969b5e24865b782bda5078e35779da43b6cb7b82a96"
  license "Apache-2.0"

  keg_only :shadowed_by_macos

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/apr"
  depends_on "maxvandl/intel/openssl@4"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/apu-1-config --version")
  end
end
