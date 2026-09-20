# Psi+ XMPP client, built from psi-plus/psi-plus-snapshots on Apple Silicon.
# Two separate builds rather than one universal binary: Homebrew ships no
# x86_64 bottle of Qt 6.11.2 for macOS 27, so the Intel slice is linked
# against the Qt 6.7.3 already present in the Intel prefix.
# Ad-hoc signed, not notarized - see caveats.
cask "psi-plus" do
  version "1.5.2182"

  on_arm do
    sha256 "2e1b8e8037f4ad08d67c389e57480e45bb4a110f09983da82ad405a82f1f302c"
    url "https://github.com/maxvandl/homebrew-intel/releases/download/psi-plus-#{version}/psi-plus-#{version}-arm64.dmg"
  end
  on_intel do
    sha256 "8dc4101df8877991c7aa7bb7c06e9df69a4d7a547c1b3c2bf2c86be449983ac2"
    url "https://github.com/maxvandl/homebrew-intel/releases/download/psi-plus-#{version}/psi-plus-#{version}-x86_64.dmg"
  end

  name "Psi+"
  desc "XMPP client designed for experienced users"
  homepage "https://psi-im.org/"

  depends_on macos: :ventura

  app "Psi+.app"

  caveats <<~EOS
    These builds are ad-hoc signed and not notarized, so Gatekeeper will
    refuse the first launch. Open it once via right-click -> Open, or:
      xattr -dr com.apple.quarantine "/Applications/Psi+.app"
  EOS

  zap trash: [
    "~/Library/Application Support/Psi+",
    "~/Library/Preferences/com.psi-plus.Psi+.plist",
    "~/Library/Saved Application State/com.psi-plus.savedState",
  ]
end
