# Готовый x86_64 keg mac-cleanup-py 3.4.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-pyapp-x86_64.sh (параметры как у формулы homebrew-core).
class MacCleanupPy < Formula
  desc "Python cleanup script for macOS (prebuilt x86_64 keg)"
  homepage "https://github.com/mac-cleanup/mac-cleanup-py"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/mac-cleanup-py-3.4.0/mac-cleanup-py-3.4.0-x86_64-macos.tar.gz"
  version "3.4.0"
  sha256 "c2c9886429cb8a53b6ab0c49be3df42ba35814f58e73f42bacf807977e67baf7"
  license "Apache-2.0"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/python@3.15"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists bin/"mac-cleanup"
  end
end
