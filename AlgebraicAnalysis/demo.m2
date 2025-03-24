needs "reduce.m2"
needs "pfaffians.m2"
needs "gaugeMatrix.m2"
needs "changeofbasis.m2"


-- Example 1: Connection matrices and change of basis

w1 = {0,0,2,1}
w2 = {0,0,1,2}

D1 = makeWeylAlgebra(QQ[x,y],w1)
D2 = makeWeylAlgebra(QQ[x,y],w2)

I = sub(ideal(x*dx^2-y*dy^2+2*dx-2*dy,x*dx+y*dy+1),D1)

holonomicRank(I)

C1 = connectionMatrices(I)
SM1 = standardMonomials I

C2 = connectionMatrices(sub(I,D2))
SM2 = standardMonomials sub(I,D2)

G = flatten entries gens gb I
changeofvar = gaugeMatrix(w1,G,SM1,SM2)
gauge(changeofvar,C1,D1)


-- Example 2: with parameters
-- Example equation (11) from https://arxiv.org/pdf/2410.14757 

w = {0,0,0,1,1,1};
D = makeWeylAlgebra(frac(QQ[e,DegreeRank=>0])[x,y,z],w);    

delta1 = (x^2-z^2)*dx^2+2*(1-e)*x*dx-e*(1-e);
delta2 = (y^2-z^2)*dy^2+2*(1-e)*y*dy-e*(1-e);
delta3 = (x+z)*(y+z)*dx*dy-e*(x+z)*dx-e*(y+z)*dy+e^2;
h = x*dx+y*dy+z*dz-2*e;

I = ideal(delta1+delta3, delta2+delta3,h)
r = holonomicRank I
P = connectionMatrices I;
C = diffConnectionMatrix I;
G = flatten entries gens gb I;
SM1 = standardMonomials I

B2 = {1,dx,dy,dx*dy};
changeofvar = gaugeMatrix(G,SM1,B2)
P2 = gaugeTransform(changeofvar,P,D)

changeVar = transpose((1/(2*z*e^2))*matrix({{2*z*e^2, -e^2*(x-z), -e^2*(y-z), -e^2*(x+y)},{0,e*(x^2-z^2),0,e*(x+y)*(x+z)},{0,0,e*(y^2-z^2),e*(x+y)*(y+z)},{0,0,0,-(x+y)*(x+z)*(y+z)}}));
P3 = gaugeTransform(changeVar,P2,D);
-- P3 is an epsilon-factorized system of connection matrices, changeofvar2 is the matrix from equation (13)
1/e*diffConnectionMatrix(P3)






-- Examples for testing with connection matrices
-- Example 1.3: w = (0,0,2,1) ----> EQUALS COMPUTATIONS
D = QQ[x,y,dx,dy, WeylAlgebra =>{x=>dx,y=>dy},MonomialOrder=>{Weights=>{0,0,2,1}, RevLex}, Global => false]
I = ideal(x*dx^2-y*dy^2+dx-dy,x*dx+y*dy+1)
R = rationalWeylAlgebra D
G = gb I
leadTerm(I)

end--
restart
needs "demo.m2"
-- P1:
-- first row P1 -- EQUAL
normalForm({0,0,2,1},dx_R,flatten entries gens G)
-- second row P1 -- NOT EQUAL
normalForm({0,0,2,1},dx_R*dy_R,flatten entries gens G)
-- P2:
-- first row P2 -- EQUAL
normalForm({0,0,2,1},dy_R,flatten entries gens G)
-- second row P2 -- NOT EQUAL
normalForm({0,0,2,1},dy_R^2,flatten entries gens G)


-- Example for gauge transformation
debug needsPackage "Dmodules"
debug needsPackage "WeylAlgebras"
load "changeofbasis.m2"
W = QQ[x,y,dx,dy, WeylAlgebra =>{x=>dx,y=>dy}]
R = (frac extractVarsAlgebra W)(monoid[W.dpairVars#1])
use coefficientRing R
P1 = matrix{{-1/x, -y/x},
            {-1/(x*(x-y)), -(x+y)/(x*(x-y))}};

P2 = matrix{{0, 1}, 
            {1/((x-y)*y), (3*y-x)/((x-y)*y)}};
G = matrix{{1,0},{-1/x,-y/x}}
--given a change of basis matrix G and matrices {P_1,...,P_n}
--gauge returns the n matrices (dG/dx_i)*G^-1 + G P_i G^-1
gauge(G,{P1,P2},W)
