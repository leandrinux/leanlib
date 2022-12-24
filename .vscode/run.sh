#!/bin/bash

run_macos () {
  /Applications/dosbox-x.app/Contents/MacOS/DosBox -fastlaunch -c "cd leanlib" -c "$1" -exit
}

run_flatpak () {
  flatpak run com.dosbox_x.DOSBox-X -nomenu -fastlaunch -c "cd leanlib" -c "$1" -exit
}

rundos () {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    run_flatpak "$@" 
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    run_macos "$@"
  fi
}

echo arg $2
dospath=$(echo $2 | tr / \\)
filename=$1
echo Running $filename at $dospath
rundos "run $dospath $filename"