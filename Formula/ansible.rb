# Готовый x86_64 keg ansible 14.5.0, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-pyapp-x86_64.sh (CFLAGS/LDFLAGS for libssh) (параметры как у формулы homebrew-core).
class Ansible < Formula
  desc "Automate deployment, configuration, and upgrading (prebuilt x86_64 keg)"
  homepage "https://www.ansible.com/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/ansible-14.5.0/ansible-14.5.0-x86_64-macos.tar.gz"
  version "14.5.0"
  sha256 "e6c45366100f56d2df275cf630c0dcdb457e7a76aa0d28669cf24c892b164b58"
  license "GPL-3.0-or-later"

  depends_on arch: :x86_64
  depends_on :macos
  depends_on "maxvandl/intel/libssh"
  depends_on "maxvandl/intel/python@3.15"
  depends_on "maxvandl/intel/tree"

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match "ansible [core", shell_output("#{bin}/ansible --version")
  end
end
