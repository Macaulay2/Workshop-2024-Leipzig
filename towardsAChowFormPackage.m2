randomUlrichLineBundle=method()
randomUlrichLineBundle(Ideal) := I -> (
    -- Input: I the homogeneous ideal of a smooth projective curve
    -- Output: Presentation matrix of an Ulrich bundle
    )

--------------------------------------
stiefelComplex = method()
stiefelComplex(Complex,Matrix) := (T,stm) -> (
    -- Input: T , a Tate resolution of E in n+1 varibles
    --        stm the kx(n+1) matrix in the over St=kk[a_(0,0)..a_(k-1,n)]
    -- Output: U'(T) a complex of garded free St-modules.

    (lo,hi) := concentration T;
    k := numColumns stm;
    n := (numRows stm)-1;
    
    matrixEtoMatrixSt := D -> (
        degsSource := flatten degrees source D;
        degsTarget := flatten degrees target D;
        
        return matrix apply(#degsTarget, i -> apply(#degsSource, j -> (
            p := k + degsSource_j;
            q := k + degsTarget_i;
            f := D_(i,j);
    
            uMatrix(p,q,f,stm)
        )));
    );
    
    newdiffs := apply(toList(lo+1..hi),d -> matrixEtoMatrixSt T.dd_d);
    d0 := first newdiffs;
    newdiffscorr := toList apply(1..#newdiffs-1, d -> d0 = map(source d0,,newdiffs#d));
    
    return complex(newdiffscorr, Base => lo);
)

TEST /// --example case 

loadPackage("BGG",Reload=>true)
kk=ZZ/101
k=4,n=6
Pn=kk[x_0..x_n]
E=kk[e_0..e_n,SkewCommutative=>true]
St=kk[a_(0,0)..a_(k-1,n)]
stm= genericMatrix(St,a_(0,0),n+1,k)

Pn=kk[x_0..x_n]
E=kk[e_0..e_n,SkewCommutative=>true]
b=2
m=matrix apply(b,i->apply(n+2-b,j->x_(i+j)))
m2=presentation prune symmetricPower(2,coker m)
TM=(tateResolution(m2,E,-3,3))**E^{0}[3]
betti TM
apply(-3..3,i->tally degrees TM_i)
ds={d0=TM.dd_0,d1=TM.dd_1, d2=TM.dd_2,d3=TM.dd_3};
netList ds
apply(ds,d->betti d)


------------------------------------------------
restart
needsPackage "Complexes"
needsPackage "BGG"

kk=ZZ/101
k=4,n=6
E=kk[e_0..e_n,SkewCommutative=>true]
St=kk[a_(0,0)..a_(k-1,n)]
stm= genericMatrix(St,a_(0,0),n+1,k)

Pn=kk[x_0..x_n]
E=kk[e_0..e_n,SkewCommutative=>true]
b=2
m=matrix apply(b,i->apply(n+2-b,j->x_(i+j)))
m2=presentation prune symmetricPower(2,coker m)

TM=(tateResolution(m2,E,-3,3))**E^{0}[3]
T = complex TM

stiefelComplex(T,stm)

D = T.dd_0
g = D_{3}^{1}

degsSource = flatten degrees source D
degsTarget = flatten degrees target D

apply(#degsTarget, i -> apply(#degsSource, j -> (
    p := k + degsSource_j;
    q := k + degsTarget_i;
    f := D_(i,j);
    
    uMatrix(p,q,f,stm)
)))

///

