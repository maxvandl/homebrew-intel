# Готовый x86_64 keg libpq 18.6, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-libpq-x86_64.sh (параметры как у формулы homebrew-core).
class Libpq < Formula
  desc "Postgres C API library (prebuilt x86_64 keg)"
  homepage "https://www.postgresql.org/docs/current/libpq.html"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/libpq-18.6/libpq-18.6-x86_64-macos.tar.gz"
  version "18.6"
  sha256 "bad841199fe9923d0c8968ab08d9e002e0d84e00b63a1ada162a9a2c663da06a"
  license "PostgreSQL"

  keg_only :versioned_formula

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/icu4c@79"
  depends_on "maxvandl/intel/krb5"
  depends_on "maxvandl/intel/openssl@4"
  depends_on "readline"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/psql --version")
    assert_path_exists lib/"libpq.dylib"
  end
end
