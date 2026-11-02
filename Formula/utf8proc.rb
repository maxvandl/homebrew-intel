# Готовый x86_64 keg utf8proc 2.12.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-cmakeproj-x86_64.sh (via build-phpdeps-x86_64.sh) (параметры как у формулы homebrew-core).
class Utf8proc < Formula
  desc "Clean C library for processing UTF-8 Unicode data (prebuilt x86_64 keg)"
  homepage "https://juliastrings.github.io/utf8proc/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/utf8proc-2.12.0/utf8proc-2.12.0-x86_64-macos.tar.gz"
  version "2.12.0"
  sha256 "af4acc8de86a6bf68bed37e9abb59c44f4ace39dff25410561c2ad8a23dcd24f"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_path_exists lib/"libutf8proc.dylib"
  end
end
