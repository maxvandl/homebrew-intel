# Готовый x86_64 keg imath 3.2.3, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (параметры как у формулы homebrew-core).
class Imath < Formula
  desc "Library of 2D and 3D vector, matrix, and math operations (prebuilt x86_64 keg)"
  homepage "https://imath.readthedocs.io/en/latest/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/imath-3.2.3/imath-3.2.3-x86_64-macos.tar.gz"
  version "3.2.3"
  sha256 "fb0d6aa6ad18a4d7ce77f9957425d3392ce0953b84247c4ee50087e09fa80534"
  license "BSD-3-Clause"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libImath.dylib"
    assert_path_exists include/"Imath/ImathVec.h"
  end
end
