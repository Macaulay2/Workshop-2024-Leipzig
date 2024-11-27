needsPackage "NCAlgebra"

-----------------------------------------
--Signature of a linear path
--u is a vector correspongding to the increment of the path
--w is a list representing a word
-----------------------------------------
linsig = method()
linsig (List, List) := QQ => (u, w)-> (
    h := length (w);
    if h==0 then (return(1));
    product(h, i-> u#(w#i-1))/(h!)
)


-----------------------------------------
--Signature of a piecewise linear path
--Build calling recursively linsig
--M is a list of increments as in linsig, 
--w is a word, as in linsig
-----------------------------------------
pwlsigw = method()
pwlsigw (List, List) := QQ => (M, w)-> (
    h := length (w); 
    m := length(M);

    --base case
    if(m==1) then return linsig(M#0,w);     
    
    --matrix check
    if not(isMatrix(M)) then(               
        error("Expected list representing matrix, got list of lists of lengths:",for i from 0 to length(M)-1 list length(M_i)) ;
    );

    -- First m-1 pieces
    Mrec := M_{0..m-2};
    -- last piece
    Mlast := M#(m-1);

    sum(h+1, i -> (
        pwlsigw(Mrec, w_{0..i-1})*linsig(Mlast,w_{i..h-1}))
    )
);


----------------------------------------
--Checks if a list represents a matrix
----------------------------------------
isMatrix = method()
isMatrix (List) := Boolean => M ->(
    lens := for i from 0 to length(M)-1 list length(M_i); 
    if(#(set(lens))>1) then(
        return false 
    );
    return true
)

------------------------------------
--This function converts a NC monomial to a list representing the corresponding word
--f is a monomial in an NCring
--The output is a list representing the word, as in linsig
-------------------------------------

ncMonToVar = method()
ncMonToVar (NCRingElement) := List => f -> (
    fmons = keys f.terms;
    monKey = (keys fmons#0)#1;
    (fmons#0)#(monKey)
);

ncMonToList = method()
ncMonToList (NCRingElement) := List => f -> (
    fmons = keys f.terms;
    monKey = (keys fmons#0)#1;
    (fmons#0)#(monKey) / ( i -> last baseName i)
);

--This is used to extend functions on words to the whole non commutative polynomial algebra
linExt = method();
linExt(FunctionClosure, NCRingElement) := RingElement => (fun, w) -> (
    lot := apply(terms w, i -> {leadCoefficient i, ncMonToList(i)});
    sum(length(lot),i->(lot#i)#0 * fun((lot#i)#1))
)

--------------------------------------
--The following function computes the signature of a piecewise linear path
--The increments of the segments are given by the columns of the matrix M
--The non-commutative polynomial is given as an element w of a NCRing
--------------------------------------
pwlsig = method();
pwlsig (Matrix, NCRingElement) := QQ => (M, w)-> (
    Mentries = entries M;
    linExt(i->pwlsigw(Mentries,i),w)
);

--------------------------------------
--polyIntegral computes integrals of polynomials with respect to one variable
--f is the integrand
--xn is a generator of the base ring
--------------------------------------
polyIntegral = method()
polyIntegral (RingElement, RingElement) := RingElement => (f, xn) ->(
    R := ring f;
    indexn := index xn;
    termsf := terms f;
    return sum(apply(termsf, i->(
        i = i/((((exponents(i))#0)#(indexn)+1));
        i= i* xn
    )))
);

-------------------------------------
--polySigGen computes the signature of a polynomial path for words
-- l is the list of components of the polynomial path, each represented by a list
-- Here, a polynomial \sum a_i x^i is represented by {a_0,a_1,...}
-- w is a list representing a word as in linsig
-- br is the base ring of the coefficients
-------------------------------------
polySigGen = method()

polySigGen (List, List, Ring) := RingElement => (l, w, bR) ->(
    k:= length w;
    x := getSymbol "t";
    R := bR[x_1..x_k];
    S := bR[s];
    X := apply(l, i-> sum(1..length(i)-1, j -> (i#j)_S * s^j));

    res:= product for i from 1 to k list (
        comp := X#(w#(i-1)-1);
        if(comp == 0) then 0_R else sub(diff(s,comp), {s => R_(i-1)})
        );
    
    for i from 1 to k-1 do (
        indefinite := sub(polyIntegral(res, R_(i-1)),R);
        eval0 := substitute(indefinite, {R_(i-1) => 0_QQ});
        eval1:= substitute (indefinite, {R_(i-1) => R_(i)}); --(if i<n then t_{i+1} else 1_R)
        res = eval1-eval0;
        );
    res = sub(polyIntegral(res, R_(k-1)),R);
    res = substitute(res, {R_(k-1) => 1_QQ}) - substitute(res, {R_(k-1) =>0_QQ});
    return leadCoefficient res
);

---------------------------------------------
--polysig  computes the signature of a polynomial path for nc polynomials, similar to pwlsig for pwl paths
--CAVEAT: do not use variable names s or t when calling this function. TODO: solve this
--------------------------------------------
polysig = method(Options=>{BaseRing => QQ});

polysig (List, NCRingElement) := QQ => opts -> (l, w) -> (
    linExt(i->polySigGen(l,i,opts.BaseRing),w)
);

errorDepth = 0;

end
restart
load("signatures_wip.m2")


TEST ///
R = QQ{l_1..l_5};
f = 1/2*(l_1*l_2 - l_2*l_1);
A = QQ[a_1,a_2,a_3]

<<<<<<< HEAD
r =polysig({{0,a_1},{0,a_2,a_3}},f, BaseRing => A)
assert(r == 1/6*a_1*a_3) 
///




matrixAction = method()
matrixAction (Matrix,  NCRingElement, NCRing) := NCRingElement => (M,  p, B) -> (
    --if #(gens B) != 

    m= #entries M;
    N=entries transpose M;
    h=#entries transpose(M);
    print(apply(N, j->sum(length(j)-1, i->j#i*(gens B)#i)));

    f = ncMap(B, p.ring , apply(N, j->sum(length(j), i->j#i*(gens B)#i)));
    f(p)

)
