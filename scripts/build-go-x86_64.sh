#!/bin/bash
# Кросс-сборка Go-формул под x86_64 macOS на Apple Silicon (arm64 go, GOARCH=amd64, cgo через
# arm64 clang из CLT с "-arch x86_64"). Аргументы как у std_go_args Homebrew: -trimpath, -ldflags "-s -w ...".
# Автодополнения генерируются запуском готового x86_64-бинарника (под Rosetta), как
# generate_completions_from_executable. usage: build-go-x86_64.sh name [name...]
set -uo pipefail
R=/Users/lin/llvm
CLT=/Library/Developer/CommandLineTools
export GOOS=darwin GOARCH=amd64 CGO_ENABLED=1
export CC="$CLT/usr/bin/clang -arch x86_64" CXX="$CLT/usr/bin/clang++ -arch x86_64"
export SDKROOT=$CLT/SDKs/MacOSX26.sdk MACOSX_DEPLOYMENT_TARGET=26.0
# icu4c@79 нужен dolt/beads/gascity (go-icu-regex)
export CGO_CFLAGS="-I/usr/local/opt/icu4c@79/include" CGO_CXXFLAGS="-I/usr/local/opt/icu4c@79/include"
export CGO_LDFLAGS="-Wl,-headerpad_max_install_names -L/usr/local/opt/icu4c@79/lib"
export PATH=$CLT/usr/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
get() { mkdir -p "$R/$1"; cd "$R/$1"; [ -f "$(basename "$2")" ] || curl -sfLO "$2"; rm -rf src; mkdir src; tar xf "$(basename "$2")" -C src --strip-components 1; cd src; }
gob() { local out=$1 ld=$2; shift 2; go build -trimpath -o "$out" -ldflags "-s -w $ld" "$@"; }
# completions: cobra (completion bash|zsh|fish) или другая команда
comp() { local k=$1 exe=$2 name=$3; shift 3; local sub=${*:-completion}
  mkdir -p "$k/etc/bash_completion.d" "$k/share/zsh/site-functions" "$k/share/fish/vendor_completions.d"
  "$exe" $sub bash > "$k/etc/bash_completion.d/$name" 2>/dev/null || rm -f "$k/etc/bash_completion.d/$name"
  "$exe" $sub zsh > "$k/share/zsh/site-functions/_$name" 2>/dev/null || rm -f "$k/share/zsh/site-functions/_$name"
  "$exe" $sub fish > "$k/share/fish/vendor_completions.d/$name.fish" 2>/dev/null || rm -f "$k/share/fish/vendor_completions.d/$name.fish"; }
K() { echo "$R/$1/stage/usr/local/Cellar/$1/$2"; }
for x in "$@"; do L=$R/$x/build.log; mkdir -p $R/$x; (set -e; case $x in
doctl) V=2.1.0; get doctl https://github.com/digitalocean/doctl/archive/refs/tags/v$V.tar.gz; k=$(K doctl $V); rm -rf $R/doctl/stage; mkdir -p $k/bin
  gob $k/bin/doctl "-X github.com/digitalocean/doctl.Major=2 -X github.com/digitalocean/doctl.Minor=1 -X github.com/digitalocean/doctl.Patch=0 -X github.com/digitalocean/doctl.Label=release" ./cmd/doctl
  comp $k $k/bin/doctl doctl ;;
gogcli) V=0.47.1; get gogcli https://github.com/openclaw/gogcli/archive/refs/tags/v$V.tar.gz; k=$(K gogcli $V); rm -rf $R/gogcli/stage; mkdir -p $k/bin
  gob $k/bin/gog "-X github.com/steipete/gogcli/internal/cmd.version=$V -X github.com/steipete/gogcli/internal/cmd.commit=maxvandl -X github.com/steipete/gogcli/internal/cmd.date=$NOW" ./cmd/gog
  comp $k $k/bin/gog gog ;;
aws-iam-authenticator) V=0.7.24; get aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/archive/refs/tags/v$V.tar.gz; k=$(K aws-iam-authenticator $V); rm -rf $R/aws-iam-authenticator/stage; mkdir -p $k/bin
  gob $k/bin/aws-iam-authenticator "-X sigs.k8s.io/aws-iam-authenticator/pkg.Version=$V -X sigs.k8s.io/aws-iam-authenticator/pkg.CommitID=maxvandl -buildid=" ./cmd/aws-iam-authenticator
  comp $k $k/bin/aws-iam-authenticator aws-iam-authenticator ;;
