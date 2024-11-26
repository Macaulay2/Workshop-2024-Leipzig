needs "holonomic.m2"
importFrom_Core { "concatRows", "concatCols" }

checkSystem = (W, A) -> apply(toSequence \ subsets(numgens W // 2, 2), (i,j) -> A_i * A_j - A_j * A_i)

-- Given a D-ideal, compute its Pfaffian system
-- c.f. [Theorem 1.4.22, SST]
pfaffians Ideal := List => I -> (
    W := ring I;
    -- warning: multiplication in R isn't correct
    R := (frac extractVarsAlgebra W)(monoid[W.dpairVars#1]);
    -- TODO: make sure this isn't doing something illegal!
    G := gb sub(I, R);
    -- cache the standard monomials
    -- TODO: only works on my branch!!
    r := holonomicRank(M := comodule I);
    if r === infinity then error "system is not finite dimensional";
    B := sub(M.cache#"basis", R);
    --error 0;
    A := apply(W.dpairVars#1,
	dt -> concatCols apply(flatten entries B,
	    s -> last coefficients(
		sub(dt, R) * s % G, Monomials => B)));
    assert all(checkSystem(W, A), zero);
    A)

end--
restart
needs "./pfaffians.m2"

-- GKZ system of matrix {{1,2,3}}
-- gkz(matrix{{1,2}}, )
W = makeWeylAlgebra(QQ[x,y])
pfaffians ideal (x*dx+2*y*dy-3, dx^2-dy)
pfaffians ideal (x*dx+2*y*dy-1, dx^2-dy)
-- permutation matrices?
pfaffians ideal (dy^2-1, dx^5-dy)
pfaffians ideal (dy^3-1, dx^2-dy)

W = makeWA(QQ[x])
pfaffians ideal (dx^2 - x)

-- Example 1.4.24 in SST
W = makeWA(QQ[a,b,c,c', DegreeRank => 0][x,y])
I = ideal(
    dx*(x*dx + c  - 1) - (x*dx + y*dy + a)*(x*dx + y*dy + b),
    dy*(y*dy + c' - 1) - (x*dx + y*dy + a)*(x*dx + y*dy + b))
A = pfaffians I;
netList apply(A, mat -> sub(mat, {a => 10, b => 4/5, c => -2, c' => 3/2}))
gens gb sub(I, {a => 10, b => 4/5, c => -2, c' => 3/2})

checkSystem(W, A)

-- FIXME: why zero?
pfaffians AppellF1 {10,4/5,-2,3/2}

W = makeWA(QQ[x_1,x_2,x_3])
-- FIXME: why zero?
netList pfaffians stafford ideal (dx_1, dx_2, dx_3)

restart
needs "./pfaffians.m2"

-- Example 1.2.9 in SST, pp. 14
W = makeWA(QQ[a,b,c,DegreeRank => 0][x_1..x_4])
I = ideal(
    dx_2*dx_3 - dx_1*dx_4,
    x_1*dx_1 - x_4*dx_4 + 1 - c,
    x_2*dx_2 + x_4*dx_4 + a,
    x_3*dx_3 + x_4*dx_4 + b)
--I = sub(I, {a => 1/2, b => 1/2, c => 1})
--WeylClosure I
netList(A = pfaffians I)

-- example
R = (frac extractVarsAlgebra W)(monoid[W.dpairVars#1])
G = gb sub(I, R);
B = sub((comodule I).cache#"basis", R)
dt = last W.dpairVars#1
s = last flatten entries B
last coefficients(sub(dt, R) * s % G, Monomials => B)

<< texMath A_1
checkSystem(W, A)

-- Example 1.4.23 in SST, pp. 39
netList apply(A, mat -> sub(mat, {a => 1/2, b => 1/2, c => 1}))


--examples from 25/11
W = makeWA(QQ[a,DegreeRank=>0][x])
pfaffians ideal (x^5*dx - a)


W = makeWA(QQ[a,b,DegreeRank=>0][x,y])
pfaffians(I=ideal (x^5*dx^2 - a,y^4*dy^3-b*dx))
holonomicRank I

f=symbol f
g=symbol g
h=symbol h
W = makeWA(QQ[f,g,h,DegreeRank=>0][x,y])
I=ideal(f*dx+g*dy+h,dx^2-dx^3+dy^3)
characteristicIdeal I
pfaffians I

W = makeWA(QQ[x,y])
g=x*y
f=x^2+y^2
h=x+y
I=ideal(f*dx+g*dy+h,dx^2+dy^3)
holonomicRank I
pfaffians I



W = QQ[x,y,dx,dy, WeylAlgebra =>{x=>dx,y=>dy}, Weights=>{0,0,2,1}]
P=x*dx^2-y*dy^2+dx-dy
Q=x*dx+y*dy+1
I=ideal(P,Q)
pfaffians I
gens gb I
leadTerm I

W' = QQ[x,y,dx,dy, WeylAlgebra =>{x=>dx,y=>dy}]
P=x*dx^2-y*dy^2+dx-dy
Q=x*dx+y*dy+1
I'=ideal(P,Q)
gens gb I'
leadTerm I'
pfaffians(I')
M'=comodule I'
holonomicRank M'
peek(M'.cache)




W = QQ[x,y,dx,dy, WeylAlgebra =>{x=>dx,y=>dy}]
P=x*dx^2-y*dy^2+2*dx-2*dy
Q=x*dx+y*dy+1
I=ideal(P,Q)
pfaffians I
M=comodule I
holonomicRank M
peek(M.cache)
