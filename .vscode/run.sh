#!/bin/bash

rundos () {
  flatpak run com.dosbox_x.DOSBox-X -nolog -nomenu -fastlaunch -c "cd leanlib" -c "$1" -exit
}

dospath=`echo $2 | tr / \\`
filename=$1
echo Running $filename at $dospath
rundos "run $dospath $filename"