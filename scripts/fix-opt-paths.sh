#!/bin/bash
# Переписывает в Mach-O файлах keg'а абсолютные пути /usr/local/Cellar/<формула>/<версия>/...
# на /usr/local/opt/<формула>/..., как это делает Homebrew для бутылок.
# Без этого keg, собранный против glib 2.90.0, ломается после обновления glib и brew cleanup
# (Homebrew сам абсолютные пути при установке не трогает).
# usage: fix-opt-paths.sh <stage-keg-dir>   (например stage/usr/local/Cellar/cairo/1.18.6)
set -euo pipefail
KEG=$1
CLT=/Library/Developer/CommandLineTools; export DEVELOPER_DIR=$CLT  # не xcode-select -p: при установленном Xcode там нет ld и SDKs

INT=$CLT/usr/bin/install_name_tool
CELLAR=/usr/local/Cellar
re="^$CELLAR/([^/]+)/[^/]+/(.*)$"

find "$KEG" -type f \( -perm -u+x -o -name '*.dylib' -o -name '*.so' -o -name '*.bundle' \) | while read -r f; do
  file -b "$f" | grep -q Mach-O || continue
  id=$(otool -D "$f" | sed -n 2p)
  if [[ $id =~ $re ]]; then
    $INT -id "/usr/local/opt/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}" "$f" 2>/dev/null
  fi
  otool -L "$f" | tail -n +2 | awk '{print $1}' | while read -r dep; do
    [[ $dep =~ $re ]] || continue
    $INT -change "$dep" "/usr/local/opt/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}" "$f" 2>/dev/null
  done
  for rp in $(otool -l "$f" | awk '/cmd LC_RPATH/{getline; getline; print $2}'); do
    [[ $rp =~ $re ]] || continue
    $INT -rpath "$rp" "/usr/local/opt/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}" "$f" 2>/dev/null || true
  done
  codesign -f -s - "$f" 2>/dev/null || true
done
echo "fix-opt-paths: $KEG"
otool -L $(find "$KEG" -name '*.dylib' -type f) 2>/dev/null | grep -c "^[[:space:]]$CELLAR" | sed 's/^/оставшихся ссылок на Cellar: /' || true
