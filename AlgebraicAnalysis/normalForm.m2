debug needsPackage "Dmodules"

-- fraction field K(x) of a Weyl algebra K[x,dx]/(...)
fractionField = memoize(D -> frac extractVarsAlgebra D)

-- graded associative ring of the rational Weyl algebra
-- Used for bookkeeping elements in R
rationalWeylAlgebra = memoize(D -> (fractionField D)(monoid[D.dpairVars#1,MonomialOrder=>{Weights=>{2,1},RevLex}, Global => false]))

-- reduce the lead term in rational Weyl algebra R
normalForm = method()
-- weightorder, f in D, g in D, SST page 7
normalForm(List, RingElement, RingElement) := (w, f, g) -> (
    if f == 0 then return f;
    D := ring g;
    n := numgens D // 2;
    F := fractionField D;
    R := rationalWeylAlgebra D;
    f0 := leadTerm(f);
    g0 := leadTerm(g);
    fexp := (exponents f0)#0;
    gexp := (last pack_n (exponents g0)#0);
    --if not (gexp << fexp) then return f0 + normalForm(w,f-f0,g);
    if not (gexp << fexp) then return f;
    fcoef := lift(f0 // R_(fexp), F);
    --gcoef := lift(sub(g0, R) // R_(gexp), F);
    gcoef := lift(leadTerm(sub(g, R)) // R_(gexp), F);
    ddexp := fexp - gexp;
    ddmon := sub(R_(ddexp), D);
    -- recurse to normalize the lower order terms
    normalForm(w,f - fcoef / gcoef * sub(ddmon * g, R),g)
    )

normalForm(List, RingElement, List) := (w, f, G) -> (
    if f == 0 then return f;
    f0 := leadTerm(f);
    scan(G, g -> f=normalForm(w,f,g));
    if leadTerm(f) == f0 then return f0 + normalForm(w,f-f0,G);
    f)

end--
restart

needs "normalForm.m2"
-- NEED TO ALSO CHANGE WEIGHTS IN DEFINITION OF R

-- Examples for testing with Pfaffian matrices
-- Example 1.3: w = (0,0,2,1) ----> DOESNT EQUAL CALCULATIONS
D = QQ[x,y,dx,dy, WeylAlgebra =>{x=>dx,y=>dy},MonomialOrder=>{Weights=>{0,0,2,1}, RevLex}, Global => false]
I = ideal(x*dx^2-y*dy^2+dx-dy,x*dx+y*dy+1)
R = rationalWeylAlgebra D
G = gb I
leadTerm(I) 
-- P1:
-- first row P1 -- EQUAL
normalForm({0,0,2,1},dx_R,flatten entries gens G)
-- second row P1 -- NOT EQUAL
normalForm({0,0,2,1},dx_R*dy_R,flatten entries gens G)
-- P2:
-- first row P2 -- EQUAL
normalForm({0,0,2,1},dy_R,flatten entries gens G)
-- second row P2 -- NOT EQUAL
normalForm({0,0,2,1},dy_R^2,flatten entries gens G)

-------------------------------------------------------------------------------------

-- Example 1.3: w = (0,0,1,2) ----> EQUALS CALCULTIONS
D = QQ[x,y,dx,dy, WeylAlgebra =>{x=>dx,y=>dy},MonomialOrder=>{Weights=>{0,0,1,2}, RevLex}, Global => false]
I = ideal(x*dx^2-y*dy^2+dx-dy,x*dx+y*dy+1)
R = rationalWeylAlgebra D
G = gb I
leadTerm(I) 
-- P1:
-- first row P1 -- EQUAL
normalForm({0,0,1,2},dx_R,flatten entries gens G)
-- second row P1 -- EQUAL
normalForm({0,0,1,2},dx_R^2,flatten entries gens G)
-- P2:
-- first row P2 -- EQUAL
normalForm({0,0,1,2},dy_R,flatten entries gens G)
-- second row P2 -- EQUAL
normalForm({0,0,1,2},dx_R*dy_R,flatten entries gens G)

-----------------------------------------------------------------------------------

-- Example 1.3: w = (0,0,2,1) ----> EQUALS CALCULTIONS
D = QQ[x,y,dx,dy, WeylAlgebra =>{x=>dx,y=>dy},MonomialOrder=>{Weights=>{0,0,2,1}, RevLex}, Global => false]
I = ideal(x*dx^2-y*dy^2+2*dx-2*dy,x*dx+y*dy+1)
R = rationalWeylAlgebra D
G = gb I
leadTerm(I) 
-- P1:
-- first row P1 -- EQUAL
normalForm({0,0,2,1},dx_R,flatten entries gens G)
-- second row P1 -- EQUAL
normalForm({0,0,2,1},dx_R*dy_R,flatten entries gens G)
-- P2:
-- first row P2 -- EQUAL
normalForm({0,0,2,1},dy_R,flatten entries gens G)
-- second row P2 -- EQUAL
normalForm({0,0,2,1},dy_R^2,flatten entries gens G)

---------------------------------------------------------------------------

-- Example 1.3: w = (0,0,1,2) ----> EQUALS CALCULATIONS
D = QQ[x,y,dx,dy, WeylAlgebra =>{x=>dx,y=>dy},MonomialOrder=>{Weights=>{0,0,1,2}, RevLex}, Global => false]
I = ideal(x*dx^2-y*dy^2+2*dx-2*dy,x*dx+y*dy+1)
R = rationalWeylAlgebra D
G = gb I
leadTerm(I) 
-- P1:
-- first row P1 -- EQUAL
normalForm({0,0,1,2},dx_R,flatten entries gens G)
-- second row P1 -- EQUAL
normalForm({0,0,1,2},dx_R^2,flatten entries gens G)
-- P2:
-- first row P2 -- EQUAL
normalForm({0,0,1,2},dy_R,flatten entries gens G)
-- second row P2 -- EQUAL
normalForm({0,0,1,2},dx_R*dy_R,flatten entries gens G)