needs "reduce.m2"

generateGaugeMatrix = method()
-- 
generateGaugeMatrix(Ring, List, List, List, List) := (D, w, G, stdMon, newStdMon) -> (
  --R := rationalWeylAlgebra(D, w);
  gaugeMat = mutableMatrix map((fractionField D)^(length newStdMon), (fractionField D)^(length stdMon),0);
  for rowIndex from 0 to length(newStdMon)-1 do
  {
    reducedWRTG = normalForm(D,w,newStdMon_rowIndex,G);  -- gives an element of R
    coeffsReduced = coefficients reducedWRTG;
    for j from 0 to length(flatten entries coeffsReduced_0)-1 do
    --runs through (d-)monomial support of the reduced thing
    {
      monomialToFind = (flatten entries coeffsReduced_0)_j;
      colIndex = position(stdMon, i->i==monomialToFind);
      gaugeMat_(rowIndex,colIndex) = sub((flatten entries coeffsReduced_1)_j, fractionField D);
    }
  }
)
