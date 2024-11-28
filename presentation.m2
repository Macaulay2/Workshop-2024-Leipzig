restart
needsPackage "Complexes"
needsPackage "BGG"
needs "towardsAChowFormPackage.m2"

-------------------------------------------
-- O(+-2) on PP^1 embedded into PP^6
-- G(4,n+1): 3-dim'l subspaces of PP^6

kk=ZZ/101
k=4,n=6
E=kk[e_0..e_n,SkewCommutative=>true]
St=kk[a_(0,0)..a_(k-1,n)]
stm= genericMatrix(St,a_(0,0),n+1,k)

Pn = kk[x_0..x_n]
E = kk[e_0..e_n,SkewCommutative=>true]
b=2
m=matrix apply(b,i->apply(n+2-b,j->x_(i+j)))
m2=presentation prune symmetricPower(2,coker m)

TM=(tateResolution(m2,E,-3,3))**E^{1}[3]
T = complex TM

X = stiefelComplex(T,stm)

needs "determinantOfAComplex.m2"

determinantOfAComplex(chainComplex X)

-------------------------------------------
-- complete intersection of two quadrics, elliptic curve of degree 4

kk=ZZ/101
k=2,n=3
E=kk[e_0..e_n,SkewCommutative=>true]
St=kk[a_(0,0)..a_(k-1,n)]
stm= genericMatrix(St,a_(0,0),n+1,k)

Pn = kk[x_0..x_n]
I = ideal(sum(n,i -> x_i^2),sum(n,i -> random(kk)*x_i^2))
M = Pn^1/I
cohomologyTable(sheaf M,-3,3)
TM = tateResolution(presentation M,E,-3,3)[3] ** E^{1}
T = complex TM

X = stiefelComplex(T,stm)

needs "determinantOfAComplex.m2"

c1 = determinantOfAComplex(chainComplex X[-1])
c2 = det (X[-1]).dd_1

denominator c1 == c2


------------------------------------------

St = ring X

Lp = subsets(toList(0..n),k)
Pl = kk[apply(Lp, s -> p_s)]

Q = St ** Pl
graph = ideal apply(Lp, s -> substitute(p_s,Q) - substitute(det stm^s,Q))

--  substitute(X.dd_0,Q) % graph

c2Pl = substitute(substitute(c2,Q) % graph,Pl)

needsPackage "Resultants"
c3 = chowForm I
c3Pl = substitute(c3,vars Pl)

ideal c3Pl == ideal c2Pl

