uMatrix = method()
uMatrix(ZZ,ZZ,RingElement,Matrix) := (p,q,f,stm) -> (
    -- Input: p,q, non-negativ integers p>q
    --       f, an element of degree t=p-q in the an exterior
    --       stm the kx(n+1) matrix in the over St=kk[a_(0,0)..a_(k-1,n)]
    -- Output: the morphism Lamba^p U -> Lambda^q U induced by f
    --       in other words a binomial(k,p)xbinomial(k,q) matrix with entries
    --       certain txt a sum of certain txt minors of m
    
    k := numColumns stm;
    n := (numRows stm)-1;
    
    if (p < q or q < 0 or p > k or f == 0) then (
        St := ring stm;
        return map(St^(binomial(k,q)),St^(binomial(k,p)),0);
    );
    
    multOnSummand := (I,J,K) -> (
        if not(#I == #J + #K) then return 0;
        if not(isSubset(J,I)) then return 0;
        
        IminusJPos := select(apply(#I,n -> (n+1,I_n)),(n,i) -> not isMember(i,J));
        IminusJ := apply(IminusJPos,last);
        
        -- TODO: Double check the sign!        
        return (-1)^(sum apply(IminusJPos,first)) * det stm^K_IminusJ;
    );
    
    exteriorPolyToList := poly -> apply(exponents poly,L -> positions(L,odd));
    
    Lsource := subsets(toList(0..k-1),p);
    Ltarget := subsets(toList(0..k-1),q);
    
    multFromK := K -> (
        return matrix apply(Ltarget,J -> apply(Lsource, I -> (
            multOnSummand(I,J,K)
        )));
    );
    
    return sum(exteriorPolyToList f,multFromK);
)
   
TEST /// -- Hint
kk=ZZ/2
k=4,n=6
E=kk[e_0..e_n,SkewCommutative=>true]
St=kk[a_(0,0)..a_(k-1,n)]
m= genericMatrix(St,a_(0,0),n+1,k)
p=3,q=1, t=p-q
f = e_1*e_3 + e_5*e_2
uMatrix(p,q,f,m)

stm = m
p=3,q=1, t=p-q
basis(t,E)

L1=subsets(toList(0..k-1),p)
L2=subsets(toList(0..k-1),q)
L3=subsets(toList(0..n),t)

I = L1_2
J = L2_3
K = L3_2

mons=apply(L3,K->product(K,l->e_l))
ns=L3_10
f=product(ns,l->e_l)
matrix apply(L1,I->apply(L2,J-> (
	    --I=L1_2,J=L2_2
	    if not isSubset(J,I) then 0_St else (
	    IminusJ=select(I,i->not member(i,J));
	    det(stm^ns_IminusJ))
	)))
///
----------------
tautologicalBundle=method()
tautologicalBundle((ZZ,ZZ,ZZ,Ring) := (p,k,n,Pl) -> (
	-- Input: p, desired exterior power
	--        k,n values of the Grasmmanian GG(k,n+1)
	--        Pl coordinate ring of PP(binomial(n+1,k))
	-- Output: Presentation of Lambda^p U of the tautological rank k subbundle U
	)
TEST /// --Hint
kk=ZZ/101
k=2,n=5  -- example does not work for k>2 --
St=kk[a_(0,0)..a_(k-1,n)]
stm= genericMatrix(St,a_(0,0),n+1,k)
L=subsets(toList(0..n),k)
Pl=kk[apply(L,I->p_I)]
betti(buchsbaumRimMatrix=syz transpose stm)
SP=St**Pl
betti(graph=ideal apply(L,I->sub(p_I,SP)-sub(det stm^I,SP)))
sBR=sub(buchsbaumRimMatrix,SP)%graph;
support sBR
phi=map(Pl^(n+1),,sub(sBR,Pl))
betti(grass=ann(coker phi))
minimalBetti coker phi
minimalBetti grass
dim coker phi-1 == k*(n+1-k)
degree grass
degree coker phi
///

determinantOfAComplex=method()
determinantOfAComplex(ChainComplex) := F -> (
    --Input: F a ChainComplex of free graded S-module
    --Output: an element of Q(S), whose divisor measures the homology in codim 1
    --        according to Cayley
    )

TEST /// -- an example
kk=ZZ/101
S=kk[y_0..y_14]
m=genericSkewMatrix(S,y_0,5)
betti(F=res pfaffians(4,m))
A1=random(F_1,S^{-2})
B1=transpose syz transpose A1
B1*A1==0
A2=random(F_2,S^{4:-3})
B2=transpose syz transpose A2
L={det(F.dd_1*A1),det(B1*F.dd_2*A2),det(B2*F.dd_3)};
ideal(L_0*L_2)==ideal L_1
syz matrix{{L_0*L_2,L_1}}

///