gascity) V=1.5.1; get gascity https://github.com/gastownhall/gascity/archive/refs/tags/v$V.tar.gz; k=$(K gascity $V); rm -rf $R/gascity/stage; mkdir -p $k/bin
  gob $k/bin/gc "-X main.version=$V" ./cmd/gc ;;
beads) V=1.3.2; get beads https://github.com/gastownhall/beads/archive/refs/tags/v$V.tar.gz; k=$(K beads $V); rm -rf $R/beads/stage; mkdir -p $k/bin
  gob $k/bin/beads "-X main.Version=$V -X main.Build=maxvandl -X main.Branch=v$V" ./cmd/bd
  ln -sf beads $k/bin/bd; comp $k $k/bin/bd bd ;;
dolt) V=2.6.2; get dolt https://github.com/dolthub/dolt/archive/refs/tags/v$V.tar.gz; k=$(K dolt $V); rm -rf $R/dolt/stage; mkdir -p $k/bin
  (cd go && gob $k/bin/dolt "" ./cmd/dolt); mkdir -p $k/etc_dist/dolt; touch $k/etc_dist/dolt/config.yaml ;;
mole) V=1.67.0; get mole https://github.com/tw93/Mole/archive/refs/tags/V$V.tar.gz; k=$(K mole $V); rm -rf $R/mole/stage; mkdir -p $k/libexec $k/bin
  rm -f bin/*-go; for c in analyze status; do gob bin/$c-go "-X main.Version=$V -X main.BuildTime=$NOW" ./cmd/$c; done
  cp -R mole bin lib $k/libexec/; ln -sf ../libexec/mole $k/bin/mole; ln -sf mole $k/bin/mo
  comp $k $k/libexec/mole mole completion ;;
act) V=0.2.94; get act https://github.com/nektos/act/archive/refs/tags/v$V.tar.gz; k=$(K act $V); rm -rf $R/act/stage; mkdir -p $k/bin
  make build VERSION=$V; install -m 755 dist/local/act $k/bin/act; comp $k $k/bin/act act ;;
vacuum) V=0.36.2; get vacuum https://github.com/daveshanley/vacuum/archive/refs/tags/v$V.tar.gz; k=$(K vacuum $V); rm -rf $R/vacuum/stage; mkdir -p $k/bin
  (cd html-report/ui && npm install && npm run build)
  go build -trimpath -tags html_report_ui -o $k/bin/vacuum -ldflags "-s -w -X main.version=$V -X main.commit=maxvandl -X main.date=$NOW"
  comp $k $k/bin/vacuum vacuum ;;
kubernetes-cli) V=1.37.2; mkdir -p $R/kubernetes-cli; cd $R/kubernetes-cli; rm -rf src stage
  git clone -q --depth 1 --branch v$V https://github.com/kubernetes/kubernetes.git src; cd src
  [ "$(git rev-parse HEAD)" = c50e5395f1ae2d4a2c05f28fdcc38c0916cc1a32 ]
  k=$(K kubernetes-cli $V); mkdir -p $k/bin $k/share/man/man1
  PATH=/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH FORCE_HOST_GO=1 KUBE_BUILD_PLATFORMS=darwin/amd64 make WHAT=cmd/kubectl
  install -m 755 _output/local/bin/darwin/amd64/kubectl $k/bin/ 2>/dev/null || install -m 755 _output/bin/kubectl $k/bin/
  comp $k $k/bin/kubectl kubectl
  PATH=/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH GOARCH=arm64 CGO_ENABLED=0 hack/update-generated-docs.sh
  cp docs/man/man1/*.1 $k/share/man/man1/ ;;
*) echo "unknown $x"; exit 1 ;;
esac) > $L 2>&1; r=$?
  k=$(ls -d $R/$x/stage/usr/local/Cellar/$x/* 2>/dev/null | tail -1); [ -n "$k" ] && $R/homebrew-intel/scripts/fix-opt-paths.sh $k >> $L 2>&1
  echo "$x $r"; done
