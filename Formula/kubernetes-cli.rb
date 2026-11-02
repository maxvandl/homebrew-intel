# Готовый x86_64 keg kubernetes-cli 1.37.2, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-go-x86_64.sh (параметры как у формулы homebrew-core).
class KubernetesCli < Formula
  desc "Kubernetes command-line interface (prebuilt x86_64 keg)"
  homepage "https://kubernetes.io/docs/reference/kubectl/"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/kubernetes-cli-1.37.2/kubernetes-cli-1.37.2-x86_64-macos.tar.gz"
  version "1.37.2"
  sha256 "f2f5f0565b4646aafc3ae1d404872189122a474c42f7189e41007a8af1915300"
  license "Apache-2.0"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kubectl version --client 2>&1")
  end
end
