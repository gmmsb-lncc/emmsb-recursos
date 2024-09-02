#!/bin/sh
#
# Setup for the free energy simulations: creates and links to the input file as
# necessary.  Two alternative for the de- and recharging step can be used.
#


. ./windows

# complete removal/addition of charges
vdw_crg=":99 | :163"

vdw=" ifsc=1, scmask1=':99@CB,HB1,HB2,HB3', scmask2=':163@CB,HB,CG1,HG11,HG12,HG13,CG2,HG21,HG22,HG23', crgmask='$vdw_crg'"

basedir=../setup
top=$(pwd)
setup_dir=$(cd "$basedir"; pwd)

for system in complex; do
  if [ \! -d $system ]; then
    mkdir $system
  fi

  cd $system

  for step in vdw; do
    if [ \! -d $step ]; then
      mkdir $step
    fi

    cd $step

    for w in $windows; do
      if [ \! -d $w ]; then
        mkdir $w
      fi

      FE=$(eval "echo \${$step}")
      sed -e "s/%L%/$w/" -e "s/%FE%/$FE/" $top/min_complex.tmpl > $w/min.in
      sed -e "s/%L%/$w/" -e "s/%FE%/$FE/" $top/heat_complex.tmpl > $w/heat.in
      sed -e "s/%L%/$w/" -e "s/%FE%/$FE/" $top/eqnpt_complex.tmpl > $w/eqnpt.in
      sed -e "s/%L%/$w/" -e "s/%FE%/$FE/" $top/prod_complex.tmpl > $w/ti.in

      (
        cd $w
        ln -sf $setup_dir/merged_lyz_mlz_bnz_vdw.parm7 ti.parm7
        ln -sf $setup_dir/merged_lyz_mlz_bnz_vdw.rst7  ti.rst7
      )
    done

    cd ..
  done

  cd $top
done

