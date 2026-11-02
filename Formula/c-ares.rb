# Готовый x86_64 keg c-ares 1.34.9, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (параметры как у формулы homebrew-core).
class CAres < Formula
  desc "Asynchronous DNS library (prebuilt x86_64 keg)"
  homepage "https://c-ares.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/c-ares-1.34.9/c-ares-1.34.9-x86_64-macos.tar.gz"
  version "1.34.9"
  sha256 "30f363bcbd1c73e4af2911b4769e4e3e83d9b7123634e3a0e845029a980b09fd"
  license "MIT"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libcares.dylib"
    assert_match "c-ares", (lib/"pkgconfig/libcares.pc").read
  end
end
