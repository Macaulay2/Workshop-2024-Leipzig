path = prepend("/home/macaulay/AlgebraicAnalysis", path)
needs "connectionMatrices.m2"

W = makeWA(QQ[a,b,c,c', DegreeRank => 0][x,y])
I = ideal(
    dx*(x*dx + c  - 1) - (x*dx + y*dy + a)*(x*dx + y*dy + b),
    dy*(y*dy + c' - 1) - (x*dx + y*dy + a)*(x*dx + y*dy + b))
A = connectionMatrices I;

-- TODO: The checkSystem as of 2025-02-28 is incorrect. Needs to involve the exterior derivative too.
-- assert all(checkSystem(W, A), zero)
