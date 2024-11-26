needs "pfaffians.m2"

-- fraction field K(x) of a Weyl algebra K[x,dx]/(...)
fractionField = memoize(D -> frac extractVarsAlgebra D)
-- graded associative ring of the rational Weyl algebra
rationalWeylAlgebra = memoize(D -> (fractionField D)(monoid[D.dpairVars#1]))

-- reduce the lead term in rational Weyl algebra R
reduceLeadTerm = method()
-- weightorder, f in D, g in D
reduceLeadTerm(List, RingElement, RingElement) := (w, f, g) -> (
    D := ring f;
    n := numgens D // 2;
    -- need to think about tiebreaker
    -- generic w
    f0 := inw(f,w);
    g0 := inw(g,w);
    -- get exponent vector
    -- pack_n is interior product with n
    fexp := unique apply(exponents f0, e -> last pack_n e);
    gexp := unique apply(exponents g0, e -> last pack_n e);
    if #fexp > 1 or #gexp > 1 then error "expected generic weight order";
    -- if g0 does not divide f0, no reduction is necessary
    if not (gexp << fexp) then return f;
    -- compare weights of leading monomials
    --fwt := sum(fexp#0, last pack_n w, times);
    --gwt := sum(gexp#0, last pack_n w, times);
    --if fwt < gwt then return f;
    F := fractionField D;
    R := rationalWeylAlgebra D;
    fcoef := lift(sub(f0, R) // R_(fexp#0), F);
    gcoef := lift(sub(g0, R) // R_(gexp#0), F);
    ddexp := fexp - gexp;
    ddmon := sub(R_(ddexp#0), D);
    -- return the S-pair
    sub(f, R) - fcoef / gcoef * sub(ddmon * g, R))

reduce = method()
reduce(List, RingElement, RingElement) := (w, f, g) -> (
    sum(terms f, m -> reduceLeadTerm(w, m, g))
    )

end--
restart
needs "reduce.m2"
S = QQ[x,y]
D = makeWA(S)
R = rationalWeylAlgebra(S)
f = dx^2
f = ((x+y)*dx)
g = x*dx+1
w = {0,0,1,1}
reduce(w, f, g)
leadTerm inw(x*dx+y*dy,w)
