!/bin/bash

echo "parm $1.parm7
trajin $1.rst7 
distance d1 :$2@$3 :$6@CA out dist.dat
go" >dist.in 

echo "parm $1.parm7
trajin $1.rst7 
angle a1 :$7@CA :$6@CA :$2@$3 out angle.dat
angle a2 :$6@CA :$2@$3 :$2@$4 out angle.dat
go" > angles.in

echo "parm $1.parm7
trajin $1.rst7
dihedral d1 :$8@CA :$7@CA :$6@CA :$2@$3 out dihedral.dat
dihedral d2 :$7@CA :$6@CA :$2@$3 :$2@$4 out dihedral.dat
dihedral d3 :$6@CA :$2@$3 :$2@$4 :$2@$5 out dihedral.dat
go" > dihedral.in


cpptraj -i dist.in
cpptraj -i angles.in
cpptraj -i dihedral.in

a=`grep ' '$2' ' $1.pdb | grep ' '$3' ' | awk '{ print $2 } '`
b=`grep ' '$2' ' $1.pdb | grep ' '$4' ' | awk '{ print $2 } '`
c=`grep ' '$2' ' $1.pdb | grep ' '$5' ' | awk '{ print $2 } '`
d=`grep ' '$6' ' $1.pdb | grep ' CA ' | awk '{ print $2 } '`
e=`grep ' '$7' ' $1.pdb | grep ' CA ' | awk '{ print $2 } '`
f=`grep ' '$8' ' $1.pdb | grep ' CA ' | awk '{ print $2 } '`

dist1=`awk 'FNR == 2 {print $2}' dist.dat`
a1=`awk 'FNR == 2 {print $2}' angle.dat`
a2=`awk 'FNR == 2 {print $3}' angle.dat`
dih1=`awk 'FNR == 2 {print $2}' dihedral.dat`
dih2=`awk 'FNR == 2 {print $3}' dihedral.dat`
dih3=`awk 'FNR == 2 {print $4}' dihedral.dat`

i=`echo "$dih1 - 180.000" | bc | sed 's/^\./0./'`
j=`echo "$dih1 + 180.000" | bc | sed 's/^\./0./'`
k=`echo "$dih2 - 180.000" | bc | sed 's/^\./0./'`
l=`echo "$dih2 + 180.000" | bc | sed 's/^\./0./'`
m=`echo "$dih3 - 180.000" | bc | sed 's/^\./0./'`
n=`echo "$dih3 + 180.000" | bc | sed 's/^\./0./'`

echo "&rst iat= $d,$a,		r1= 0.000,	r2= $dist1,	r3= $dist1,	r4= 999.000,	rk2= 5.000,	rk3= 5.000,	&end
&rst iat= $e,$d,$a,	r1= 0.000,	r2= $a1,	r3= $a1,	r4= 180.000,	rk2= 5.000,	rk3= 5.000,	&end 
&rst iat= $d,$a,$b,	r1= 0.000,	r2= $a2,	r3= $a2,	r4= 180.000,	rk2= 5.000,	rk3= 5.000,	&end
&rst iat= $f,$e,$d,$a,	r1= $i,	r2= $dih1,	r3= $dih1,	r4= $j,	rk2= 5.000,	rk3= 5.000,	&end	
&rst iat= $e,$d,$a,$b,	r1= $k,	r2= $dih2,	r3= $dih2,	r4= $l,	rk2= 5.000,	rk3= 5.000,	&end
&rst iat= $d,$a,$b,$c,	r1= $m,	r2= $dih3,	r3= $dih3,	r4= $n,	rk2= 5.000,	rk3= 5.000,	&end" > disang.rest
