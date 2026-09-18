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
| `node`    | 26.8.2  | Bundled openssl/icu/libuv (like nodejs.org binaries) instead of 18 shared Homebrew libs. npm 11.19.1 included. |

## Rebuilding

`scripts/build-llvm-x86_64.sh` and `scripts/build-node-x86_64.sh` produce a
staged Cellar tree, which is then tarred and attached to a GitHub Release.
Requirements on the build machine: arm64 Homebrew with `cmake`, `ninja`,
`llvm@22` (for native tblgen), `rustup` with the `x86_64-apple-darwin` target,
Command Line Tools, Rosetta 2.
