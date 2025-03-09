-- Examples based on the Overleaf file created at the workshop and modified thereafter.
-- Computations are checked with Mathematica.

-- TODO: This is only one example from the file. We should add the other ones too.


path = prepend("/home/macaulay/AlgebraicAnalysis", path)

needs "reduce.m2"
needs "pfaffians.m2"
needs "gaugeMatrix.m2"
needs "changeofbasis.m2"


w1 = {0,0,2,1};
w2 = {0,0,1,2};

D1 = makeWeylAlgebra(QQ[x,y],w1);
D2 = makeWeylAlgebra(QQ[x,y],w2);

-- Construct the ideal in the first Weyl algebra
I = sub(ideal(x*dx^2-y*dy^2+2*dx-2*dy,x*dx+y*dy+1),D1);  -- Ex. 1.4
-- Compute its holonomic rank
assert(holonomicRank(I) == 2) 

-- Computing the Pfaffian system w.r.t. weight vector w1
C1 = pfaffians(I);
SM1 = stdMon(I);

-- Computing the Pfaffian system w.r.t. weight vector w2
C2 = pfaffians(sub(I,D2));
SM2 = stdMon(sub(I,D2));

-- Compute Groebner Basis
G = flatten entries gens gb I; 
changeofvar = gaugeMatrix(G,SM1,SM2);

-- Now transform the Pfaffian system C1 into the Pfaffian System C2 via Gauge transform
assert(C2 == gaugeTransform(changeofvar,C1,D1)) -- TODO: Need to remove the weight information.   // Fails so far.