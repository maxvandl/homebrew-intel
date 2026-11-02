# Готовый x86_64 keg argon2 20190702, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-phpdeps-x86_64.sh (make) (параметры как у формулы homebrew-core).
class Argon2 < Formula
  desc "Password hashing library and CLI utility (prebuilt x86_64 keg)"
  homepage "https://github.com/P-H-C/phc-winner-argon2"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/argon2-20190702/argon2-20190702-x86_64-macos.tar.gz"
  version "20190702"
  sha256 "c4152015d116995613ba0c0408e744f3bc870ebee3f60c2de531cee613a153f6"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    output = pipe_output("#{bin}/argon2 somesalt -t 2 -m 16 -p 4", "password")
    assert_match "Encoded:", output
  end
end
