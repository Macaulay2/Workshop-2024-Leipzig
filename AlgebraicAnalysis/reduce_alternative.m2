needs "pfaffians.m2"


-- ALTERNATIVE IMPLEMENTATION (Any Groebner basis) --




-- Reduction Step in R (Rational Weyl Algebra) --
-- Input:
--     w - weight vector (0, v), v \in R^n_{>0}
--     f - Differential Operator in R
--     g - Differential Operator in D (e.g. element of Gröbner basis)
-- Output:
--    Remainder of f w.r.t. g and term order (<_reflex, degree-weighted by w) 
reduceStep = method()
reduceStep(List, RingElement, RingElement) := (w, f, g) -> (
	-- Get initial term in R of f and g

	-- If divisible, i.e. in(g) | in(f)
	-- -> Reduce
	-- Else:
	-- -> Return f
    )


-- Extract Initial Term in R (Rat. Weyl Algebra) --




end--
restart

-- Example to work with alternative implementation --

S = QQ[x,y] -- Coefficient Ring 
D = makeWA(S) -- Weyl Algebra

K = fractionField(D) -- Fraction field Q(x,y)

R = rationalWeylAlgebra(S) -- Rational Weyl Algbra

f = (1/x)*dx + (1/y)*dy
g = x*d
