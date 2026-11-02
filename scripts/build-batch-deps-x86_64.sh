#!/bin/bash
# Сборка библиотек-зависимостей openexr/aom/freetds (imath, libdeflate, openjph, libvmaf, unixodbc)
# через общие build-cmakeproj/build-meson/build-autotools скрипты; аргументы как у homebrew-core.
set -uo pipefail
R=/Users/lin/llvm; S=$R/homebrew-intel/scripts
get() { mkdir -p $R/$1/src; cd $R/$1; [ -f "$(basename $2)" ] || curl -sfLO "$2"; rm -rf src/*; tar xf "$(basename $2)" -C src --strip-components 1; cd $R; }
for x in "$@"; do case $x in
imath) get imath https://github.com/AcademySoftwareFoundation/Imath/archive/refs/tags/v3.2.3.tar.gz
  $S/build-cmakeproj-x86_64.sh imath 3.2.3 $R/imath/src > $R/imath/build.log 2>&1; echo "imath $?" ;;
libdeflate) get libdeflate https://github.com/ebiggers/libdeflate/archive/refs/tags/v1.26.tar.gz
  $S/build-cmakeproj-x86_64.sh libdeflate 1.26 $R/libdeflate/src > $R/libdeflate/build.log 2>&1; echo "libdeflate $?" ;;
openjph) get openjph https://github.com/aous72/OpenJPH/archive/refs/tags/0.32.0.tar.gz
  DEPS=libtiff $S/build-cmakeproj-x86_64.sh openjph 0.32.0 $R/openjph/src -DCMAKE_INSTALL_RPATH=@loader_path/../lib > $R/openjph/build.log 2>&1; echo "openjph $?" ;;
libvmaf) get libvmaf https://github.com/Netflix/vmaf/archive/refs/tags/v3.2.1.tar.gz
  $S/build-meson-x86_64.sh libvmaf 3.2.1 $R/libvmaf/src/libvmaf > $R/libvmaf/build.log 2>&1; r=$?
  mkdir -p $R/libvmaf/stage/usr/local/Cellar/libvmaf/3.2.1/share/libvmaf && cp -R $R/libvmaf/src/model $R/libvmaf/stage/usr/local/Cellar/libvmaf/3.2.1/share/libvmaf/
  $S/fix-opt-paths.sh $R/libvmaf/stage/usr/local/Cellar/libvmaf/3.2.1 >/dev/null; echo "libvmaf $r" ;;
unixodbc) get unixodbc https://www.unixodbc.org/unixODBC-2.3.14.tar.gz
  DEPS=libtool $S/build-autotools-x86_64.sh unixodbc 2.3.14 $R/unixodbc/src --sysconfdir=/usr/local/etc --enable-static --enable-gui=no > $R/unixodbc/build.log 2>&1; echo "unixodbc $?" ;;
esac; done
