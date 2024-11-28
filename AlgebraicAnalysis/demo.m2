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

gauge(G,{P1,P2},W)
