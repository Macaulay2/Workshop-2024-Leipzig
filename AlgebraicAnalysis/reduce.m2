debug needsPackage "Dmodules"

-- fraction field K(x) of a Weyl algebra K[x,dx]/(...)
fractionField = memoize(D -> frac extractVarsAlgebra D)

-- graded associative ring of the rational Weyl algebra
-- Used for bookkeeping elements in R
rationalWeylAlgebra = memoize(D -> (fractionField D)(monoid[D.dpairVars#1,MonomialOrder=>{Weights=>{2,1}, RevLex}, Global => false]))

-- reduce the lead term in rational Weyl algebra R
-- TODO: Write function for Gröbner Basis
normalForm = method()
-- weightorder, f in D, g in D, SST page 7
normalForm(List, RingElement, RingElement) := (w, f, g) -> (
    if f == 0 then return f;
    D := ring g;
    n := numgens D // 2;
    F := fractionField D;
    R := rationalWeylAlgebra D;
    --wR := last pack_n w;
    -- surprisingly inw works for elements of rational Weyl Algebra
    --f := sub(f,R);
    f0 := leadTerm(f);
    g0 := leadTerm(g);
    --f0 := inw(f,wR);
    -- need it to be in D to perform derivative
    --g0 := inw(g,w);   
    -- g0 get exponent vector
    -- pack_n is interior product with n
    --fexp := unique exponents f0;
    --gexp := unique apply(exponents g0, e -> last pack_n e);
    fexp := (exponents f0)#0;
    gexp := (last pack_n (exponents g0)#0);
    --gexp := unique exponents g0;
    --have to use RevLex!!!
    --sortedListfin := sort(apply(fexp, e -> R_e));
    --sortedListfin := sort(terms(f0));
    --sortedListgin := sort(apply(gexp, e -> D_e));
    --sortedListgin := sort(terms(g0));
    --fin := sortedListfin#0;
    --gin := sortedListgin#0;
    --finexp := (exponents fin)#0;
    --ginexp := last pack_n (exponents gin)#0;
    --if #fexp > 1 or #gexp > 1 then error "expected generic weight order";
    -- if gin does not divide fin, no reduction is necessary
    -- RECURSION
    if not (gexp << fexp) then return f0 + normalForm(w,f-f0,g);
    -- compare weights of leading monomials
    --fwt := sum(fexp#0, last pack_n w, times);
    --gwt := sum(gexp#0, last pack_n w, times);
    --if fwt < gwt then return f;
    fcoef := lift(f0 // R_(fexp), F);
    gcoef := lift(sub(g0, R) // R_(gexp), F);
    ddexp := fexp - gexp;
    ddmon := sub(R_(ddexp), D);
    -- recurse to normalize the lower order terms
    normalForm(w,f - fcoef / gcoef * sub(ddmon * g, R),g)
    )

normalForm(List, RingElement, List) := (w, f, G) -> (
    scan(G, g -> f=normalForm(w,f,g));
    f)

end--
restart

needs "reduce.m2"
S = QQ[x,y]
D = makeWA(S)
R = rationalWeylAlgebra D
--D = newRing(E,MonomialOrder=>{Weights => {0,0,1,1}, GRevLex})
--f = dx^2
--f = ((x+y)*dx)
--g = x*dx+1
w = {0,0,1,1}
reduce(w, f, g)
leadTerm inw(x*dx+y*dy,w)

--new Example

f2 = (x_R)^(-1)*dx_R + (y_R)^(-1)*dy_R
f = (x_R)^(-4)*dx_R^2 + (y_R)^(-1)*dy_R
use D
g = (x+y)*dy
h = (x_R+y_R)^(-1)*dx_R^2+x_R^(-1)*dx_R*dy_R
h0 = inw(h,wR)
terms(h0)
use D
D = QQ[x,y,dx,dy, WeylAlgebra =>{x=>dx,y=>dy},MonomialOrder=>{Weights=>{0,0,2,1}, RevLex}, Global => false]
I = ideal(x*dx^2-y*dy^2+dx-dy,x*dx+y*dy+1)
R = rationalWeylAlgebra D
G = gb I
leadTerm(I)
normalForm({0,0,1,2},dx_R,flatten entries gens G)
normalForm({0,0,2,1},dy_R^2,flatten entries gens G)
assert ((x_R)^(-4)*dx_R^2 == normalForm({0,0,1,1},f,g))
assert((x_R)^(-4)*dx_R^2 == normalForm({0,0,5,1},f,g))
assert(y_R^(-1)*dy_R == normalForm({0,0,4,17},(x_R)^(-4)*dx_R^2+y_R^(-1)*dy_R,7*dx))
assert(-dy_R == normalForm({0,0,5,4},(x_R)^(-4)*dx_R^5+y_R^(-1)*dx_R^3-dy_R,7*dx))
assert(0 == normalForm({0,0,4,17},(x_R)^(-4)*dx_R^2+y_R^(-1)*dy_R,{7*dx,dy}))
assert((x_R)^(-4)*dx_R^2+y_R^(-1)*dy_R == normalForm({0,0,1,1},(x_R)^(-4)*dx_R^2+y_R^(-1)*dy_R,{x^2*dx*dy-5*x*dx+8,x*dx^2*dy^3-dx*dy^2}))
f = 2*x_R^(-2)
w = {0,0,2,1}
g = (flatten entries gens G)#1