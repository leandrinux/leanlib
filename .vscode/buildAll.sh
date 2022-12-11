#!/bin/bash

run_macos() {
  /Applications/dosbox-x.app/Contents/MacOS/DosBox -silent -log-con -fastlaunch -time-limit 15 -c "cd leanlib" -c "$1" -exit
}

run_flatpak () {
  flatpak run com.dosbox_x.DOSBox-X -silent -log-con -fastlaunch -time-limit 15 -c "cd leanlib" -c "$1" -exit
}

rundos () {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    run_flatpak "$@" 
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    run_macos "$@"
  fi
}

rundos "build"