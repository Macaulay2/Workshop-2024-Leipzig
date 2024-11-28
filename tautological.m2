restart
kk=ZZ/101
k=3,n=6  -- example does not work for k>2 --
St=kk[a_(0,0)..a_(k-1,n)]
A = genericMatrix(St,a_(0,0),n+1,k)
bbrm = syz transpose A

L=subsets(0..n,k)
Pl = kk[apply(L, I -> p_I)]
plueckRel = Grassmannian(k-1,n,Pl)
SGr = ring plueckRel / plueckRel

StxPl = St ** Pl
graph = ideal apply(L, I -> sub(p_I,StxPl) - sub(det A^I,StxPl))

elapsedTime (sBR = map(Pl^(n+1),,sub(sub(bbrm, StxPl) % graph, Pl)))
betti( imU = sBR ** SGr )
assert(dim coker imU - 1 == k*(n+1-k))
assert( degree coker imU == k*degree SGr)

--pres = syz imU


emb = map(SGr, Pl)

needsPackage "PushForward"
phi = pushFwd(emb, sBR)