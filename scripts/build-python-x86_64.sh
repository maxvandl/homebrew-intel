#!/bin/bash
# Нативная кросс-сборка python@3.X под x86_64 macOS на Apple Silicon.
# usage: build-python-x86_64.sh 3.14.10   (проверено на 3.12-3.15)
# Повторяет install формулы homebrew-core python@3.X (framework-сборка, патчи, ensurepip,
# pip/wheel из sdist, sitecustomize.py, EXTERNALLY-MANAGED). Патчи и ресурсы (pip, wheel,
# flit-core) берутся из `brew cat python@3.X` arm64-brew, так что они всегда как в core.
# Скрипт сам перезапускается под Rosetta (arch -x86_64): configure видит x86_64-хост,
# а собранный python.exe (нужен для сборки stdlib) и так x86_64. Компилятор — arm64 clang
# из CLT с "-arch x86_64". Установка идёт прямо в /usr/local/Cellar/python@3.X/<ver>
# (пост-шаги запускают установленный python), затем keg переносится в stage.
set -euo pipefail
VER=$1
MM=${VER%.*}                                   # 3.14
ROOT=/Users/lin/llvm/python
FORMULA=$ROOT/python@$MM.rb
if [ "$(uname -m)" != x86_64 ]; then
  # arm64 brew под Rosetta не запускаем: формулу core и имя python3 получаем заранее
  mkdir -p "$ROOT"; brew cat "python@$MM" > "$FORMULA"
  PY3=$(brew info --json=v2 python3 | /usr/bin/python3 -c 'import json,sys;print(json.load(sys.stdin)["formulae"][0]["name"])')
  export PY3
  exec arch -x86_64 /bin/bash "$0" "$@"
fi
SRC=$ROOT/Python-$VER
KEG=/usr/local/Cellar/python@$MM/$VER
OPT=/usr/local/opt/python@$MM
FW=$KEG/Frameworks
LIBC=$FW/Python.framework/Versions/$MM/lib/python$MM   # lib_cellar
SP=$KEG/lib/python$MM/site-packages                   # root_site_packages
STAGE=$ROOT/stage-$MM
CLT=/Library/Developer/CommandLineTools; export DEVELOPER_DIR=$CLT
OPENSSL4=/Users/lin/llvm/openssl/stage4/usr/local/Cellar/openssl@4/4.1.0
# различия между версиями берём из формулы core: openssl@3/@4, zstd, tail-call, certifi, sysconfig-патч
SSL=$(grep -oE 'depends_on "openssl@[0-9]+"' "$FORMULA" | grep -oE 'openssl@[0-9]+')
DEPS="mpdecimal $SSL sqlite xz"; grep -q 'depends_on "zstd"' "$FORMULA" && DEPS="$DEPS zstd"
EXTRA=""; grep -q -- '--with-tail-call-interp' "$FORMULA" && EXTRA="--with-tail-call-interp"
SYSCFG=$(grep -oE 'Patches/python/[^"]+' "$FORMULA")
# python3 (не altinstall) — тот, на который в core указывает алиас python3
ALT=1; [ "$PY3" = "python@$MM" ] && ALT=0

export SDKROOT=$CLT/SDKs/MacOSX26.sdk   # не SDK 27: слабые символы ломают результат на macOS 26
export PATH=$CLT/usr/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
export CC="$CLT/usr/bin/clang -arch x86_64" CXX="$CLT/usr/bin/clang++ -arch x86_64"
export MACOSX_DEPLOYMENT_TARGET=26.0
export LLVM_AR=$CLT/usr/bin/ar LLVM_PROFDATA=$CLT/usr/bin/llvm-profdata   # для --with-lto и PGO
export PKG_CONFIG=/opt/homebrew/bin/pkgconf
PCDIRS=""; INC=""; LIBS=""
for d in $DEPS; do PCDIRS="$PCDIRS:/usr/local/opt/$d/lib/pkgconfig"; INC="$INC -I/usr/local/opt/$d/include"; LIBS="$LIBS -L/usr/local/opt/$d/lib"; done
export PKG_CONFIG_LIBDIR="${PCDIRS#:}:/usr/local/Homebrew/Library/Homebrew/os/mac/pkgconfig/26"
unset PYTHONHOME PYTHONPATH

