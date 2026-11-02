# Готовый x86_64 keg boost 1.92.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-boost-x86_64.sh (параметры как у формулы homebrew-core).
class Boost < Formula
  desc "Collection of portable C++ source libraries (prebuilt x86_64 keg)"
  homepage "https://www.boost.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/boost-1.92.0/boost-1.92.0-x86_64-macos.tar.gz"
  version "1.92.0"
  sha256 "5ad46eb818ecc3e9a3bc9264d4ca04100f1de6dc5c44aa2de045539278ca3362"
  license "BSL-1.0"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/icu4c@79"
  depends_on "xz"
  depends_on "zstd"

  def install
    prefix.install Dir["*"]
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <boost/algorithm/string.hpp>
      #include <string>
      int main() { std::string s("a,b"); boost::to_upper(s); return s == "A,B" ? 0 : 1; }
    CPP
    system ENV.cxx, "test.cpp", "-std=c++17", "-I#{include}", "-o", "test"
    system "./test"
  end
end
