#!/bin/bash

rundos () {
  flatpak run com.dosbox_x.DOSBox-X -silent -log-con -fastlaunch -c "cd leanlib" -c "$1" -exit
}

echo Parameter: %1
rundos "build"