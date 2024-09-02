#!/bin/sh
#
# Setup for the free energy simulations: creates and links to the input file as
# necessary.  Two alternative for the de- and recharging step can be used.
#


. ./windows

# partial removal/addition of charges: softcore atoms only
decharge_crg=":2"

decharge=" ifsc = 0, crgmask = '$decharge_crg',"

basedir=../setup
top=$(pwd)
setup_dir=$(cd "$basedir"; pwd)

for system in ligand; do
  if [ \! -d $system ]; then
    mkdir $system
  fi

  cd $system

  for step in decharge; do
    if [ \! -d $step ]; then
      mkdir $step
    fi

    cd $step

    for w in $windows; do
      if [ \! -d $w ]; then
        mkdir $w
      fi

      FE=$(eval "echo \${$step}")
      sed -e "s/%L%/$w/" -e "s/%FE%/$FE/" $top/min_ligand.tmpl > $w/min.in
      sed -e "s/%L%/$w/" -e "s/%FE%/$FE/" $top/heat_ligand.tmpl > $w/heat.in
      sed -e "s/%L%/$w/" -e "s/%FE%/$FE/" $top/eqnpt_ligand.tmpl > $w/eqnpt.in
      sed -e "s/%L%/$w/" -e "s/%FE%/$FE/" $top/prod_ligand.tmpl > $w/ti.in

      (
        cd $w
        ln -sf $setup_dir/bnz_dech.parm7 ti.parm7
        ln -sf $setup_dir/bnz_dech.rst7  ti.rst7
      )
    done

    cd ..
  done

  cd $top
done

