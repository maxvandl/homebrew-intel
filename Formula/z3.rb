# Готовый x86_64 keg z3 5.3.3, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-z3-x86_64.sh (параметры как у формулы homebrew-core).
class Z3 < Formula
  desc "High-performance theorem prover (prebuilt x86_64 keg)"
  homepage "https://github.com/Z3Prover/z3"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/z3-5.3.3/z3-5.3.3-x86_64-macos.tar.gz"
  version "5.3.3"
  sha256 "1b49ce7abb6fce469bf95d5f18a1b637e61c8ba422d85a4b24a1b2d98addf8b6"
  license "MIT"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    (testpath/"test.smt2").write "(declare-const a Int)\n(assert (> a 2))\n(check-sat)\n"
    assert_match "sat", shell_output("#{bin}/z3 -smt2 test.smt2")
  end
end
