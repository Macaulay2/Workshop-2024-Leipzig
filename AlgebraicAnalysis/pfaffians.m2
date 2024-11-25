needs "holonomic.m2"
importFrom_Core "concatRows"

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
    A := apply(W.dpairVars#1,
	dt -> concatRows apply(flatten entries B,
	    s -> transpose last coefficients(
		sub(dt, R) * s % G, Monomials => B))))

checkSystem = (W, A) -> apply(toSequence \ subsets(numgens W // 2, 2), (i,j) -> A_i * A_j - A_j * A_i)

end--
restart
needs "./pfaffians.m2"

W = makeWA(QQ[x,y])
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
-- FIXME: why zero?
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
I = sub(I, {a => 1/2, b => 1/2, c => 1})
WeylClosure I
netList(A = pfaffians I)
<< texMath A_1

-- Example 1.4.23 in SST, pp. 39
netList apply(A, mat -> sub(mat, {a => 1/2, b => 1/2, c => 1}))

apply(toSequence \ subsets(numgens W // 2,2),
    (i,j) -> A_i * A_j - A_j * A_i)
