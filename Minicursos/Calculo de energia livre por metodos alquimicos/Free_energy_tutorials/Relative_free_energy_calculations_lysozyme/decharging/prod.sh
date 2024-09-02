#!/bin/bash
#windows=`echo "0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.47 0.50 0.53 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.92 0.94 0.95 0.97 0.99 1.00"`
windows=`echo "0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.47 0.50 0.53"`
for i in $windows
do
cd $i
export AMBERHOME=~/sortware/amber18
source ~/software/amber18/amber.sh

export CUDA_VISIBLE_DEVICES=0

pmemd.cuda -i heat.in -c ti.rst7 -ref ti.rst7 -p ti.parm7 -O -o heat.out -inf heat.info -e heat.en -r heat.rst7 -x heat.nc -l heat.log
pmemd.cuda -i eqnpt.in -c heat.rst7 -ref ti.rst7 -p ti.parm7 -O -o eqnpt.out -inf eqnpt.info -e eqnpt.en -r eqnpt.rst7 -x eqnpt.nc -l eqnpt.log
pmemd.cuda -i ti.in -c eqnpt.rst7 -p ti.parm7 -O -o ti001.out -inf ti001.info -e ti001.en -r ti001.rst7 -x ti001.nc -l ti001.log
cd ../
done
