# Готовый x86_64 keg sphinx-doc 9.2.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-pyapp-x86_64.sh (параметры как у формулы homebrew-core).
class SphinxDoc < Formula
  desc "Tool to create intelligent and beautiful documentation (prebuilt x86_64 keg)"
  homepage "https://www.sphinx-doc.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/sphinx-doc-9.2.0/sphinx-doc-9.2.0-x86_64-macos.tar.gz"
  version "9.2.0"
  sha256 "1b7c307b7de32c935a380c1f7c4e039bf0057b55068f3b70ad8b9120c418c8a7"
  license "BSD-2-Clause"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/python@3.15"

  def install
    prefix.install Dir["*"]
  end

  test do
    system bin/"sphinx-build", "--version"
  end
end
