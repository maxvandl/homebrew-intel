# Готовый x86_64 keg aws-iam-authenticator 0.7.24, кросс-собранный нативно на Apple Silicon
# скриптом scripts/build-go-x86_64.sh (параметры как у формулы homebrew-core).
class AwsIamAuthenticator < Formula
  desc "Use AWS IAM credentials to authenticate to Kubernetes (prebuilt x86_64 keg)"
  homepage "https://github.com/kubernetes-sigs/aws-iam-authenticator"
  url "https://github.com/maxvandl/homebrew-intel/releases/download/aws-iam-authenticator-0.7.24/aws-iam-authenticator-0.7.24-x86_64-macos.tar.gz"
  version "0.7.24"
  sha256 "4f6640df4c8a22d0866c6b5255347bb5ec422a60f687663ce6a697c23d3bb774"
  license "Apache-2.0"

  depends_on arch: :x86_64
  depends_on :macos

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aws-iam-authenticator version")
  end
end
