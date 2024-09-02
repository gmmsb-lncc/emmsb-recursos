#!/bin/sh


top=$(pwd)
getdvdl=$top/getdvdl.py

for system in merged_complex; do
  cd $system
  result=0.0

  for step in vdw_bonded_*; do
    cd $step

    python $getdvdl 5 ti001.en [01].* > dvdl.dat
    echo -n "$system/$step: "
    dG=$(tail -n 1 dvdl.dat | awk '{print $4}')
    echo $dG
    result=$(echo $dG + $result | bc)

    cd ..
  done

  echo '--------------------------------'
  echo "dG sum for $system = $result"
  echo

  cd $top
done

