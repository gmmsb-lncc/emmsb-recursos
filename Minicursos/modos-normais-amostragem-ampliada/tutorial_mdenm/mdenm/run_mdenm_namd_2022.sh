#!/bin/bash

#################################################################
# run MDeNM simulations with NAMD
# by Mauricio Costa 
#################################################################

beg=1
tot=100
# total number of simulation replicas 
echo "How many replicas ? "
echo $tot
#read tot

a=`echo $PWD`

for i in `seq ${beg} ${tot}`
do

cd ${a}	
rm -rf ${i} # remove previous folder with same name
mkdir ${i}

cp  mdexciter_namd_nm.R ./${i}
cp inputs.R ./${i}
cp config.namd ./${i}

cd ${i}
R -f mdexciter_namd_nm.R
cd ${a}
done
