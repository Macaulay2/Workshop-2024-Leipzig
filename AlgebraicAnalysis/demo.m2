
W = QQ[x,y,dx,dy, WeylAlgebra =>{x=>dx,y=>dy}]
R = (frac extractVarsAlgebra W)(monoid[W.dpairVars#1])
use coefficientRing R
P1 = matrix{{-1/x,-y/x},{0,0}}
P2 = matrix{{0,1},{0,-2/y}}
G = matrix{{1,0},{-1/x,-y/x}}
gauge(G,{P1,P2},W)
