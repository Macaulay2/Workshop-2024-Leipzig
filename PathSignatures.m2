newPackage("PathSignatures",
         Version => "1.0",
         Authors => {{Name => "Felix Lotter"}, {Name => "Oriol Reig"}, {Name => "Angelo El Saliby"}},
         Headline => "A package for working with signatures of algebraic paths",
         AuxiliaryFiles => true,
         PackageExports => {"NCAlgebra", "Permutations"}
);
export {
    --types
    "Path",
    --methods
    "sig",
    "polyPath",
    "linPath",
    "pwLinPath",
    "matrixAction",
    "CAxisTensor",
    "CMonTensor",
    "createMapFromCoreTensor",
    "tensorParametrization",
    "wordAlgebra",
    "signedVolume",
    "shuffle",
    "halfshuffle",
    "wordFormat",
    "wordString",
    -- symbols
    "BaseRing",
    "adjointWord",
    "tensorArray",
    "inner",
    "lyndonWords",
    "lie",
    "lieBasis",
    "tensorExp"
    -- "type",
    -- "pieces",
    -- "dimension",
    -- "numberOfPieces",
    -- "bR"
};

exportFrom("NCAlgebra",{"NCRingElement", "NCPolynomialRing"})

protect type
protect pieces
protect dimension
protect numberOfPieces
protect bR



Path = new Type of MutableHashTable

sig = method()

