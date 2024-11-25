path = prepend("/home/macaulay/AlgebraicAnalysis", path)
needs "pfaffians.m2"

W = makeWA(QQ[a,b,c,c', DegreeRank => 0][x,y])
I = ideal(
    dx*(x*dx + c  - 1) - (x*dx + y*dy + a)*(x*dx + y*dy + b),
    dy*(y*dy + c' - 1) - (x*dx + y*dy + a)*(x*dx + y*dy + b))
A = pfaffians I;
assert all(checkSystem(W, A), zero)
