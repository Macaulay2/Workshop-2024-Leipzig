needs "holonomic.m2"
--needs "gbw-fixed.m2"
needs "reduce.m2"
importFrom_Core { "concatRows", "concatCols" }

checkSystem = (W, A) -> apply(toSequence \ subsets(numgens W // 2, 2), (i,j) -> A_i * A_j - A_j * A_i)

-- Given a D-ideal, compute its Pfaffian system
-- c.f. [Theorem 1.4.22, SST]
pfaffians(List, Ideal) := List => (w, I) -> (
    D := ring I;
    -- warning: multiplication in R isn't correct
    R := rationalWeylAlgebra(D, w);
    -- TODO: make sure this isn't doing something illegal!
    G := gens gb I;
    print G;
--    G := gens ideal {I_1, (-x*y+y^2)*dy^2 + (-x+3*y)*dy + 1};
    -- cache the standard monomials
    -- TODO: only works on my branch!!
    r := holonomicRank(w, M := comodule I);
    if r === infinity then error "system is not finite dimensional";
    B := sub(M.cache#"basis", R);
    print B;
    A := apply(D.dpairVars#1,
	dt -> transpose concatCols apply(flatten entries B,
	    s -> last coefficients(
		-- essentially compute: sub(dt, R) * s % G
		normalForm(D, w, sub(dt, R) * s, first entries G), Monomials => B)));
    A)
-- TODO: pfaffians Ideal := List => I -> ()

end--
restart
needs "./pfaffians.m2"
-- ALS notes, Example 7.16
D = makeWeylAlgebra(QQ[x,y], w = {0,0,1,2});
A = pfaffians(w, I = ideal (x*dx^2 - y*dy^2 + dx-dy, x*dx+y*dy+1)) -- doesn't commute

-- i2 : D = makeWeylAlgebra(QQ[x,y], w = {0,0,2,1});
-- i3 : A = pfaffians(w, I = ideal (x*dx^2 - y*dy^2 + dx-dy, x*dx+y*dy+1)) -- doesn't commute
-- | xdx+ydy+1 ydxdy+ydy^2+dx+dy xydy^2-y2dy^2+xdy-3ydy-1 |
-- | 1 dy |
-- o3 = {{-1} | (-1)/x       (-y)/x         |, {-1} | 0         1               |}
--       {-1} | (-1)/(x2-xy) (-x-y)/(x2-xy) |  {-1} | 1/(xy-y2) (-x+3y)/(xy-y2) |

-- i4 : D = makeWeylAlgebra(QQ[x,y], w = {0,0,1,1});
-- i5 : A = pfaffians(w, I = ideal (x*dx^2 - y*dy^2 + dx-dy, x*dx+y*dy+1)) -- doesn't commute
-- | xdx+ydy+1 ydxdy+ydy^2+dx+dy xydy^2-y2dy^2+xdy-3ydy-1 |
-- | 1 dy |
-- o5 = {{-1} | (-1)/x       (-y)/x         |, {-1} | 0         1               |}
--       {-1} | (-1)/(x2-xy) (-x-y)/(x2-xy) |  {-1} | 1/(xy-y2) (-x+3y)/(xy-y2) |

-- i6 : D = makeWeylAlgebra(QQ[x,y], w = {0,0,1,2});
-- i7 : A = pfaffians(w, I = ideal (x*dx^2 - y*dy^2 + dx-dy, x*dx+y*dy+1)) -- doesn't commute
-- | ydy+xdx+1 xdxdy+xdx^2+dy+dx x2dx^2-xydx^2+3xdx-ydx+1 |
-- | 1 dx |
-- o7 = {{-1} | 0            1               |, {-1} | (-1)/y    (-x)/y        |}
--       {-1} | (-1)/(x2-xy) (-3x+y)/(x2-xy) |  {-1} | 1/(xy-y2) (x+y)/(xy-y2) |

checkSystem(D, A)

-- GKZ system of matrix {{1,2,3}}
-- gkz(matrix{{1,2}}, )
D = makeWeylAlgebra(QQ[x,y])
pfaffians({0,0,1,1}, ideal (x*dx+2*y*dy-1, dx^2-dy))
pfaffians ideal (x*dx+2*y*dy-1, dx^2-dy)
-- permutation matrices?
pfaffians ideal (dy^2-1, dx^5-dy)
pfaffians ideal (dy^3-1, dx^2-dy)

D = makeWA(QQ[x])
pfaffians ideal (dx^2 - x)

-- Example 1.4.24 in SST
D = makeWA(QQ[a,b,c,c', DegreeRank => 0][x,y])
I = ideal(
    dx*(x*dx + c  - 1) - (x*dx + y*dy + a)*(x*dx + y*dy + b),
    dy*(y*dy + c' - 1) - (x*dx + y*dy + a)*(x*dx + y*dy + b))
A = pfaffians({0,0,11,9}, I);
netList apply(A, mat -> sub(mat, {a => 10, b => 4/5, c => -2, c' => 3/2}))
gens gb sub(I, {a => 10, b => 4/5, c => -2, c' => 3/2})

checkSystem(D, A)

-- FIXME: why zero?
pfaffians AppellF1 {10,4/5,-2,3/2}

D = makeWA(QQ[x_1,x_2,x_3])
-- FIXME: why zero?
netList pfaffians stafford ideal (dx_1, dx_2, dx_3)

restart
needs "./pfaffians.m2"

-- Example 1.2.9 in SST, pp. 14
D = makeWA(QQ[a,b,c,DegreeRank => 0][x_1..x_4])
I = ideal(
    dx_2*dx_3 - dx_1*dx_4,
    x_1*dx_1 - x_4*dx_4 + 1 - c,
    x_2*dx_2 + x_4*dx_4 + a,
    x_3*dx_3 + x_4*dx_4 + b)
--I = sub(I, {a => 1/2, b => 1/2, c => 1})
--WeylClosure I
netList(A = pfaffians I)

-- example
R = (frac extractVarsAlgebra D)(monoid[D.dpairVars#1])
G = gb sub(I, R);
B = sub((comodule I).cache#"basis", R)
dt = last D.dpairVars#1
s = last flatten entries B
last coefficients(sub(dt, R) * s % G, Monomials => B)

<< texMath A_1
checkSystem(D, A)

-- Example 1.4.23 in SST, pp. 39
netList apply(A, mat -> sub(mat, {a => 1/2, b => 1/2, c => 1}))


--examples from 25/11
D = makeWA(QQ[a,DegreeRank=>0][x])
pfaffians ideal (x^5*dx - a)


D = makeWA(QQ[a,b,DegreeRank=>0][x,y])
pfaffians(I=ideal (x^5*dx^2 - a,y^4*dy^3-b*dx))
holonomicRank I

f=symbol f
g=symbol g
h=symbol h
D = makeWA(QQ[f,g,h,DegreeRank=>0][x,y])
I=ideal(f*dx+g*dy+h,dx^2-dx^3+dy^3)
characteristicIdeal I
pfaffians I

D = makeWA(QQ[x,y])
g=x*y
f=x^2+y^2
h=x+y
I=ideal(f*dx+g*dy+h,dx^2+dy^3)
holonomicRank I
pfaffians I



D = QQ[x,y,dx,dy, WeylAlgebra =>{x=>dx,y=>dy}, Weights=>{0,0,2,1}]
P=x*dx^2-y*dy^2+dx-dy
Q=x*dx+y*dy+1
I=ideal(P,Q)
pfaffians I
gens gb I
leadTerm I

D' = QQ[x,y,dx,dy, WeylAlgebra =>{x=>dx,y=>dy}]
P=x*dx^2-y*dy^2+dx-dy
Q=x*dx+y*dy+1
I'=ideal(P,Q)
gens gb I'
leadTerm I'
pfaffians(I')
M'=comodule I'
holonomicRank M'
peek(M'.cache)




D = QQ[x,y,dx,dy, WeylAlgebra =>{x=>dx,y=>dy}]
P=x*dx^2-y*dy^2+2*dx-2*dy
Q=x*dx+y*dy+1
I=ideal(P,Q)
pfaffians I
M=comodule I
holonomicRank M
peek(M.cache)