[ -e "$KEG" ] && { echo "ERROR: $KEG уже существует"; exit 1; }
# openssl@4 из этого tap ещё может быть не установлен: на время сборки подставляем staged keg
TMPLINK=""
if [ "$SSL" = openssl@4 ] && [ ! -e /usr/local/opt/openssl@4 ]; then ln -s "$OPENSSL4" /usr/local/opt/openssl@4; TMPLINK=/usr/local/opt/openssl@4; fi
trap '[ -n "$TMPLINK" ] && rm -f "$TMPLINK"' EXIT

cd "$ROOT"
[ -f "Python-$VER.tgz" ] || curl -fLO "https://www.python.org/ftp/python/$VER/Python-$VER.tgz"
rm -rf "$SRC" "$STAGE"; tar xzf "Python-$VER.tgz"
cd "$SRC"

echo "### патчи"
for u in $(grep -oE 'https://github.com/python/cpython/commit/[0-9a-f]+\.patch\?full_index=1' "$FORMULA"); do
  curl -fsL "$u" | patch -p1
done
curl -fsL "https://raw.githubusercontent.com/Homebrew/homebrew-core/main/$SYSCFG" |
  sed 's|@@HOMEBREW_PREFIX@@|/usr/local|g' | patch -p1

sed -i '' 's/libmpdec_machine=universal/libmpdec_machine=x64/' configure
export PYTHON_DECIMAL_WITH_MACHINE=x64
sed -i '' -e "s|DEFAULT_LIBRARY_FALLBACK = \[|DEFAULT_LIBRARY_FALLBACK = [ '/usr/local/lib', '/usr/local/opt/$SSL/lib',|" \
          -e "s|DEFAULT_FRAMEWORK_FALLBACK = \[|DEFAULT_FRAMEWORK_FALLBACK = [ '/usr/local/Frameworks',|" Lib/ctypes/macholib/dyld.py

echo "### configure"
./configure --prefix="$KEG" --enable-ipv6 --datarootdir="$KEG/share" --datadir="$KEG/share" \
  --without-ensurepip --enable-loadable-sqlite-extensions --with-openssl=/usr/local/opt/$SSL \
  --with-system-expat --with-system-libmpdec --with-readline=editline \
  --enable-optimizations --with-lto --enable-framework="$FW" --with-dtrace --with-dbmliborder=ndbm $EXTRA \
  MACOSX_DEPLOYMENT_TARGET=26.0 \
  "CFLAGS_NODIST=${INC# }" \
  "LDFLAGS_NODIST=${LIBS# } -L/usr/local/lib -Wl,-rpath,/usr/local/lib" \
  "CPPFLAGS=${INC# }" \
  py_cv_module__tkinter=n/a
make -j"$(sysctl -n hw.ncpu)"
if [ $ALT = 1 ]; then T=altinstall; else T=install; fi
make $T PYTHONAPPSDIR="$KEG"
make frameworkinstallextras PYTHONAPPSDIR="$KEG/share/python@$MM"

