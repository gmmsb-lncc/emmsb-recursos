#!/bin/bash

pmemd.cuda -i min1.in -o em1.out -ref *ions.rst7 -c *ions.rst7 -p *parm7 -r min1.rst7 -O

pmemd.cuda -i min-all.in -o min-all.out -O -ref min1.rst7 -c min1.rst7 -p *parm7 -r min-all.rst7

pmemd.cuda -i heat.in -o heat.out -O -ref min-all.rst7 -c min-all.rst7 -p *parm7 -r heat.rst7 -x heat.mdcrd

pmemd.cuda -i eqnpt.in -o eqnpt.out -O -ref heat.rst7 -c heat.rst7 -p *parm7 -r eqnpt.rst7 -x eqnpt.mdcrd

ln -s eqnpt.rst7 eq_2.rst7
for i in $(seq 4 2 8)
do
k=$(($i-2)) <<EOF
EOF

j=$((-1*$i+10)) <<EOF
EOF
  
echo "equil NTP 0.5ns
 heat
 &cntrl
  imin=0,irest=1,ntx=5,
  nstlim=50000,dt=0.002,
  ntc=2,ntf=2,
  cut=10.0, ntb=2, ntp=1, taup=1.0,
  ntpr=10000, ntwx=10000,ntwr=10000,
  ntt=3, gamma_ln=2.0,
  temp0=300.0,iwrap=1,
  ntr=1, restraintmask=':1-163&!(@H=)',
  restraint_wt=$j,
 /
 /">>eq_$i.in

pmemd.cuda -i eq_$i.in -o eq_$i.out  -ref eq_$k.rst7 -c eq_$k.rst7 -p *parm7 -x eq_$i.mdcrd -r eq_$i.rst7 -O
done

pmemd.cuda -i md10ns.in -o md10ns.out -O -ref eq_8.rst7 -c eq_8.rst7 -p *parm7 -x md10ns.nc -r md10ns.rst7 
