diffW=method();
diffW(RingElement,RingElement) :=(P,f)->(
DR := ring P;
R := ring f;
createDpairs DR;
partials := ideal( DR.dpairVars_1);
sub((P*sub(f,DR)) % partials,R)
)

diffratW=method();
-- Add check that P is degree 1 in derivation
diffratW(RingElement,RingElement,RingElement) :=(P,f,g)->(
    (h1,h2)=(g*diffW(P,f)-f*diffW(P,g),g^2);
    sub(h1, ring f)/sub(h2,ring f)
)

-- Convert entries of Pfaffian to fractions
convertEntry = method();
convertEntry(RingElement) := (h)->(
    frach = sub(h, coefficientRing(ring h));
    (numerator frach, denominator frach)
)

--Differentiate matrix
diffmatrixW = method();
diffmatrixW(RingElement, Matrix) :=(P, M)->(
    lrows = entries M;
    matrix apply(lrows, a-> apply(a, b-> diffratW(toSequence({P}| toList convertEntry(b)))))
)

gauge = method();
gauge(Matrix, List, PolynomialRing) := (G, C, W)->(
    G = sub(G, ring C#0);
    invG = inverse G;
    n = dim W//2;
    for i from 1 to n list(
        dxi = W_(n+i-1);
        diffmatrixW(dxi, G)*invG + G*(C#(i-1))*invG
    )
)

end--
restart
debug needsPackage "Dmodules"
debug needsPackage "WeylAlgebras"
needs "changeofbasis.m2"


W = makeWA(QQ[x,y])
P = dx
f = x^2
g = 3*y^5
diffratW(P,f,g)

needs "pfaffians.m2"
W = QQ[x,y,dx,dy, WeylAlgebra =>{x=>dx,y=>dy}]
P=x*dx^2-y*dy^2+2*dx-2*dy
Q=x*dx+y*dy+1
I=ideal(P,Q)
C = pfaffians I
G = matrix{{x,0},{0,y}}
gauge(G,C,W)