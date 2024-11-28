needs "normalForm.m2"
-- NEED TO ALSO CHANGE WEIGHTS IN DEFINITION OF R

-- Examples for testing with Pfaffian matrices
-- Example 1.3: w = (0,0,2,1) ----> EQUALS COMPUTATIONS
D = QQ[x,y,dx,dy, WeylAlgebra =>{x=>dx,y=>dy},MonomialOrder=>{Weights=>{0,0,2,1}, RevLex}, Global => false]
I = ideal(x*dx^2-y*dy^2+dx-dy,x*dx+y*dy+1)
R = rationalWeylAlgebra D
G = gb I
leadTerm(I) 
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
