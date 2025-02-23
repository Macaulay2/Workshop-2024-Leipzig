needs "reduce.m2"
needs "pfaffians.m2"

gaugeMatrix = method();
-- generate gauge matrix
-- D Weyl algebra, w weights, G old Groebner basis, L {old standard monomials, new standard monomials}
gaugeMatrix(List, List, List, List) := (w, G, stdMon, newStdMon) -> (
  D := ring G#0;
  --R := rationalWeylAlgebra(D, w);
  gaugeMat := mutableMatrix map((fractionField D)^(length newStdMon), (fractionField D)^(length stdMon),0);
  for rowIndex from 0 to length(newStdMon)-1 do
  (
    reducedWRTG := normalForm(D,w,sub(newStdMon#rowIndex,D),G);  -- gives an element of R
    coeffsReduced := coefficients reducedWRTG;
    for j from 0 to length(flatten entries coeffsReduced_0)-1 do
    --runs through (d-)monomial support of the reduced thing
    (
      monomialToFind := sub((flatten entries coeffsReduced_0)#j,D);
      colIndex := position(stdMon, i->sub(i,D) == monomialToFind);
      gaugeMat_(rowIndex,colIndex) = sub((flatten entries coeffsReduced_1)#j, fractionField D);
    );
  );
  return matrix gaugeMat
);

end--
restart 

-- Example Francesca overleaf
w1 = {0,0,2,1};
w2 = {0,0,1,2};

D = makeWeylAlgebra(QQ[x,y],w1);
I = ideal(x*dx^2-y*dy^2+2*dx-2*dy,x*dx+y*dy+1);
holonomicRank(I)
C = (pfaffians(w1,I))
oldSM = {sub(1,D),dy};
newSM = {sub(1,D),dx};
G = flatten entries gens gb I;
gaugeMatrix(w1,G,oldSM,newSM)
