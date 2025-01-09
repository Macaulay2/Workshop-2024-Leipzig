needsPackage "GraphicalModels";

intersectCImodel = method(Options => {Verbose => false})
intersectCImodel (Graph,Ideal,List) := Sequence => o -> (G,V,Di) -> (
v := o.Verbose;
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
if v then print ("Completed step " | k+1 | " of saturating CI ideal");
V=saturate(V,R_k,Strategy=>Bayer);
if v then print ("Completed step " |k+1| " of saturating input ideal");
);
I=saturate(I,sum(R_*),Strategy=>Bayer);
if v then print ("Completed step " |length(R_*)+1| " of saturating CI ideal");
V=saturate(V,sum(R_*),Strategy=>Bayer);
if v then print ("Completed step " |length(R_*) +1|" of saturating input ideal");
J:=I+V;
for k from 0 to length(R_*)-1 do (
J=saturate(J,R_k,Strategy=>Bayer);
if v then print ("Completed step "|k+1|" of saturating sum");
);
J=saturate(J,sum(R_*),Strategy=>Bayer);
result=J;
result
)

