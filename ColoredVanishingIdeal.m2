m2
debug needsPackage "GraphicalModels"


coloredGaussianVanishingIdeal = method()

coloredGaussianVanishingIdeal (Digraph, List) := Ideal => (G, c) -> (

R=gaussianRing G;
gens R;
M:=covarianceMatrix(R);
K= for i from 0 to (#vertices G+ #edges G -1) list (gens R)_i;
N=gaussianParametrization(R);
W=sub(N,{l_(2,3)=>l_(1,2)});
J=M-W;
I=for i from 0 to #vertices G-1 list for j from 0 to #vertices G-1 list J_(i,j);
Id=ideal flatten I;
VI= eliminate(Id,K)

)


G = digraph({1,2,3},{{1,2},{2,3}})
coloredGaussianVanishingIdeal(G, {l_(2,3)=>l_(1,2)})