sig (Path, List) := QQ => (X,w) -> ( --This doesn't need to be exposed
    nop := X.numberOfPieces;
    h := length(w);
    if(w == {}) then return 1;
    if(nop == 0) then return 0;
    if(nop == 1) then (
        return(polySigGen(X.pieces#0,w,X.bR))
    );
    sum(h+1, i -> (
        sig(X_(0..nop-2), w_{0..i-1})*sig(X_(nop-1),w_{i..h-1}))
    )
)

sig(Path,NCRingElement) := QQ => (X,f) -> (
    return(linExt(w->sig(X,w),f));
)

sig(Path,ZZ,NCRing) := QQ => (X, h, R) -> (
    nop := X.numberOfPieces;
    d := X.dimension;
    if(h == 0) then return 1_R;
    if(nop == 0) then return 0;
    if(nop == 1) then (
        ws := toList(apply((h:1)..(h:d), toList));
        return(sum(ws,w-> polySigGen(X.pieces#0,w,X.bR)*(new Array from w)_R));
    );
    sum(h+1, i -> (
        sig(X_(0..nop-2), i, R)*sig(X_(nop-1),h-i, R))
    )
)

--Compute the signature in level h of a path X
sig(Path,ZZ) := (X,h) ->
(
    R := wordAlgebra(X.dimension, BaseRing => X.bR);
    sig(X,h,R)
)

TEST ///
R = QQ{symbol s_1..symbol s_5};
f = 1/2*(s_1*s_2 - s_2*s_1);
A = QQ[symbol x_1..symbol x_3]

pR = A[t];
X = polyPath({0,x_2*t^2}) ** polyPath({x_3*t^3 + 3*t, t^2 - 1})
--The issue with 0 components was fixed by changing the polyPath generator
<<<<<<< HEAD
r = sig(X,f,BaseRing => A)
///

-- TEST ///
-- bR = QQ[t]
-- X= linPath({0,0,0,1})
-- Y= polyPath({0,0,0,1}) --Gives error
-- Z= X**Y

-- wR = QQ{x_1..x_4}
-- w= x_4
-- assert(sig(Z, w)==pwlSig(X, w))
-- ///
--globalAssignment Path

------------------------------------------------
--Defining the Type "Path" as a subclass of MutableHashTable.
--It should be able to allow for concatenation of piecewise linear
--and polynomial paths and to correctly call the functions
--already implemented depending on the type of path.
--To allow for better integration, it will have two subclasses:
--PolyPath, reserved for paths given in polynomial form
--LinPath, reserved for paths given through the articulation points.
--A Path will then be an (ordered) list of LinPaths and PolyPaths

-- Methods to implement:
    -- "+": Component-wise sum of paths
    -- "*": concatenation of paths
    -- "==": check whether two paths are equal (this could be hard)
    -- Latex export of a path
    -- override the "display" command (look into "net" class)
    --
    -- ... other suggestions
    -- 

-- I think there is already a way to do this but i could not find it
-- I think 'pairs' does what you want!
enumerate = L -> toList apply(0..(#L - 1), i -> {i, L#i});

--Basic checks to verify if a list is the listForm of a polynomial
isListForm = method(); 
isListForm Thing := (L) ->(
    if not(instance(L, List)) or not(instance(L#0, Sequence)) or not(instance(L#0#0, List))  then return false;
    l := length(L#0#0);
    c := L#0#(-1);
    if not(instance(c, Number)) and not(instance(c, RingElement)) then return false;
    apply(L, i-> 
        if length(i#0)!=l or (not(instance(i#(-1), Number)) and not(instance(#i(-1), RingElement))) then return false);
    return true
);

--A piecewise polynomial path
--polyPath takes a list of polynomials in some variable and constructs the corresponding polynomial path from it
--the polynomials can be given as actual polynomials or directly in listForm

polyPath = method();
polyPath List := (polyPathList) -> (
    if(polyPathList === {}) then return new Path from {pieces => {}, dimension => -1, numberOfPieces => 0};

    if isListForm (polyPathList#0) then (
        apply(polyPathList, i-> if not(isListForm(i)) then error("The input was neither a list of polynomials nor a list of polynomials in listForm"));
        return new Path from{
            pieces => {polyPathList},
            dimension => length polyPathList,
            numberOfPieces => 1,
            bR => class (product apply(polyPathList, i -> i#0#(-1)))
        };
        );

    if (instance(product(polyPathList), RingElement)) then (
        tR := class product(polyPathList);
        if(#gens(tR) != 1) then error("Expected a vector of polynomials in one variable.");
        baseR := coefficientRing (tR); --Consider taking this as input
        P := new Path from{
            bR => baseR,
            pieces => {apply(polyPathList,i-> listForm (i*1_baseR))},
            dimension => length polyPathList,
            numberOfPieces => 1
        };
        return(P);
    );
)

--Take parts of a path

Path _ List := (X, l) -> (
    if(l === {}) then return polyPath({});
    P := new Path from{
        bR => X.bR,
        pieces => (X.pieces)_l,
        dimension => X.dimension,
        numberOfPieces => length(l)
    };
    return P;
)

Path _ Sequence := (X,l) -> (
    return X_(toList l);
)

Path _ ZZ := (X, z) -> (
    return X_{z};
)

-- Concatenation of paths

sub(Path,Ring) := (X,R) -> (
    npieces := X.pieces;
    npieces = apply(npieces, polvec -> apply(polvec, pol -> apply(pol, mon -> (mon#0, sub(mon#1,R)))));
    P := new Path from{
        bR => R,
        pieces => npieces,
        dimension => X.dimension,
        numberOfPieces => X.numberOfPieces
    };
    return(P);
);

Path ** Path := Path => (X,Y) -> (
    if(X.dimension != Y.dimension) then error("Can not concatenate paths of different ambient dimension.");
    R := if((X.bR === Y.bR)) then X.bR else (
        if (isMember(Y.bR, (X.bR).baseRings)) then (
            Y = sub(Y,X.bR); return(X ** Y);
        ) else if (isMember(X.bR, (Y.bR).baseRings)) then (
            X = sub(X, Y.bR); return(X ** Y);
        ) else if (coefficientRing X.bR === coefficientRing Y.bR) then  (
            nR := X.bR ** Y.bR;
            return(sub(X,nR)**sub(Y,nR));
         )
        else error("The base rings 'bR' of the two paths were different, namely they were X.bR = ", toString X.bR, " and Y.bR = ", toString Y.bR, ". Moreover no trivial relation between them was found.");
    );
    -- -- 
    
    P := new Path from{
        bR => X.bR,
        pieces => X.pieces | Y.pieces,
        dimension => X.dimension,
        numberOfPieces => X.numberOfPieces + Y.numberOfPieces
    };
    return P;
)

-- TODO: implement path reversal
Path ^ ZZ := (X,n) -> (
    fold(n:X, (X,Y) -> X**Y)
)
-- TEST ///
-- pR = QQ[t];
-- X = polyPath({t,t^2})
-- Y = polyPath({t,t^2})

-- <<<<<<< HEAD
-- X**Y
-- ///


net Path := (X) ->
(
    myNet := net ("Path in " | X.dimension | "-dimensional space with " | X.numberOfPieces | (if(X.numberOfPieces == 1) then " polynomial segment:" else " polynomial segments:") );
    t:= getSymbol("t");
    locR := X.bR [local t];
    pieces := apply(X.pieces,l->
        apply(l,
            p-> sum(p, 
                i-> i#1*t^(i#0#0)
                )
            )
        );
    myNet = myNet || "" || (net pieces);
    return(myNet)
)

-- foo = method(Options=>{BaseRing => QQ})
-- foo(List,List) := (l,g)->(l|g);
-- foo(Path,List) := (l,g)->(l_g);

-- The general method for computing the signature of a piecewise polynomial path


--Constructs the linear polynomial path t*v for a vector v
linPath = method();
linPath List := Path => (v) ->(
    baseR := class product(v); 
    if(baseR === ZZ) then (baseR = QQ);
    new Path from{
        bR => baseR,
        pieces => {apply(v,i->{({1},i)})},
        dimension => #v,
        numberOfPieces => 1
    }
)

pwLinPath = method();
--Constructs a pw linear path from a given matrix of increments
pwLinPath Matrix := (pwlMatrix) -> (
    pathList := apply(transpose entries pwlMatrix, i-> linPath(i));
    return(fold(pathList,(i,j)->i**j));
)

TEST ///
R= QQ[t];


p = polyPath({t, t^2});
assert(p#"type" === "PPolynomial", "p should be a polynomial path");
assert(keys(p#"pieces") === {0}, "p should have one piece");
assert(p#"dimension" === 2, "p should be 2-dimensional");

pp = polyPath({ {t, t^2}, {t^3, t^4} });
assert(pp#"type" === "PPolynomial", "pp should be a piecewise polynomial path");
assert(keys(pp#"pieces") === {0,1}, "pp should have pieces with keys 0 and 1");
assert(pp#"dimension" === 2, "pp should be 2-dimensional");

///


-- linToPoly = method(Options => {polyRing => QQ[local t] });
-- linToPoly Path := Path => opts -> p -> (
--     if p#'type' == 
-- )



-- Path"+" = (p,q) -> (
--     --For now assuming p, q have the same number of pieces 

-- )


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
-- pwlsigw = method()
-- pwlsigw (List, List) := QQ => (M, w, baseR)-> (
--     h := length (w); 
--     m := length(M);

--     --base case
--     if(m==1) then return linsig(M#0,w);     
    
--     --matrix check
--     if not(isMatrix(M)) then(               
--         error("Expected list representing matrix, got list of lists of lengths:",for i from 0 to length(M)-1 list length(M_i)) ;
--     );

--     -- First m-1 pieces
--     Mrec := M_{0..m-2};
--     -- last piece
--     Mlast := M#(m-1);

--     sum(h+1, i -> (
--         pwlsigw(Mrec, w_{0..i-1})*linsig(Mlast,w_{i..h-1}))
--     )
-- );


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


ncMonToVar = method()
ncMonToVar (NCRingElement) := List => f -> (
    fmons := keys f.terms;
    monKey := (keys fmons#0)#1;
    (fmons#0)#(monKey)
);

------------------------------------
--coefficientHTable returns a Hash table associating the monomials in a nc polynomial to their coefficients
--this is not the same as f.terms, which associated the NCMonomials (an inaccessible type) in f to their coefficients
-------------------------------------
coefficientHTable = method()
coefficientHTable (NCRingElement) := HashTable => f -> (
        fterms := terms f;
        hashTable(apply(fterms, i -> {leadMonomial i, leadCoefficient i}))
);

--Returns the index of a variable given as an element of a NCRing
varIndex = method()
varIndex(NCRingElement) := List => (var) -> (
    tbl := hashTable toList(apply(pairs var.ring.generators, (i,j)->(j,i)));
    return tbl#var
)

------------------------------------
--This function converts a NC monomial to a list representing the corresponding word
--f is a monomial in an NCring
--The output is a list representing the word, as in linsig
-------------------------------------

ncMonToList = method()
ncMonToList (NCRingElement) := List => f -> (
    fmons := keys f.terms;
    monKey := (keys fmons#0)#1;
    R := ring f;
    varst := hashTable(toList apply(0..length(gens R)-1, i-> (baseName R_i,i+1)));
    (fmons#0)#(monKey) / ( i -> varst#i)
);

------------------------------------
--This function converts a list to the corresponding monomial in an NCring
-------------------------------------

toNCMon = method()
toNCMon (List, NCRing) := (w,R) -> (
    return(product(w,i->R_(i-1)));
);


--------------------------------
--wordRingAndValues takes an nc polynomial f and returns a ring wR and a list vals of elements in the base ring of f
-- For every monomial m in f, it creates a new variable v_m. The ring wR is the free commutative QQ-algebra in the variables v_m.
-- The coefficients of these monomials in f are stored in vals, in such a way that the index of v_m in R agrees with the position of the coefficient of m in vals
-- (TODO: add option for different variable name in wR.)
--------------------------------
wordRingAndValues = method(Options => {BaseRing => QQ})
wordRingAndValues(NCRingElement) := (Ring,List) => opts -> f -> (
        htable := coefficientHTable(f);
        whtable := applyKeys(htable, ncMonToList);
        v := getSymbol("v");
        vs := new Array from apply(keys whtable, i-> v_(toSequence(i)));
        wR := opts.BaseRing vs;
        vals := values whtable;
       return((wR,vals))
)

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
-- pwlsig = method();
-- pwlsig (Matrix, NCRingElement) := QQ => (M, w)-> (
--     Mentries := entries M;
--     linExt(i->pwlsigw(Mentries,i),w)
-- );


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
    return sum(termsf, i->(1_R/(((((exponents(i))#0)#(indexn)+1))) * i * xn))
);


-------------------------------------
--polySigGen computes the signature of a polynomial path for words
-- l is the list of components of the polynomial path, each represented by a list
-- Here, a polynomial is represented by its list form, see M2 documentation for listForm
-- w is a list representing a word as in linsig
-- br is the base ring of the coefficients
-------------------------------------
polySigGen = method()

polySigGen (List, List, Ring) := RingElement => (l,w, baseR) ->(
    if(w == {}) then return 1;

    k:= length w;
    x := getSymbol("x");
    R := baseR monoid([x_1..x_k]);
    s := getSymbol("s");
    S := baseR monoid([s]);
    X := apply(l, i-> sum(0..length(i)-1, j -> ((i#j)#1)_S * (S_0)^((i#j)#0#0)));

    resd := product for i from 1 to k list (
        comp := X#(w#(i-1)-1);
        if(comp == 0) then 0_R else sub(sub(diff(S_0,comp),S), {S_0 => R_(i-1)})
        );
    
    for i from 1 to k-1 do (
        indefinite := sub(polyIntegral(resd, R_(i-1)),R);
        eval0 := substitute(indefinite, {R_(i-1) => 0_QQ});
        eval1:= substitute (indefinite, {R_(i-1) => R_(i)}); --(if i<n then t_{i+1} else 1_R)
        resd = eval1-eval0;
        );
    resd = sub(polyIntegral(resd, R_(k-1)),R);
    --use(baseR);
    resd = substitute(resd, {R_(k-1) => 1_baseR}) - substitute(resd, {R_(k-1) =>0_baseR});
    return (if class resd === baseR then resd else leadCoefficient resd)
);

---------------------------------------------
--polysig  computes the signature of a polynomial path for nc polynomials, similar to pwlsig for pwl paths
--CAVEAT: do not use variable names s or t when calling this function. TODO: solve this
--------------------------------------------
-- polysig = method(Options=>{BaseRing => QQ});

-- polysig (List, NCRingElement) := QQ => opts -> (l, w) -> (
--     linExt(i->polySigGen(l,i,opts.BaseRing),w)
-- );

-- errorDepth = 0;


TEST ///
R = QQ{s_1..s_5};
f = 1/2*(s_1*s_2 - s_2*s_1);
A = QQ[x_1,x_2,x_3]

<<<<<<< HEAD
r = polysig({ {({1},0)} , {({1},x_2),({2},x_3)} },f, BaseRing => A)
assert(r == 1/6*x_1*x_3) 
///


----------------------------------------------------------------------------
-- Draft of equivariance action
-- Consider outputing the NCringmap instead of computing it on 
-- an element
----------------------------------------------------------------------------

matrixAction = method()
matrixAction (Matrix,  NCRingElement, NCRing) := NCRingElement => (M,  p, B) -> (
    --if #(gens B) != 
    N :=transpose entries M;
    f := ncMap(B, ring p, apply(N, j->sum(length(j), i->j#i*(gens B)#i)));
    f(p)
)

----------------
-- Matrix * Tensor gives the result of the diagonal action of the matrix on the tensor
----------------

Matrix * NCRingElement := (M, f) -> (
    n := length entries M;
    m := length entries transpose M;
    tf := length gens ring f;
    if(m != tf) then (error("A " | toString(n) | "x" | toString(m) | " matrix can not act on a tensor over " | toString(tf) | "-dimensional space.");)
    else (
    t := new IndexedVariableTable;
    B := (coefficientRing ring f){local t_1..local t_n};
    return(matrixAction(M, f, B));)
)

----------------------------------------------------------------------------
-- Hard coded canonical axis path tensor simple compoents as in 
-- Example 2.1 of "varieties of signature tensors" 
-- C. Amendola et al, 2018
--Inputs: 
--  w, a word in a NCpolynomial ring 
----------------------------------------------------------------------------

CAxisComponent= method();

CAxisComponent (NCRingElement) := QQ => w -> (
    L := ncMonToList (w);
    if(L!=sort(L)) then return 0;
    distinctPermutations := (#L)!/(product( apply(values tally L, i-> i !)));
    distinctPermutations/((#L))!
);

----------------------------------------------------------------------------
-- Hard coded canonical moment path tensor simple components as in 
-- Example 2.3 of "varieties of signature tensors" 
-- C. Amendola et al, 2018
--Inputs: 
--  w, a word in a NCpolynomial ring
----------------------------------------------------------------------------

CMonComponent= method();

CMonComponent (NCRingElement) := QQ => w -> (
    L := ncMonToList (w);
    product(L_{1..length(L)-1})/product(accumulate(plus,L))
);

CAxisTensor = method();
CAxisTensor(ZZ, NCPolynomialRing) := NCRingElement => (k,r) -> (
    sum(apply((entries basis(k,r))#0, i-> CAxisComponent(i) * i))
)

CMonTensor = method();
CMonTensor(ZZ, NCPolynomialRing) := NCRingElement => (k,r) -> (
    sum(apply((entries basis(k,r))#0, i-> CMonComponent(i) * i))
)


-----------------------------------------------------------------------
--createMapFromCoreTensor takes a core tensor f and a target ambient 
--dimension and constructs the associated map of varieties
-----------------------------------------------------------------------

createMapFromCoreTensor = method(Options=>{BaseRing => QQ});
createMapFromCoreTensor(NCRingElement, ZZ) := NCRingElement => opts -> (f,ambd) -> (
    a := getSymbol "a";
    lamb := getSymbol "lamb";
    ctd := #gens f.ring; -- if core tensor is element of (R^d)^{tensor k}, this is d
    mR := (opts.BaseRing)[a_(1,1)..a_(ctd,ambd)]; -- create coordinate ring of matrix space
    A := genericMatrix(mR,ambd,ctd); -- create generic matrix
    ncR2 := mR{(lamb)_1..(lamb)_ambd}; -- create tensor algebra over ambient vector space
    genTensor := matrixAction(A, f, ncR2); -- create generic tensor
    (wR,rmap) := wordRingAndValues(genTensor,BaseRing=>opts.BaseRing); -- get target ring and components of ring map
    map(mR, wR, rmap) -- create the map from word ring to matrix ring via rmap
)

-- tensorParametrization takes a tensor T, constructs a ring R with one variable for each word appearing in T and creates the map that sends a variable to the coefficient of the corresponding word.
-- I think this makes createMapFromCoreTensor obsolete.

tensorParametrization = method(Options=>{BaseRing => QQ})
tensorParametrization(NCRingElement) := opts -> (f) -> (
    t := terms f;
    lc := t / leadCoefficient;
    lm := t / leadMonomial;
    b := getSymbol("b");
    varis := apply(lm, i -> b_(wordString i));
    bR := coefficientRing (class f);
    R := opts.BaseRing monoid(new Array from varis);
    return(map(bR,R,lc));
)


-- define shuffle products on words, then overload function and use linExt to extend to NCRingElements. Define operator ** as shuffle product in NCAlgebra

wordAlgebra = method(Options=>{BaseRing => QQ});
wordAlgebra (List) := opts -> (l) -> (
    Lt := getSymbol("Lt");
    myvars := apply(l,i-> (Lt_i));
    return(opts.BaseRing myvars);
)
wordAlgebra (ZZ) := opts -> (z) -> (
    return(wordAlgebra(toList(1..z), BaseRing => opts.BaseRing));
)


--Returns the shuffle product of two words using the recursive definition. The words are given as NCMonomials with their respective ring. 
--There is no need for checks on whether the imputed elements are monomials since this is an auxiliary function that will be called in the function "shuffle" 
--

-- need to rewrite shuffleMon; causes bugs when working with different NCRings, see below
-- shuffleMon = method();
-- shuffleMon (NCRingElement, NCRingElement, NCPolynomialRing) := NCRingElement => (word1, word2, R) -> (

--     list1Aux:=(values ((keys word1.terms)#0))#1; --List of factors in the monomial
--     list2Aux:=(values ((keys word2.terms)#0))#1;

--     if (word1==0_R or word2==0_R ) then (return 0_R);

--     if (word1==1_R) then (return word2);

--     if (word2==1_R) then (return word1);

--     if (length(list1Aux)==1) and (length(list2Aux)==1) then (return word2*word1 + word1*word2);

--     if (length(list1Aux)==1) and (length(list2Aux)>1) then (
--         ww2:= product(length(list2Aux)-1, i-> value (list2Aux)#i); -- CALLING value PUTS VARIABLE INTO THE WRONG RING
--         bb:= value (list2Aux)#-1; -- SAME PROBLEM HERE!
--         return word2*word1 + shuffleMon(word1, ww2, R)*bb
--     );

--     if (length(list1Aux)>1) and (length(list2Aux)==1) then (
--         return  shuffleMon(word2, word1, R)
--     );


--     w1:= product(length(list1Aux)-1, i-> value (list1Aux)#i);

--     w2:= product(length(list2Aux)-1, i-> value (list2Aux)#i);

--     a:= value (list1Aux)#-1;

--     b:= value (list2Aux)#-1;

--     return (shuffleMon(w1, word2, R)* a) + (shuffleMon(word1, w2, R)* b)
-- )

-- --Auxiliary function that returns the shuffle product of NCpolynomials of the type (sum f_i x^i) shuffle x^j
-- --

-- shuffleMonExtL = method()
-- shuffleMonExtL (NCRingElement, NCRingElement, NCPolynomialRing) := (NCRingElement) => (g , word, R) -> (

--     coefTableAux:= coefficientHTable(g);       
--     return sum(#(values coefTableAux), i-> (values coefTableAux)_i* shuffleMon((keys coefTableAux)_i, word, R))

-- );



-- --Returns the shuffle product of two NCpolynomials of the type (sum f_i x^i) shuffle (sum g_j x^j)
-- --
-- shuffle = method();
-- shuffle (NCRingElement, NCRingElement) := NCRingElement => (f, g) -> (
--     R1 := class f; R2 := class g;
--     if(not R1 === R2) then error("Can not shuffle words from different algebras.");
--     coefTableAux:= coefficientHTable(g);       
--     return sum(#(values coefTableAux), i-> (values coefTableAux)_i* shuffleMonExtL(f, (keys coefTableAux)_i, R1))

-- )


-- updated shuffle method:
shuffle = method();
shuffle (List,List,NCRing) := (w1,w2,R) -> (
    l1 := length(w1);
    l2 := length(w2);
    if(l1 == 0 and l2 == 0) then return 1_R;
    if(l1 == 0) then return (new Array from w2)_R;
    if(l2 == 0) then return (new Array from w1)_R;
    w1l := w1_{0..l1-2};
    w2l := w2_{0..l2-2};
    i := w1#-1;
    j := w2#-1;

    return(shuffle(w1,w2l,R)*[j]_R + shuffle(w1l,w2,R)*[i]_R);
);

shuffle (NCRingElement, List) := (f,w2) -> linExt(i->shuffle(i,w2,ring f),f);

shuffle (NCRingElement, NCRingElement) := (f,g) -> (
    if(ring f === ring g) then (
        return(linExt(i->shuffle(f,i),g));)
    else (
        error "Can not apply shuffle to polynomials from different rings";
    )
)

NCRingElement ** NCRingElement := (f,g) -> (
    shuffle(f,g)
)

-- define halfshuffle product. Define operator << as halfshuffle product in NCAlgebra

-- halfshuffle = method();
-- halfshuffle (NCRingElement, NCRingElement) := NCRingElement => (word1, word2) -> (
  
--     if (length((values ((keys word2.terms)#0))#1)==1) then (
--     return word1*word2
--     );


--     w2:= product(length((values ((keys word2.terms)#0))#1)-1, i-> value ((values ((keys word2.terms)#0))#1)#i);
--     b:= value ((values ((keys word2.terms)#0))#1)#-1;

--     return (halfshuffle(word1, w2) + halfshuffle(w2, word1))*b
-- )

halfshuffle = method();
halfshuffle(NCRingElement, List) := (f,w) -> (
    wl := w_(toList(0..length(w)-2));
    wr := w_(-1);
    return( shuffle(f,wl) * (ring f)_(wr-1) );
)

halfshuffle (NCRingElement, NCRingElement) := (f,g) -> (
    if(ring f === ring g) then (
        return(linExt(i->halfshuffle(f,i),g));)
    else (
        error "Can not apply halfshuffle to polynomials from different rings";
    )
)

NCRingElement << NCRingElement := (f,g) -> (
    halfshuffle(f,g)
)

wordFormat = method();
wordFormat NCRingElement := f -> (
   if #(f.terms) == 0 then return net "0";
   
   firstTerm := true;
   myNet := net "";
   isZp := (class coefficientRing ring f === QuotientRing and ambient coefficientRing ring f === ZZ);
   for t in sort pairs coefficientHTable f do (
      tempNet := net t#1 | net " ";
      printParens := ring t#1 =!= QQ and
  		     ring t#1 =!= ZZ and
                     not isZp and
		     (size t#1 > 1 or (isField ring t#1 and 
			               numgens coefficientRing ring t#1 > 0 and
				       size sub(t#1, coefficientRing ring t#1) > 1));
      myNet = myNet |
              (if isZp and tempNet#0#0 != " - " and not firstTerm then net " + "
	       else if not firstTerm and t#1 > 0 then
                 net " + "
               else 
                 net "") |
              (if printParens then net "(" else net "") | 
              (if t#1 != 1 and t#1 != -1 then
                 tempNet
               else if t#1 == -1 then net " - "
               else net "") |
              (if printParens then net ")" else net "") |
              (if t#0 === {} and (t#1 == 1 or t#1 == -1) then net "1" else (net new Array from ncMonToList(t#0)));
      firstTerm = false;
   );
   myNet
)

wordString = method();
wordString NCRingElement := f -> (
   if #(f.terms) == 0 then return "0";
   
   firstTerm := true;
   myString := "";
   isZp := (class coefficientRing ring f === QuotientRing and ambient coefficientRing ring f === ZZ);
   for t in sort pairs coefficientHTable f do (
      tempString := toString(t#1) | " ";
      printParens := ring t#1 =!= QQ and
  		     ring t#1 =!= ZZ and
                     not isZp and
		     (size t#1 > 1 or (isField ring t#1 and 
			               numgens coefficientRing ring t#1 > 0 and
				       size sub(t#1, coefficientRing ring t#1) > 1));
      myString = myString |
              (if isZp and tempString#0#0 != " - " and not firstTerm then " + "
	       else if not firstTerm and t#1 > 0 then
                  " + "
               else 
                 "") |
              (if printParens then "(" else "") | 
              (if t#1 != 1 and t#1 != -1 then
                 tempString
               else if t#1 == -1 then " - "
               else "") |
              (if printParens then ")" else "") |
              (if t#0 === {} and (t#1 == 1 or t#1 == -1) then "1" else (toString new Array from ncMonToList(t#0)));
      firstTerm = false;
   );
   myString
)

applyDeep = method();
applyDeep (Thing, FunctionClosure) := (l,f) -> (
    if(class l === List) then (
        l1 := apply(l,i->applyDeep(i,f));
        return(l1);
    );
    f(l)
)

tensorArray = method();
tensorArray NCRingElement := f -> (
    H := coefficientHTable f;
    R := ring f;
    genv := gens R;
    k := degree leadTerm f;
    toList apply(1..k,
        i -> applyDeep(product(i,k->genv),w->(if(H#?w) then H#w else 0)
        )
    )
)

tensorArray(NCRingElement,ZZ) := (f,h) -> (
    H := coefficientHTable f;
    R := ring f;
    genv := gens R;
    applyDeep(product(h,k->genv),w->(if(H#?w) then H#w else 0))
)

NCRingElement @ ZZ := (f,h) -> tensorArray(f,h);

 -- the inner product on tensor space
inner = method();
inner(List, NCRingElement) := (l,f) -> (
    H := coefficientHTable f;
    mon := (new Array from l)_(ring f);
    return(if(H#?mon) then H#mon else 0);
)

-- the first argument is to be viewed as an element of the dual space
inner(NCRingElement, NCRingElement) := (fv,f) -> (
    return(linExt(w->inner(w,f),fv));
)


NCRingElement @ NCRingElement := (f,m) -> inner(f,m);

Array _ NCPolynomialRing := (a, R) -> (
    if(max(toList a)>length(gens R)) then (error(toString(net "Not enough letters in ring " | net R | ".")));
    
    product(a,i->R_(i-1))
)

signedVolume = method();
signedVolume NCPolynomialRing := (R) -> (
    perms := permutations(toList(1..length(gens R)));
    (1/(length(gens R))!) * sum(perms,i-> sign(permutation i) * (new Array from i)_R)
);


--Function to transform a commutative polynomial into a non-commutative polynomial, with the same ordered variables of a given NCRing. 
--Roughly speaking it outputs the given polynomial with the variables replaced by non commutative variables on a given NCRing. It is an auxiliary funtion to be used later. 
--
elementToNCElement = method();
elementToNCElement (RingElement, NCPolynomialRing):= NCRingElement => (f, S) -> (
    R:=ring f;
    phi:=ncMap(S ,R , apply(length(gens S), i->(gens S)_i));
    return phi(f)
)


--Returns the image of a monomial under the map \varphi: R[x_1..x_d] \to T(R^d), x_i\maptso i, x_{i_1},...,x_{i_l}\mapsto x_{i_1}\shuffle .... \shuffle x_{i_l}
--This function is then extended linearly in "phiMap"  

phiMapMon = method();
phiMapMon (NCRingElement, NCPolynomialRing):= NCRingElement => (f, S) -> (
  
    if f==1_S then (
        return 1_S
    );

    ListAux:=(values ((keys f.terms)#0))#1;

    if (length(ListAux)==1) then (
        return f
    );


    fw:= product(length(ListAux)-1, i-> value (ListAux)#i);
    b:= value (ListAux)#-1;

    return (phiMapMon(fw, S) ** b)
)

--Returns the image of a polynomial under the map \varphi: R[x_1..x_d] \to T(R^d), x_i\maptso i, x_{i_1},...,x_{i_l}\mapsto x_{i_1}\shuffle .... \shuffle x_{i_l} 
--Extends linearly the previous function.

phiMap = method();
phiMap (RingElement, NCPolynomialRing) := NCRingElement => (f, S) -> ( 


    if f==0 then (
        return 0_S
    );

    ncomf:= elementToNCElement(f, S);
    coefTableAux:= coefficientHTable(ncomf);
    return sum(#(values coefTableAux), i-> (values coefTableAux)_i* phiMapMon((keys coefTableAux)_i, S))
)


--Given a list of polynomials, it returns the image of their Jacobian under the phi map. 
--There is no need to check whether the imputed list is made of polynomials since it is an auxiliary function to be called later.  

phiJacobian = method();
phiJacobian (List, NCPolynomialRing) := NCMatrix => (l, S) -> ( 

    M:=matrix{l};
    J:=jacobian M;

    m := table(numgens target J, numgens source J, (i,j)->phiMap(J_(i,j), S));

    return ncMatrix(apply(numgens target J, i->apply(numgens source J, j->m#i#j)))

)



--Function M_p applied to words

adjointWordMon = method()
adjointWordMon (NCRingElement, NCPolynomialRing, ZZ, List) := NCRingElement => (word, T, d, l) -> (

    S := class word;
    
    if word==0_S then (
            return 0_T
        );
    
    listAux := (values ((keys word.terms)#0))#1;
    M := transpose phiJacobian(l, T);
    listVars := gens T;
    
    i := 0;

    if length(listAux)==1 then (
        i =varIndex(word);
        return sum(d, j-> ((M.matrix)_i)_j*listVars_(j))
    );

    if length(listAux)>1 then (
        ww := product(length(listAux)-1, i-> value (listAux)#i);
        i = varIndex(value (listAux)#-1);

        return sum(d, j-> (adjointWordMon(ww, T, d, l) ** ((M.matrix)_i)_j )*listVars_(j))
    );
)

--Function M_p applied to polynomials


adjointWord = method()
adjointWord (NCRingElement, NCPolynomialRing, List) := NCRingElement => (g, T, L) -> (

    Raux:=ring product(L);
    d:=length(gens Raux);

    --Check that number of letters in the given NCRing is enough to compute the image of the word  
    if d>length(gens T) then (
        error("Number of generators of the NCRing lower than dimension of the polynomial ring")
    );

    if not all(apply(L, p->part(0,p)), q->q==0) then (
        error("The image of 0 under the polynomial map is not 0")
    );

    coefTableAux:= coefficientHTable(g);       
    return sum(#(values coefTableAux), i-> (values coefTableAux)_i* adjointWordMon((keys coefTableAux)_i, T,d,L))

)

-- alternative implementation of adjointWord via half-shuffle -- let's discuss

phiMapMon2 = method();
phiMapMon2(List, NCPolynomialRing) := (l, A) -> (
    L := flatten apply(length(l), i -> toList((l#i : [i+1]_A)));
    fold(L, (i,j) -> i**j)
)

phiMap2 = method();
phiMap2(RingElement,NCPolynomialRing) := (p, A) -> (
    cA := coefficientRing A;
    sum(listForm p, i-> sub(i#1,cA) * phiMapMon2(i#0,A))
)

adjWord2 = method();
adjWord2 (List, NCPolynomialRing, List) := (w, A, P) -> (

    w2 := {1_A} | w;
    fold((i,j) -> i << (phiMap2(P#(j-1),A)), w2)
)

-- f is the input nc polynomial, A is the output nc ring and P is the polynomial transformation, given as a list of polynomials
adjWord2 (NCRingElement, NCPolynomialRing, List) := (f, A, P) -> (
    Raux:=ring product(P);
    d:=length(gens Raux);

    --Check that number of letters in the given NCRing is enough to compute the image of the word  
    if d>length(gens A) then (
        error("Number of generators of the NCRing lower than dimension of the polynomial ring")
    );
    if not (length(P) == length(gens ring f)) then error("The polynomial transformation does not map to the space underlying the input word.");

    if not all(apply(P, p->part(0,p)), q->q==0) then (
        error("The image of 0 under the polynomial map is not 0");
    );
    if(f == 0_(ring f)) then return 0_A;
    return(linExt(w->adjWord2(w,A,P), f));
)

-- given d and k, nextLyndon(w,d,k) creates the next Lyndon word of length at most k in d letters after w in lexicographical order
nextLyndonWord = method();
nextLyndonWord(List,ZZ,ZZ) := (l,d,k) -> (
    nl := fold((ceiling(k/length(l))):l, (i,j)->i|j);
    if(length(nl)>k) then (nl = nl_{0..k-1});
    while(nl_(-1) == d and length(nl)>1) do (
        nl = nl_{0..length(nl)-2};
    );
    if(nl != {d}) then nl = nl + toList(((length(nl)-1):0) | (1:1));
    return(nl)
);

-- lyndonWords(d,k) returns a list of all Lyndon words of length at most k in d letters
lyndonWords = method();
lyndonWords (ZZ,ZZ) := (d,k) -> (
    if(d <= 0) then error("d must be a positive integer in lyndonWords(d,k).");
    if(k <= 0) then error("k must be a positive integer in lyndonWords(d,k).");
    l:={{1}};
    while(l_(-1) != {d}) do (
        l = l | {nextLyndonWord(l_(-1),d,k)};
    );
    return(l);
)

-- lie(a,b) returns the lie bracket of a and b
lie = (a,b) -> (a*b - b*a);

-- isLyndon(l) checks if l is a Lyndon word
isLyndon = method();
isLyndon List := (l) -> (
    out := true;
    scan(1..length(l)-1, i->( out = (l < l_{i..(length(l)-1)})));
    return(out)
)

-- lyndonFact(l) computes the standard decomposition of l
lyndonDecomposition = method();
lyndonDecomposition List := (l) -> (
    i := length(l)-1;
    ls := apply(0..length(l)-2,i-> {l_{0..i},l_{i+1..length(l)-1}});
    cand := select(ls,i-> isLyndon(i_0) and isLyndon(i_1));
    return cand_(-1)
)

-- lieBasis(l, A) yields the basis element corresponding to the Lyndon word l in the free Lie algebra, realized in A
lieBasis = method();
lieBasis(List, NCPolynomialRing) := (l,R) -> (
    if(length(l) == 0) then error("lieBasis expected a non-empty list as input.");
    if(length(l) == 1) then return R_(l_(-1) - 1);
    fact := apply(lyndonDecomposition(l),i-> lieBasis(i,R));
    return(lie(fact_0,fact_1))
)

-- auxiliary functions for tensorExp
expTermCoef = (t) -> (
    m := max t;
    counts := new MutableList from (m : 0);
    for i from 0 to length(t)-1 do(
       if(t#i > 0) then counts#(t#i - 1) = counts#(t#i - 1) + 1;
    );
    counts = toList(counts);
    facs := apply(counts, i -> i!);
    binom := product(facs);
    return(1/binom);
);

expTerm = (tl,l) -> (
    expTermCoef(l)*product(l,i->(tl_i))
)

-- Given a tensor p with constant term 0, tensorExp(p,k) returns the k-th level component of exp(p)

tensorExp = method();
tensorExp (NCRingElement, ZZ) := (p,k) -> (
    if(length (select(terms p, j-> degree j == 0)) > 0) then error("tensorExp expects a nc polynomial with constant term 0.");
    s := {1} | toList apply(1..k, i-> sum(select(terms p, j->((degree j) == i))));
    comp := unique apply(compositions k, i->delete(0,i));
    t := sum(apply(comp, i-> expTerm(s,i)));
    return(t);
)

--------------------------------------------
--Include documentation
load "./PathSignatures/PathSignaturesDoc.m2"
--------------------------------------------

endPackage;












