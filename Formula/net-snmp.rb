# Готовый x86_64 keg net-snmp 5.9.5.2, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-autotools-x86_64.sh (via build-phpdeps-x86_64.sh), explicit frameworks via LIBS (параметры как у формулы homebrew-core).
class NetSnmp < Formula
  desc "Implements SNMP v1, v2c, and v3, using IPv4 and IPv6 (prebuilt x86_64 keg)"
  homepage "http://www.net-snmp.org/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/net-snmp-5.9.5.2/net-snmp-5.9.5.2-x86_64-macos.tar.gz"
  version "5.9.5.2"
  sha256 "e13e9b668dc487a87ec90ec373eaaa89036293c3cd52eb84e29c3535177ff7ef"

  keg_only :provided_by_macos

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/openssl@4"

  def install
    prefix.install Dir["*"]
    (var/"db/net-snmp").mkpath
    (var/"log").mkpath
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/snmpget -V 2>&1")
  end
end
