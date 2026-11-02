#!/bin/bash
# gemini-cli как в homebrew-core: npm install --global --build-from-source в libexec, bin -> libexec/bin,
# нативный @github/keytar пересобирается без prebuilds. Используется официальный node darwin-x64
# (той же версии, что формула node этого tap) под Rosetta, node-gyp компилирует arm64 clang'ом с "-arch x86_64".
set -euo pipefail
[ "$(uname -m)" = x86_64 ] || exec arch -x86_64 /bin/bash "$0" "$@"
V=0.66.0; NODEV=26.13.0
R=/Users/lin/llvm; W=$R/gemini-cli
CLT=/Library/Developer/CommandLineTools
K=$W/stage/usr/local/Cellar/gemini-cli/$V
export SDKROOT=$CLT/SDKs/MacOSX26.sdk MACOSX_DEPLOYMENT_TARGET=26.0
export CC="$CLT/usr/bin/clang -arch x86_64" CXX="$CLT/usr/bin/clang++ -arch x86_64"
cd "$W"
[ -d "node-v$NODEV-darwin-x64" ] || { curl -fsLO "https://nodejs.org/dist/v$NODEV/node-v$NODEV-darwin-x64.tar.gz"; tar xzf "node-v$NODEV-darwin-x64.tar.gz"; }
export PATH=$W/node-v$NODEV-darwin-x64/bin:$R/deps/armbin:$CLT/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin
[ -f "gemini-cli-$V.tgz" ] || curl -fsLO "https://registry.npmjs.org/@google/gemini-cli/-/gemini-cli-$V.tgz"
rm -rf "$W/stage"; mkdir -p "$K"
npm install --global --build-from-source --cache="$W/npm-cache" --prefix="$K/libexec" "$W/gemini-cli-$V.tgz"
mkdir -p "$K/bin"; for f in "$K"/libexec/bin/*; do ln -s "../libexec/bin/$(basename "$f")" "$K/bin/"; done
cd "$K/libexec/lib/node_modules/@google/gemini-cli/node_modules/@github/keytar"
rm -rf prebuilds; npm run build
"$R/homebrew-intel/scripts/fix-opt-paths.sh" "$K"
file $(find "$K" -name '*.node' | head -3)
echo "Готово: $K"
