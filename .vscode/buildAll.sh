#!/bin/bash

run_macos () {
  /Applications/dosbox-x.app/Contents/MacOS/DosBox -silent -log-con -fastlaunch -time-limit 15 -c "$2" -conf "$1/.vscode/build.conf" -exit
}
 
run_flatpak () {
  flatpak run com.dosbox_x.DOSBox-X -silent -log-con -fastlaunch -time-limit 15 -c "$2" -conf "$1/.vscode/build.conf" -exit
}

rundos () {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    run_flatpak "$@" 
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    run_macos "$@"
  fi
}

rundos $1 "build"