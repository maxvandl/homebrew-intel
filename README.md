# homebrew-intel

Prebuilt **x86_64 macOS** kegs for formulae that Homebrew no longer ships Intel
bottles for. Built on Apple Silicon by native cross-compilation (arm64 host
compiler, `-arch x86_64`), so no multi-hour Rosetta source builds.

Intended for the Intel Homebrew in `/usr/local` (natively on an Intel Mac, or
under Rosetta on Apple Silicon).

## Usage

```bash
arch -x86_64 /usr/local/bin/brew tap maxvandl/intel
arch -x86_64 /usr/local/bin/brew install maxvandl/intel/llvm@22
arch -x86_64 /usr/local/bin/brew install maxvandl/intel/node
```

On an Intel Mac drop the `arch -x86_64` prefix.

## Formulae

| Formula   | Version | Notes |
|-----------|---------|-------|
| `llvm@22` | 22.1.8  | clang, clang-tools-extra, mlir, polly, compiler-rt, libc++, libunwind. Keg-only, like upstream. Writes clang config files with `-isysroot` and `-B` to the CLT linker so it works under Rosetta. |
| `glib`    | 2.90.0  | With built-in GIRepository/typelibs (introspection enabled), links Intel-brew `gettext` and `pcre2`. Built against the macOS 26 SDK (CLT 27 ships SDK 27, whose weak `pipe2` breaks glib on macOS 26). |
| `cairo`   | 1.18.4  | Quartz, X11/XCB, PNG, PDF/PS/SVG, glib bindings. |
| `harfbuzz`| 14.4.0  | With cairo, freetype, glib/gobject, graphite2, ICU (Intel-brew `icu4c@76`), CoreText and introspection. |
| `node`    | 26.8.2  | Bundled openssl/icu/libuv (like nodejs.org binaries) instead of 18 shared Homebrew libs. npm 11.19.1 included. |

## Rebuilding

`scripts/build-llvm-x86_64.sh`, `scripts/build-node-x86_64.sh`, `scripts/build-glib-x86_64.sh` and the
generic `scripts/build-meson-x86_64.sh` (cairo, harfbuzz) produce a
staged Cellar tree, which is then tarred and attached to a GitHub Release.
Requirements on the build machine: arm64 Homebrew with `cmake`, `ninja`,
`llvm@22` (for native tblgen), `rustup` with the `x86_64-apple-darwin` target,
Command Line Tools, Rosetta 2.
