# Готовый x86_64 CMake 4.4.5, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmake-x86_64.sh (bootstrap --no-system-libs,
# системные zlib/bzip2/curl, как у homebrew-core).
class Cmake < Formula
  desc "Cross-platform make (prebuilt x86_64 keg)"
  homepage "https://www.cmake.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/cmake-4.4.5/cmake-4.4.5-x86_64-macos.tar.gz"
  version "4.4.5"
  sha256 "37f5a5496b864a72aa67baaec065cbab7271b4668d52912589f95d7f63d69ea4"
  license "BSD-3-Clause"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(Ruby)")
    system bin/"cmake", "."
    assert_match "4.4.5", shell_output("#{bin}/cmake --version")
  end
end
