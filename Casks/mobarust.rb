# MobaRust desktop preview, taken from the upstream OthmaneBlial/MobaRust
# release. Unlike psi-plus, upstream already publishes per-architecture macOS
# disk images, so this cask points straight at those instead of re-hosting a
# build of its own; on_arm/on_intel picks the matching thin slice.
# Ad-hoc signed, not notarized - see caveats.
cask "mobarust" do
  version "0.1.1"

  on_arm do
    sha256 "0e26a968234148f55a11ffd140fcc83192ceb22db0014fd51f114c1be7076c49"

    url "https://github.com/OthmaneBlial/MobaRust/releases/download/v#{version}/MobaRust-#{version}-macos-arm64.dmg"
  end
  on_intel do
    sha256 "d5e49d724f7715cf6ec249697bb693ef2b3f7214a957a426aca84b3eccc7124c"

    url "https://github.com/OthmaneBlial/MobaRust/releases/download/v#{version}/MobaRust-#{version}-macos-x64.dmg"
  end

  name "MobaRust"
  desc "SSH client, SFTP browser and terminal workspace"
  homepage "https://othmaneblial.github.io/MobaRust/"

  # Upstream's only release so far is flagged a GitHub pre-release, which both
  # :github_latest and the stock :github_releases block skip over. Match the
  # release tags directly instead, excluding only drafts.
  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_releases do |json, regex|
      json.filter_map do |release|
        next if release["draft"]

        release["tag_name"]&.[](regex, 1)
      end
    end
  end

  # The bundle's LSMinimumSystemVersion of 10.13 is the Tauri template
  # default, not a tested floor - Tauri 2 needs Catalina or newer. No version
  # is pinned here because every macOS Homebrew itself supports already clears
  # that bar, which is what brew style enforces.
  depends_on :macos

  app "MobaRust.app"

  # Ad-hoc signed without an Apple Developer ID. On current macOS that is not
  # merely a Gatekeeper prompt: the quarantined bundle is judged "damaged" and
  # relocated to the Trash on first launch. Homebrew 7 dropped
  # --no-quarantine, so strip the attribute here instead.
  postflight_steps do
    run "/usr/bin/xattr",
        args: ["-dr", "com.apple.quarantine", "{{appdir}}/MobaRust.app"]
  end

  zap trash: [
    "~/Library/Application Support/com.othmane.mobarust",
    "~/Library/Caches/com.othmane.mobarust",
    "~/Library/Preferences/com.othmane.mobarust.plist",
    "~/Library/Saved Application State/com.othmane.mobarust.savedState",
    "~/Library/WebKit/com.othmane.mobarust",
  ]

  caveats <<~EOS
    This is an upstream preview build: ad-hoc signed and not notarized. The
    cask removes the quarantine attribute after install so macOS will run it;
    notarizing with an Apple Developer ID is upstream's fix to make.

    MobaRust stores SSH credentials in the login Keychain under the service
    "com.othmane.mobarust". `brew uninstall --zap` cannot remove Keychain
    items; delete them in Keychain Access if you want them gone.
  EOS
end
