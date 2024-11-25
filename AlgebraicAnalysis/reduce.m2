needs "pfaffians.m2"

-- reduce in rational Weyl algebra R
reduce = method()
-- weightorder, f in D, g in D
reduce(List,RingElement,RingElement) := (w,f,g) -> (
    D := ring f
    n := numgens D // 2
    -- need to think about tiebreaker
    -- generic w
    f0 := inw(f,w)
    g0 := inw(g,w)
    -- get exponent vector
    -- pack_n is interior product with n
    fexp := unique apply(exponents f0, e -> last pack_n e)
    gexp := unique apply(exponents g0, e -> last pack_n e)
    -- TODO compare w weights of leading monomials
    sum(fexp,last pack_n w,times)

    -- lex comparison on dx_i
    if fexp < gexp then return f
    else 
    )


end--
restart
needs "reduce.m2"
S = QQ[x,y]
D = makeWA(S)
f = ((x+y)*dx)
g = x*dx+1
w = {0,0,1,1}
leadTerm inw(x*dx+y*dy,w)
