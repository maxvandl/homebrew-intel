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
| `llvm@23` | 23.1.4  | clang, clang-tools-extra, mlir, polly, compiler-rt, libc++, libunwind. Keg-only, like upstream. Writes clang config files with `-isysroot` and `-B` to the CLT linker so it works under Rosetta. |
| `llvm@22` | 22.1.8  | clang, clang-tools-extra, mlir, polly, compiler-rt, libc++, libunwind. Keg-only, like upstream. Writes clang config files with `-isysroot` and `-B` to the CLT linker so it works under Rosetta. |
| `glib`    | 2.90.1  | With built-in GIRepository/typelibs (introspection enabled), links Intel-brew `gettext` and `pcre2`. Built against the macOS 26 SDK (CLT 27 ships SDK 27, whose weak `pipe2` breaks glib on macOS 26). |
| `cairo`   | 1.18.6  | Quartz, X11/XCB, PNG, PDF/PS/SVG, glib bindings. |
| `harfbuzz`| 15.0.0  | With cairo, freetype, glib/gobject, graphite2, ICU (Intel-brew `icu4c@76`), CoreText and introspection. |
| `openssl@3` | 3.6.5 | no-ssl3, no-zlib, same configure flags as homebrew-core. Shadows core `openssl@3`; certs via `ca-certificates`. |
| `openssl@4` | 4.1.0 | darwin64-x86_64-cc with enable-ec_nistp_64_gcc_128, same configure flags as homebrew-core. Shadows core `openssl@4` (which homebrew-core python now links). Certs via `ca-certificates`. |
| `cmake` | 4.4.5 | Bootstrap build with system zlib/bzip2/curl, same flags as homebrew-core. Shadows core `cmake`. |
| `python@3.15` | 3.15.2 | Framework build with PGO + ThinLTO, links `openssl@4` from this tap. Same patches and install steps as homebrew-core (pip from sdist, `sitecustomize.py`, EXTERNALLY-MANAGED). Provides `python3`. |
| `python@3.14` | 3.14.10 | Same build as `python@3.15`, linked against `openssl@4` with the homebrew-core backport patches. Versioned only (`python3.14`, `pip3.14`, `wheel3.14`); unversioned links in `libexec/bin`. |
| `python@3.12` | 3.12.16 | Same build, linked against `openssl@3` like homebrew-core. Versioned only (`python3.12`, `pip3.12`, `wheel3.12`). |
| `openjdk` | 27.0.1  | Azul Zulu OpenJDK 27.0.1 macOS x64 build, laid out like homebrew-core `openjdk` (`libexec/openjdk.jdk`). No build needed. |
| `node`    | 26.13.0 | Official darwin-x64 binary from nodejs.org, repackaged as a keg (npm included). No build needed. |
| `c-ares` | 1.34.9 | Asynchronous DNS library. |
| `simdjson` | 5.1.1 | SIMD-accelerated C++ JSON parser. |
| `brotli` | 1.2.1 | Generic-purpose lossless compression algorithm by Google. |
| `jpeg-turbo` | 3.2.1 | JPEG image codec that aids compression and decompression. |
| `icu4c@78` | 78.3 | C/C++ and Java libraries for Unicode and globalization. |
| `fribidi` | 1.0.18 | Implementation of the Unicode BiDi algorithm. |
| `z3` | 5.3.3 | High-performance theorem prover. |
| `icu4c@79` | 79.1 | C/C++ and Java libraries for Unicode and globalization. |
| `simdutf` | 9.3.3 | Unicode conversion routines, fast. |
| `openldap` | 2.7.2 | Open source suite of directory software. |
| `imath` | 3.2.3 | Library of 2D and 3D vector, matrix, and math operations. |
| `libdeflate` | 1.26 | Heavily optimized DEFLATE/zlib/gzip compression and decompression. |
| `openjph` | 0.32.0 | Open-source implementation of JPEG2000 Part-15 (or JPH or HTJ2K). |
| `libvmaf` | 3.2.1 | Perceptual video quality assessment based on multi-method fusion. |
| `unixodbc` | 2.3.14 | ODBC 3 connectivity for UNIX. |
| `openexr` | 3.5.3 | High dynamic-range image file format. |
| `krb5` | 1.22.2 | Network authentication protocol. |
| `boost` | 1.92.0 | Collection of portable C++ source libraries. |
| `gobject-introspection` | 1.86.0 | Generate introspection data for GObject libraries. |
| `aom` | 3.15.3 | Codec library for encoding and decoding AV1 video streams. |
| `freetds` | 1.5.20 | Libraries to talk to Microsoft SQL Server and Sybase databases. |
| `m4` | 1.4.21 | Macro processing language. |
| `pkgconf` | 3.0.10 | Package compiler and linker metadata toolkit. |
| `argon2` | 20190702 | Password hashing library and CLI utility. |
| `libsodium` | 1.0.22 | NaCl networking and cryptography library. |
| `json-c` | 0.19 | JSON parser for C. |
| `libssh2` | 1.11.1 | C library implementing the SSH2 protocol. |
| `gmp` | 6.3.0 | GNU multiple precision arithmetic library. |
| `oniguruma` | 6.9.10 | Regular expressions library. |
| `autoconf` | 2.73 | Automatic configure script builder. |
| `libtool` | 2.6.2 | Generic library support script. |
| `libnghttp2` | 1.70.0 | HTTP/2 C Library. |
| `libnghttp3` | 1.18.0 | HTTP/3 library written in C. |
| `libngtcp2` | 1.25.0 | IETF QUIC protocol implementation. |
| `tidy-html5` | 5.8.0 | Granddaddy of HTML tools, with support for modern standards. |
| `libzip` | 1.12.1 | C library for reading, creating, and modifying zip archives. |
| `dav1d` | 1.5.4 | AV1 decoder targeted to be small and fast. |
| `libavif` | 1.4.2 | Library for encoding and decoding .avif files. |

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
tblgen: `llvm` 23.1.4 for `llvm@23`, `llvm@22` 22.1.8 for `llvm@22`), `rustup`
with the `x86_64-apple-darwin` target,
Command Line Tools, Rosetta 2.
