restart
loadPackage("Resultants")
loadPackage("BGG")
loadPackage("RandomSpaceCurves")
kk=ZZ/101
P3=kk[x_0..x_3]
d=8,g=5
betti(I=(random spaceCurve)(d,g,P3))
minimalBetti I
elapsedTime F=chowForm I; -- 32.3974 seconds elapsed d=8,g=5
#terms F
M=P3^1/I
F=sheaf M;
cohomologyTable(F,-2,5)
E=kk[e_0..e_3,SkewCommutative=>true]
m=presentation M
TM=tateResolution(m,E,-2,5)
betti TM
betti(TM.dd_5)
omegaC=Ext^2(M,P3^{-4})
cohomologyTable(sheaf omegaC,-2,5)
betti res coker bgg(3,M,E)
m2x3=matrix apply(2,i->apply(3,j->x_(i+j)))
Ominus1=sheaf (M=trim symmetricPower(2,coker m2x3))
cohomologyTable(Ominus1,-3,3)
T=tateResolution(presentation symmetricPower(2,coker m2x3),E,-3,3)
T.dd_4

I=minors(2,m2x3)
F=dualize chowForm I
P5=ring ideal ring F
m3x3=matrix {{x_(0,1),x_(0,2),x_(0,3)},
        {x_(0,2),x_(1,2)+x_(0,3),x_(1,3)},
	{x_(0,3),x_(1,3),x_(2,3)}}
ideal sub(det m3x3,ring F)==ideal F

P4=kk[x_0..x_4]
I=ideal random(P4^1,P4^{3:-2})
minimalBetti I
F=chowForm I

use P3
elapsedTime tally apply(10,c->(
	I=ideal(sum(4,i->x_i^2),sum(4,i->random(kk)*x_i^2));
	degree chowForm I))

elapsedTime tally apply(1,c->(
	I=ideal random(P3^1,P3^{2,-2});
	degree chowForm I)
