needsPackage "GraphicalModels";

intersectCImodel = method()
intersectCImodel (Graph,Ideal,List) := (G,V,Di) -> (
markovR = markovRing (toSequence(Di));
R := ring (V);
Finv := map(R,markovR,R_*);
H:=map(R,ZZ);
S := globalMarkov G;
I := Finv(conditionalIndependenceIdeal (markovR, S));
if I+V==H(ideal(1)) then (
result:=H(ideal(1));
result
);
for k from 0 to length(R_*)-1 do (
I=saturate(I,R_k,Strategy=>Bayer);
print k;
V=saturate(V,R_k,Strategy=>Bayer);
print k;
);
I=saturate(I,sum(R_*),Strategy=>Bayer);
V=saturate(V,sum(R_*),Strategy=>Bayer);
J:=I+V;
for k from 0 to length(R_*)-1 do (
J=saturate(J,R_k,Strategy=>Bayer);
print k;
);
J=saturate(J,sum(R_*),Strategy=>Bayer);
result=J;
result
)

