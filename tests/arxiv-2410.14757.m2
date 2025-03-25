-- Example based on the equations (11)-(13) in https://arxiv.org/pdf/2410.14757 (v2)
path = prepend("/home/macaulay/AlgebraicAnalysis", path)
needsPackage "ConnectionMatrices"

w = {0,0,0,1,1,1}
D = makeWeylAlgebra(frac(QQ[e,DegreeRank=>0])[x,y,z],w)    

delta1 = (x^2-z^2)*dx^2+2*(1-e)*x*dx-e*(1-e)
delta2 = (y^2-z^2)*dy^2+2*(1-e)*y*dy-e*(1-e)
delta3 = (x+z)*(y+z)*dx*dy-e*(x+z)*dx-e*(y+z)*dy+e^2
h = x*dx+y*dy+z*dz-2*e

I = ideal(delta1+delta3, delta2+delta3,h)


P = connectionMatrices I;  
r = holonomicRank I;  

assert(holonomicRank I == 4)

-- Get Groebner Basis
G = flatten entries gens gb I;

-- TODO: Assert that the following change of bases lead to an epsilon factorized form.

SM1 = {1,dy,dz,dz^2};   -- TODO: Change this to take the standard monomials from P directly

B2 = {1,dx,dy,dx*dy};


changeofvar = gaugeMatrix(w,G,SM1,B2);
P2 = gauge(changeofvar,P,D);

-- Change of basis to go from P2 into epsilon factorized form:
changeofvar2 = transpose((1/(2*z*e^2))*matrix({{2*z*e^2, -e^2*(x-z), -e^2*(y-z), -e^2*(x+y)},{0,e*(x^2-z^2),0,e*(x+y)*(x+z)},{0,0,e*(y^2-z^2),e*(x+y)*(y+z)},{0,0,0,-(x+y)*(x+z)*(y+z)}}));
P3 = gauge(changeofvar2,P2,D);
-- P3 is an epsilon-factorized system of connection matrices, changeofvar2 is the matrix from equation (13)
1/e*connectionMatrix(P3);
