# Готовый x86_64 keg libvmaf 3.2.1, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-meson-x86_64.sh (параметры как у формулы homebrew-core).
class Libvmaf < Formula
  desc "Perceptual video quality assessment based on multi-method fusion"
  homepage "https://github.com/Netflix/vmaf"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/libvmaf-3.2.1/libvmaf-3.2.1-x86_64-macos.tar.gz"
  version "3.2.1"
  sha256 "2cc22e907f7ef8f25f11ca78735637c9a4fd359eff2bddeb01ba9fe94ae66f14"
  license "BSD-2-Clause-Patent"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libvmaf.dylib"
    assert_path_exists pkgshare/"model"
  end
end