echo "### пост-шаги как в формуле core"
cd "$KEG"
for app in *.app; do [ -e "$app" ] && mv "$app" "${app%.app} 3.app"; done
PC=$FW/Python.framework/Versions/$MM/lib/pkgconfig
mkdir -p lib/pkgconfig
for pc in "$PC"/*; do ln -sf "../../Frameworks/Python.framework/Versions/$MM/lib/pkgconfig/$(basename "$pc")" lib/pkgconfig/; done
for f in "$LIBC/_sysconfigdata__darwin_darwin.py" "$LIBC/_sysconfig_vars__darwin_darwin.json" \
         "$LIBC/config-$MM-darwin/Makefile" "$PC/python-$MM.pc" "$PC/python-$MM-embed.pc"; do
  [ -f "$f" ] && sed -i '' "s|$KEG|$OPT|g" "$f"
done
sed -i '' -E 's/^LINKFORSHARED=(.*)PYTHONFRAMEWORKDIR(.*)/LINKFORSHARED=\1PYTHONFRAMEWORKINSTALLDIR\2/' "$LIBC/config-$MM-darwin/Makefile"
perl -0pi -e "s{('LINKFORSHARED': .*?)( |')(Python.framework/Versions/3.\\d+/Python)'}{\$1\$2$OPT/Frameworks/\$3'}s" "$LIBC/_sysconfigdata__darwin_darwin.py"
[ $ALT = 1 ] && rm -rf "$FW/Python.framework/Headers" "$FW/Python.framework/Python" \
                      "$FW/Python.framework/Resources" "$FW/Python.framework/Versions/Current"
rm -rf "${LIBC:?}/site-packages/"*

PY=$KEG/bin/python$MM
res() { grep -A1 "resource \"$1\"" "$FORMULA" | grep -oE 'https://[^"]+'; }
mkdir -p "$ROOT/res"; WHL=$ROOT/whl_build-$MM; rm -rf "$WHL"
"$PY" -m venv "$WHL"
PIPARGS="-v --no-deps --no-binary :all: --no-index --no-build-isolation"
getres() { local u; u=$(res "$1"); (cd "$ROOT/res" && curl -fsLO "$u"); rm -rf "$ROOT/res/$1"; mkdir "$ROOT/res/$1"; tar xzf "$ROOT/res/$(basename "$u")" -C "$ROOT/res/$1" --strip-components 1; }
HAS_WHEEL=0; res wheel >/dev/null && HAS_WHEEL=1
getres flit-core; (cd "$ROOT/res/flit-core" && "$WHL/bin/pip3" install $PIPARGS .)
mkdir -p "$KEG/libexec"
if [ $HAS_WHEEL = 1 ]; then
  getres wheel
  (cd "$ROOT/res/wheel" && "$WHL/bin/pip3" install $PIPARGS . && "$WHL/bin/pip3" wheel $PIPARGS --wheel-dir="$KEG/libexec" .)
fi
rm -f "$LIBC"/ensurepip/_bundled/pip-*.whl
getres pip; (cd "$ROOT/res/pip" && "$WHL/bin/pip3" wheel $PIPARGS --wheel-dir="$LIBC/ensurepip/_bundled" .)
PIPVER=$(basename "$LIBC"/ensurepip/_bundled/pip-*.whl | sed -E 's/pip-([^-]+)-.*/\1/')
sed -i '' -E "s/_PIP_VERSION = .*/_PIP_VERSION = \"$PIPVER\"/" "$LIBC/ensurepip/__init__.py"
chmod ugo+r "$LIBC"/ensurepip/_bundled/pip-*.whl

mkdir -p libexec/bin
lnk() { ln -sf "../../bin/$2" "libexec/bin/$1"; }
lnk idle "idle$MM"; lnk pydoc "pydoc$MM"; lnk python "python$MM"; lnk python-config "python$MM-config"
if [ $ALT = 1 ]; then lnk idle3 "idle$MM"; lnk pydoc3 "pydoc$MM"; lnk python3 "python$MM"; lnk python3-config "python$MM-config"; fi

"$PY" -Im ensurepip
WHEELS="$LIBC/ensurepip/_bundled/pip-$PIPVER-py3-none-any.whl"
[ $HAS_WHEEL = 1 ] && WHEELS="$WHEELS $(ls "$KEG"/libexec/wheel-*-py3-none-any.whl)"
"$PY" -Im pip install -v --no-deps --no-index --upgrade --isolated --target="$SP" $WHEELS

if grep -q 'certifi = root_site_packages' "$FORMULA"; then
  CERTIFI=$SP/pip/_vendor/certifi
  rm "$CERTIFI/cacert.pem"; ln -s /usr/local/etc/ca-certificates/cert.pem "$CERTIFI/cacert.pem"
