# homebrew-intel

Prebuilt **x86_64 macOS** kegs for formulae that Homebrew no longer ships Intel
bottles for. Built on Apple Silicon by native cross-compilation (arm64 host
compiler, `-arch x86_64`), so no multi-hour Rosetta source builds.

Intended for the Intel Homebrew in `/usr/local` (natively on an Intel Mac, or
under Rosetta on Apple Silicon).

## Usage

```bash
arch -x86_64 /usr/local/bin/brew tap maxvandl/intel
arch -x86_64 /usr/local/bin/brew install maxvandl/intel/llvm@23
arch -x86_64 /usr/local/bin/brew install maxvandl/intel/node
```

On an Intel Mac drop the `arch -x86_64` prefix.

## Formulae

| Formula   | Version | Notes |
|-----------|---------|-------|
| `llvm@23` | 23.1.1  | clang, clang-tools-extra, mlir, polly, compiler-rt, libc++, libunwind. Keg-only, like upstream. Writes clang config files with `-isysroot` and `-B` to the CLT linker so it works under Rosetta. |
| `llvm@22` | 22.1.8  | clang, clang-tools-extra, mlir, polly, compiler-rt, libc++, libunwind. Keg-only, like upstream. Writes clang config files with `-isysroot` and `-B` to the CLT linker so it works under Rosetta. |
| `glib`    | 2.90.0  | With built-in GIRepository/typelibs (introspection enabled), links Intel-brew `gettext` and `pcre2`. Built against the macOS 26 SDK (CLT 27 ships SDK 27, whose weak `pipe2` breaks glib on macOS 26). |
| `cairo`   | 1.18.4  | Quartz, X11/XCB, PNG, PDF/PS/SVG, glib bindings. |
| `harfbuzz`| 14.4.0  | With cairo, freetype, glib/gobject, graphite2, ICU (Intel-brew `icu4c@76`), CoreText and introspection. |
| `openjdk` | 27      | Azul Zulu OpenJDK 27.0.0 macOS x64 build, laid out like homebrew-core `openjdk` (`libexec/openjdk.jdk`). No build needed. |
| `node`    | 26.9.0  | Official darwin-x64 binary from nodejs.org, repackaged as a keg (npm included). No build needed. |

## Casks

Unlike the formulae above, these are app bundles and are installed with the
**arm64** Homebrew in `/opt/homebrew` (the cask picks the matching slice):

```bash
brew tap maxvandl/intel
brew install --cask maxvandl/intel/psi-plus
brew install --cask maxvandl/intel/mobarust
```

| Cask       | Version   | Notes |
|------------|-----------|-------|
| `psi-plus` | 1.5.2182  | Psi+ XMPP client, built from `psi-plus/psi-plus-snapshots`. Separate arm64 and x86_64 disk images, selected via `on_arm`/`on_intel`. The arm64 build links Qt 6.11.2 from `/opt/homebrew`; the x86_64 build links Qt 6.7.3 from `/usr/local`, since Homebrew ships no x86_64 bottle of Qt 6.11.2 for macOS 27. Ad-hoc signed and **not notarized**, so Gatekeeper blocks the first launch (the reason homebrew-cask disabled its own `psi-plus` on 2026-09-01). |
| `mobarust` | 0.1.1     | MobaRust SSH/SFTP terminal workspace, a free MobaXterm alternative. Unlike `psi-plus`, nothing is built here: upstream `OthmaneBlial/MobaRust` already publishes arm64 and x86_64 disk images, so the cask points straight at them. Upstream ships it ad-hoc signed and **not notarized**, and tags the release a GitHub pre-release, so `brew audit --online` reports one expected pre-release finding. |

## Rebuilding

`node` and `openjdk` need no build: bump `version`/`sha256` in the formula from nodejs.org.

`scripts/build-llvm23-x86_64.sh`, `scripts/build-llvm-x86_64.sh`,
`scripts/build-glib-x86_64.sh` and the
generic `scripts/build-meson-x86_64.sh` (cairo, harfbuzz) produce a
staged Cellar tree, which is then tarred and attached to a GitHub Release.
Requirements on the build machine: arm64 Homebrew with `cmake`, `ninja`,
an arm64 `llvm` of the **same version** as the sources being built (for native
tblgen: `llvm` 23.1.1 for `llvm@23`, `llvm@22` 22.1.8 for `llvm@22`), `rustup`
with the `x86_64-apple-darwin` target,
Command Line Tools, Rosetta 2.
