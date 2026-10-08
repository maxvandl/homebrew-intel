# Готовый x86_64 OpenSSL 3.6.5, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-openssl-x86_64.sh (конфигурация как у homebrew-core:
# no-ssl3, no-zlib, darwin64-x86_64-cc, openssldir в etc/openssl@3).
class OpensslAT3 < Formula
  desc "Cryptography and SSL/TLS Toolkit (prebuilt x86_64 keg)"
  homepage "https://openssl-library.org"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/openssl%403-3.6.5/openssl@3-3.6.5-x86_64-macos.tar.gz"
  version "3.6.5"
  sha256 "479d880e8cd1a081b2fcf5a1f65025cbb39e332c2ef0fce35a0a00cf11026435"
  license "Apache-2.0"

  depends_on arch: :x86_64
  depends_on "ca-certificates"
  depends_on :macos

  link_overwrite "bin/c_rehash", "bin/openssl", "include/openssl/*", "lib/libcrypto*", "lib/libssl*",
                 "lib/cmake/OpenSSL/*", "lib/pkgconfig/libcrypto.pc", "lib/pkgconfig/libssl.pc",
                 "lib/pkgconfig/openssl.pc"

  def install
    prefix.install Dir["*"]
    (etc/"openssl@3").mkpath
    (etc/"openssl@3").install prefix/"openssl.cnf.dist" => "openssl.cnf.dist"
    cnf = etc/"openssl@3/openssl.cnf"
    cnf.write((etc/"openssl@3/openssl.cnf.dist").read) unless cnf.exist?

    rm(etc/"openssl@3/cert.pem") if (etc/"openssl@3/cert.pem").exist?
    (etc/"openssl@3").install_symlink Formula["ca-certificates"].pkgetc/"cert.pem"
  end

  test do
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "e2d0fe1585a63ec6009c8016ff8dda8b17719a637405a4e23c0ff81339148249"
    system bin/"openssl", "dgst", "-sha256", "-out", "checksum.txt", "testfile.txt"
    assert_equal expected_checksum, (testpath/"checksum.txt").read.split.last
    assert_match "3.6.5", shell_output("#{bin}/openssl version")
  end
end
