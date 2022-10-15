#!/bin/bash

rundos () {
  flatpak run com.dosbox_x.DOSBox-X -silent -log-con -fastlaunch -time-limit 15 -c "cd leanlib" -c "$1" -exit
}

rundos "build"