fi
mv "$SP"/bin/* bin/; rmdir "$SP/bin"
rm bin/pip; [ $ALT = 1 ] && rm bin/pip3
if [ $HAS_WHEEL = 1 ]; then
  mv bin/wheel "bin/wheel$MM"; [ $ALT = 0 ] && ln -s "wheel$MM" bin/wheel3
  lnk wheel "wheel$MM"; [ $ALT = 1 ] && lnk wheel3 "wheel$MM"
fi
lnk pip "pip$MM"; [ $ALT = 1 ] && lnk pip3 "pip$MM"

rm -rf "$LIBC/site-packages"
ln -s "../../../../../../lib/python$MM/site-packages" "$LIBC/site-packages"

MAJ=${MM%%.*}; MIN=${MM#*.}
cat > "$LIBC/sitecustomize.py" <<PYTHON
# This file is created by Homebrew and is executed on each python startup.
# Don't print from here, or else python command line scripts may fail!
# <https://docs.brew.sh/Homebrew-and-Python>
import os
import site
import sys
if sys.version_info[:2] != ($MAJ, $MIN):
    # This can only happen if the user has set the PYTHONPATH to a mismatching site-packages directory.
    # Every Python looks at the PYTHONPATH variable and we can't fix it here in sitecustomize.py,
    # because the PYTHONPATH is evaluated after the sitecustomize.py. Many modules (e.g. PyQt4) are
    # built only for a specific version of Python and will fail with cryptic error messages.
    # In the end this means: Don't set the PYTHONPATH permanently if you use different Python versions.
    exit(f'Your PYTHONPATH points to a site-packages dir for Python $MM '
         f'but you are running Python {sys.version_info[0]}.{sys.version_info[1]}!\\n'
         f'     PYTHONPATH is currently: "{os.environ["PYTHONPATH"]}"\\n'
         f'     You should \`unset PYTHONPATH\` to fix this.')
# Only do this for a brewed python:
if os.path.realpath(sys.executable).startswith('/usr/local/Cellar/python@$MM'):
    # the Cellar site-packages is a symlink to the HOMEBREW_PREFIX
    # site_packages; prefer the shorter paths
    sys.path = [p.replace('$LIBC/site-packages', '/usr/local/lib/python$MM/site-packages') for p in sys.path]
    # Set the sys.executable to use the opt_prefix. Only do this if PYTHONEXECUTABLE is not
    # explicitly set and we are not in a virtualenv:
    if 'PYTHONEXECUTABLE' not in os.environ and sys.prefix == sys.base_prefix:
        sys.executable = sys._base_executable = '$OPT/bin/python$MM'
if 'PYTHONHOME' not in os.environ:
    if os.path.realpath(sys.base_prefix).startswith('/usr/local/Cellar/python@$MM'):
        new_prefix = sys.base_prefix.replace('$KEG', '$OPT')
        site.PREFIXES[:] = [new_prefix if x == sys.base_prefix else x for x in site.PREFIXES]
        if sys.prefix == sys.base_prefix:
            sys.prefix = new_prefix
        sys.base_prefix = new_prefix
    if os.path.realpath(sys.base_exec_prefix).startswith('/usr/local/Cellar/python@$MM'):
        new_exec_prefix = sys.base_exec_prefix.replace('$KEG', '$OPT')
        site.PREFIXES[:] = [new_exec_prefix if x == sys.base_exec_prefix else x for x in site.PREFIXES]
        if sys.exec_prefix == sys.base_exec_prefix:
            sys.exec_prefix = new_exec_prefix
        sys.base_exec_prefix = new_exec_prefix
# Make site.getsitepackages() return the HOMEBREW_PREFIX site-packages,
# but only if we are outside a venv or in one with include-system-site-packages.
if sys.base_prefix in site.PREFIXES:
    site.PREFIXES.insert(site.PREFIXES.index(sys.base_prefix), '/usr/local')
    site.addsitedir('/usr/local/lib/python$MM/site-packages')
# Check for and add the prefix of split Python formulae.
for split_module in ["tk", "gdbm"]:
    split_prefix = f"/usr/local/opt/python-{split_module}@$MM/libexec"
    if os.path.isdir(split_prefix):
        sys.path.append(split_prefix)
PYTHON

# текст EXTERNALLY-MANAGED дословно из формулы core
sed -n '/EXTERNALLY-MANAGED").write <<~INI/,/^    INI$/p' "$FORMULA" | sed -e '1d' -e '$d' -e 's/^      //' > "$LIBC/EXTERNALLY-MANAGED"

echo "### проверка"
"$PY" -c 'import sqlite3, _ctypes, _decimal, pyexpat, readline, zlib, ssl, lzma; print(ssl.OPENSSL_VERSION)'

cd /; mkdir -p "$STAGE/usr/local/Cellar/python@$MM"
mv "$KEG" "$STAGE/usr/local/Cellar/python@$MM/"
rmdir "/usr/local/Cellar/python@$MM" 2>/dev/null || true
/Users/lin/llvm/homebrew-intel/scripts/fix-opt-paths.sh "$STAGE$KEG"
echo "Готово: $STAGE$KEG"
