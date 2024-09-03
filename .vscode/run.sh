#!/bin/bash

run_macos () {
  /Applications/dosbox-x.app/Contents/MacOS/DosBox -fastlaunch -conf "$1/.vscode/build.conf" -c "\run $2 $3" -exit
}

run_flatpak () {
  flatpak run com.dosbox_x.DOSBox-X -nomenu -fastlaunch -conf "$1/.vscode/build.conf" -c "\run $2 $3" -exit
}

rundos () {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    run_flatpak $@ 
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    run_macos $@
  fi
}

projectroot=$1
filename=$2
dospath=$(echo $3 | tr / \\)
echo Running $filename at $dospath
rundos $projectroot $dospath $filename