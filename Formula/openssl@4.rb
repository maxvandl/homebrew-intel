# Готовый x86_64 OpenSSL 4.1.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-openssl4-x86_64.sh (конфигурация как у homebrew-core:
# darwin64-x86_64-cc enable-ec_nistp_64_gcc_128, openssldir в etc/openssl@4).
class OpensslAT4 < Formula
  desc "Cryptography and SSL/TLS Toolkit (prebuilt x86_64 keg)"
  homepage "https://openssl-library.org"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/openssl%404-4.1.0/openssl@4-4.1.0-x86_64-macos.tar.gz"
  version "4.1.0"
  sha256 "9e74417a8dea649593fc8bf8fec4e96066312f56211fe501250eff72cf4dd44a"
  license "Apache-2.0"

  depends_on arch: :x86_64
  depends_on "ca-certificates"
  depends_on :macos

  link_overwrite "bin/openssl", "include/openssl/*", "lib/libcrypto*", "lib/libssl*", "lib/ossl-modules/legacy.*",
                 "lib/cmake/OpenSSL/OpenSSLConfig.cmake", "lib/cmake/OpenSSL/OpenSSLConfigVersion.cmake",
                 "lib/pkgconfig/libcrypto.pc", "lib/pkgconfig/libssl.pc", "lib/pkgconfig/openssl.pc"

  def install
    prefix.install Dir["*"]
    (etc/"openssl@4").mkpath
    (etc/"openssl@4").install prefix/"openssl.cnf.dist" => "openssl.cnf.dist"
    cnf = etc/"openssl@4/openssl.cnf"
    cnf.write((etc/"openssl@4/openssl.cnf.dist").read) unless cnf.exist?
    %w[certs private].each { |d| (etc/"openssl@4"/d).mkpath }
  end

  post_install_steps do
    symlink "{{etc}}/ca-certificates/cert.pem", "{{pkgetc}}/cert.pem", overwrite: true
  end

  test do
    assert_path_exists etc/"openssl@4/openssl.cnf"
    (testpath/"testfile.txt").write("This is a test file")
    expected_checksum = "e2d0fe1585a63ec6009c8016ff8dda8b17719a637405a4e23c0ff81339148249"
    system bin/"openssl", "dgst", "-sha256", "-out", "checksum.txt", "testfile.txt"
    assert_equal expected_checksum, (testpath/"checksum.txt").read.split.last
    assert_match "4.1.0", shell_output("#{bin}/openssl version")
  end
end
