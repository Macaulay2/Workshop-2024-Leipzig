restart
loadPackage("Resultants")
loadPackage("BGG")
loadPackage("RandomSpaceCurves")
kk=ZZ/101
P3=kk[x_0..x_3]
E=kk[e_0..e_3,SkewCommutative=>true]
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

I=ideal(sum(4,i->x_i^2),sum(4,i->random(kk)*x_i^2));
M=P3^1/I
F=sheaf M
cohomologyTable(F,-3,3)
TM=tateResolution(presentation M,E,-3,3)
TM.dd_4

elapsedTime tally apply(1,c->(
	I=ideal random(P3^1,P3^{2,-2});
	degree chowForm I)
restart
loadPackage("BGG")
kk=ZZ/101
k=3,n=6
Pn=kk[x_0..x_n]
E=kk[e_0..e_n,SkewCommutative=>true]
b=2
m=matrix apply(b,i->apply(n+b-2,j->x_(i+j)))
m2=presentation prune symmetricPower(2,coker m)
TM=(tateResolution(m2,E,-3,3))**E^{1}
betti TM
apply(7,i->tally degrees TM_i)
d1=TM.dd_4, d0=TM.dd_3



k,n
St=kk[a_(0,0)..a_(k-1,n)]
stm= genericMatrix(St,a_(0,0),n+1,k)

matrix apply(2,i->apply(4,j->a_(i,j)*random(ZZ^2,ZZ^3)))

val=values tally apply(10^3,i->random(100))
mean=sum(val)/#val
mean-min val, max val -mean, max val -min val
sqrt (sum(val,v->(v-mean)^2)/(#val-1)), sqrt( #val)
tally val

i=3,j=1, t=i-j
basis(t,E)

L1=subsets(toList(0..k-1),i)
L2=subsets(toList(0..k-1),j)
L3=subsets(toList(0..n),t)
mons=apply(L3,K->product(K,l->e_l))
ns=L3_10
mon=product(L3_10,l->e_l)
matrix apply(L1,I->apply(L2,J-> (
	    --   I=L1_2,J=L2_2
	    if not isSubset(J,I) then 0_St else (
	    IminusJ=select(I,i->not member(i,J));
	    det(stm^ns_IminusJ))
	)))
)
    netList apply(3,i->exteriorPower(i,m2x4))
netList apply(3,i->basis(i,E))
