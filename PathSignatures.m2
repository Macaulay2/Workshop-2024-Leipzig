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
    "wordAlgebra",
    "signedVolume",
    "shuffle",
    "halfshuffle",
    "wordFormat",
    -- symbols
    "BaseRing",
    "adjointWord",
    "tensorArray",
    "type",
    "pieces",
    "dimension",
    "numberOfPieces",
    "bR"
};

exportFrom("NCAlgebra","NCRingElement")

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

TEST ///
bR = QQ[t]
X= linPath({0,0,0,1})
Y= polyPath({0,0,0,1}) --Gives error
Z= X**Y

wR = QQ{x_1..x_4}
w= x_4
assert(sig(Z, w)==pwlSig(X, w))
///
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
    if(polyPathList === {}) then return new Path from {type => "PPolynomial", pieces => {}, dimension => -1, numberOfPieces => 0};

    if isListForm (polyPathList#0) then (
        apply(polyPathList, i-> if not(isListForm(i)) then error("The input was neither a list of polynomials nor a list of polynomials in listForm"));
        return new Path from{
            type => "PPolynomial",
            pieces => {polyPathList},
            dimension => length polyPathList,
            numberOfPieces => 1
        };
        );

    if (instance(product(polyPathList), RingElement)) then (
        baseR := class product(polyPathList); --Consider taking this as input
        P := new Path from{
            type => "PPolynomial",
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
        type => X.type,
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
    -- TODO
);

Path ** Path := Path => (X,Y) -> (
    if(X.dimension != Y.dimension) then error("Can not concatenate paths of different ambient dimension.");
    if((X.bR === Y.bR)==false) then error("Paths have coefficients over different base rings.");
    P := new Path from{
        type => X.type,
        bR => X.bR,
        pieces => X.pieces | Y.pieces,
        dimension => X.dimension,
        numberOfPieces => X.numberOfPieces + Y.numberOfPieces
    };
    return P;
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
    new Path from{
        type => "PLinear", -- PiecewiseLinear
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
pwlsigw = method()
pwlsigw (List, List) := QQ => (M, w, baseR)-> (
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
pwlsig = method();
pwlsig (Matrix, NCRingElement) := QQ => (M, w)-> (
    Mentries := entries M;
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
        i = i* xn
    )))
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

    res:= product for i from 1 to k list (
        comp := X#(w#(i-1)-1);
        if(comp == 0) then 0_R else sub(diff(S_0,comp), {S_0 => R_(i-1)})
        );
    
    for i from 1 to k-1 do (
        indefinite := sub(polyIntegral(res, R_(i-1)),R);
        eval0 := substitute(indefinite, {R_(i-1) => 0_QQ});
        eval1:= substitute (indefinite, {R_(i-1) => R_(i)}); --(if i<n then t_{i+1} else 1_R)
        res = eval1-eval0;
        );
    res = sub(polyIntegral(res, R_(k-1)),R);
    use(baseR);
    res = substitute(res, {R_(k-1) => 1}) - substitute(res, {R_(k-1) =>0});
    return (if class res === baseR then res else leadCoefficient res)
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

shuffleMon = method();
shuffleMon (NCRingElement, NCRingElement, NCPolynomialRing) := NCRingElement => (word1, word2, R) -> (

    list1Aux:=(values ((keys word1.terms)#0))#1; --List of factors in the monomial
    list2Aux:=(values ((keys word2.terms)#0))#1;

    if (word1==0_R or word2==0_R ) then (return 0_R);

    if (word1==1_R) then (return word2);

    if (word2==1_R) then (return word1);

    if (length(list1Aux)==1) and (length(list2Aux)==1) then (return word2*word1 + word1*word2);

    if (length(list1Aux)==1) and (length(list2Aux)>1) then (
        ww2:= product(length(list2Aux)-1, i-> value (list2Aux)#i);
        bb:= value (list2Aux)#-1;
        return word2*word1 + shuffleMon(word1, ww2, R)*bb
    );

    if (length(list1Aux)>1) and (length(list2Aux)==1) then (
        return  shuffleMon(word2, word1, R)
    );


    w1:= product(length(list1Aux)-1, i-> value (list1Aux)#i);

    w2:= product(length(list2Aux)-1, i-> value (list2Aux)#i);

    a:= value (list1Aux)#-1;

    b:= value (list2Aux)#-1;

    return (shuffleMon(w1, word2, R)* a) + (shuffleMon(word1, w2, R)* b)
)

--Auxiliary function that returns the shuffle product of NCpolynomials of the type (sum f_i x^i) shuffle x^j
--

shuffleMonExtL = method()
shuffleMonExtL (NCRingElement, NCRingElement, NCPolynomialRing) := (NCRingElement) => (g , word, R) -> (

    coefTableAux:= coefficientHTable(g);       
    return sum(#(values coefTableAux), i-> (values coefTableAux)_i* shuffleMon((keys coefTableAux)_i, word, R))

);



--Returns the shuffle product of two NCpolynomials of the type (sum f_i x^i) shuffle (sum g_j x^j)
--
shuffle = method(); -- is faster than shuffle!
shuffle (NCRingElement, NCRingElement, NCPolynomialRing) := NCRingElement => (f, g, R) -> (

    coefTableAux:= coefficientHTable(g);       
    return sum(#(values coefTableAux), i-> (values coefTableAux)_i* shuffleMonExtL(f, (keys coefTableAux)_i, R))

)

----- old shuffle function, depracated
-- shuffle = method();
-- shuffle (List,List,NCRing) := (w1,w2,R) -> (
--     l1 := length(w1);
--     l2 := length(w2);
--     perms := select(permutations(toList(0..l1+l2-1)), i->sort(i_{0..l1-1}) == i_{0..l1-1} and sort(i_{l1..l1+l2-1}) == i_{l1..l1+l2-1});
--     idp := toList(0..l1+l2-1);
--     invperms := apply(transpose {perms, toList(length(perms):idp)}, i -> values hashTable(transpose i));
--     w := join(w1,w2);
--     words := apply(invperms, i-> w_i);
--     sum(words,i->toNCMon(i,R))
-- )

-- shuffle (NCRingElement, List) := (f,w2) -> linExt(i->shuffle(i,w2,ring f),f);

-- shuffle (NCRingElement, NCRingElement) := (f,g) -> (
--     if(ring f === ring g) then (
--         return(linExt(i->shuffle(f,i),g));)
--     else (
--         error "Can not apply shuffle to polynomials from different rings";
--     )
-- )

NCRingElement ** NCRingElement := (f,g) -> (
    shuffle(f,g)
)

-- define halfshuffle product. Define operator << as halfshuffle product in NCAlgebra

halfshuffle = method();
halfshuffle (NCRingElement, NCRingElement) := NCRingElement => (word1, word2) -> (
  
    if (length((values ((keys word2.terms)#0))#1)==1) then (
    return word1*word2
    );


    w2:= product(length((values ((keys word2.terms)#0))#1)-1, i-> value ((values ((keys word2.terms)#0))#1)#i);
    b:= value ((values ((keys word2.terms)#0))#1)#-1;

    return (halfshuffle(word1, w2) + halfshuffle(w2, word1))*b
)

------ old halfshuffle methods, depracated ----
-- halfshuffle = method();
-- halfshuffle(NCRingElement, List) := (f,w) -> (
--     wl := w_(toList(0..length(w)-2));
--     wr := w_(-1);
--     return( shuffle(f,wl) * (ring f)_(wr-1) );
-- )

-- halfshuffle (NCRingElement, NCRingElement) := (f,g) -> (
--     if(ring f === ring g) then (
--         return(linExt(i->halfshuffle(f,i),g));)
--     else (
--         error "Can not apply halfshuffle to polynomials from different rings";
--     )
-- )

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

    return shuffle(phiMapMon(fw, S), b, S)
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

    
    if word==0_T then (
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

        return sum(d, j-> shuffle(adjointWordMon(ww, T, d, l), ((M.matrix)_i)_j, T)*listVars_(j))
    );
)

--Function M_p applied to polynomials


adjointWord = method()
adjointWord (NCRingElement, NCPolynomialRing, List) := NCRingElement => (g, T, L) -> (

    Raux:=ring L_0;
    d:=length(gens Raux);

    --Check that number of letters in the given NCRing is enough to compute the image of the word  
    if d>length(gens T) then (
        error("Number of generators of the NCRing lower than dimension of the polynomial ring")
    );

    if not all(apply(L, p->part(0,p)), q->q==0) then (
        error("The image of 0 under the polynomail map is not 0")
    );

    coefTableAux:= coefficientHTable(g);       
    return sum(#(values coefTableAux), i-> (values coefTableAux)_i* adjointWordMon((keys coefTableAux)_i, T,d,L))

)

--------------------------------------------
--Include documentation
load "./PathSignatures/PathSignaturesDoc.m2"
--------------------------------------------

endPackage;












