newPackage("PathSignatures",
         Version => "1.0",
         Authors => {{Name => "Felix Lotter"}, {Name => "Oriol Reig"}, {Name => "Angelo El Saliby"}, {Name => "Carlos Amendola"}},
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
    "concatPath",
    "matrixAction",
    "CAxisTensor",
    "CMonTensor",
    "tensorParametrization",
    "wordAlgebra",
    "signedVolume",
    "shuffle",
    "halfshuffle",
    "wordFormat",
    "wordString",
    "getDimension",
    "getPieces",
    "getCoefficientRing",
    "getNumberOfPieces",
    -- symbols
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

sig (Path, List) := (X,w) -> (
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

sig(Path,NCRingElement) := (X,f) -> (
    return(linExt(w->sig(X,w),f));
)

--Compute the signature in level h of a path X

sig(Path,ZZ,NCRing) := (X, h, R) -> (
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
    R := wordAlgebra(X.dimension, CoefficientRing => X.bR);
    sig(X,h,R)
)

TEST ///
R = QQ{symbol s_1..symbol s_5};
f = 1/2*(s_1*s_2 - s_2*s_1);
A = QQ[symbol x_1..symbol x_3]

pR = A[t];
X = polyPath({0,x_2*t^2}) ** polyPath({x_3*t^3 + 3*t, t^2 - 1})
<<<<<<< HEAD
r = sig(X,f)
///

------------------------------------------------
--Defining the Type "Path" as a subclass of MutableHashTable.
--It should be able to allow for concatenation of piecewise linear
--and polynomial paths and to correctly call the functions
--already implemented depending on the type of path.
--A Path will then be an (ordered) list of LinPaths and PolyPaths

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
polyPath List := Path => (polyPathList) -> (
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

Path _ List := Path => (X, l) -> (
    if(l === {}) then return polyPath({});
    P := new Path from{
        bR => X.bR,
        pieces => (X.pieces)_l,
        dimension => X.dimension,
        numberOfPieces => length(l)
    };
    return P;
)

Path _ Sequence := Path => (X,l) -> (
    return X_(toList l);
)

Path _ ZZ := Path => (X, z) -> (
    return X_{z};
)

getDimension = method();
getDimension Path := (X) -> X.dimension;
dim Path := (X) -> X.dimension; -- can we have two aliases for the same function?

getPieces = method();
getPieces Path := (X) -> X.pieces;

getCoefficientRing = method();
getCoefficientRing Path := (X) -> X.bR;
coefficientRing Path := (X) -> X.bR;

getNumberOfPieces = method();
getNumberOfPieces Path := (X) -> X.numberOfPieces;

-- Concatenation of paths

sub(Path,Ring) := Path => (X,R) -> (
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

concatPath = method();
concatPath(Path,Path) := Path => (X,Y) -> (
    if(X.dimension != Y.dimension) then error("Cannot concatenate paths of different ambient dimension.");
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
    
    P := new Path from{
        bR => X.bR,
        pieces => X.pieces | Y.pieces,
        dimension => X.dimension,
        numberOfPieces => X.numberOfPieces + Y.numberOfPieces
    };
    return P;
)

Path ** Path := Path => (X,Y) -> concatPath(X,Y);

TEST ///
pR = QQ[t];
X = polyPath({t,t^2})

<<<<<<< HEAD
X**X
///

Path ^ ZZ := Path => (X,n) -> (
    if(n > 0) then return(fold(n:X, (X,Y) -> X**Y));
    if(n == -1) then (
        rpath := X.pieces;
        s := getSymbol("s");
        S := X.bR monoid([s]);
        rpath = apply(rpath, polyvec -> apply(polyvec, pol -> sum(pol, mon -> ((mon)#1)_S * (S_0)^((mon)#0#0)))); -- transform pieces back to polynomial vectors in variable s
        rpath = apply(rpath,polyvec -> apply(polyvec, pol -> sub(pol,S_0 => (1 - S_0)))); -- replace s by 1-s
        rpath = reverse(rpath); -- reverse order of pieces
        rpath = apply(rpath, P-> polyPath(P));
        return(fold(rpath,(i,j)->i**j));
    );
    if(n < 1) then (
        return((X^(-1))^(abs(n)))
    );
    t:= getSymbol("t");
    auxR := X.bR [t];
    return(polyPath(toList(X.dimension:(0_(auxR)))))
)

TEST ///
pR = QQ[t];
X = polyPath({t,t^2})

<<<<<<< HEAD
X^(-1)
///

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

--Constructs a pw linear path from a given matrix of increments

pwLinPath = method();
pwLinPath Matrix := Path => (pwlMatrix) -> (
    pathList := apply(transpose entries pwlMatrix, i-> linPath(i));
    return(fold(pathList,(i,j)->i**j));
)

TEST ///
R= QQ[t];

X = polyPath({t, t^2});
assert(getNumberOfPieces X === 1);
assert(dim p === 2);
Y = linPath({1,2});

XY = X**Y;
assert(getNumberOfPieces XY === 2);
assert(dim XY === 2);
///


--coefficientHTable returns a Hash table associating the monomials in a nc polynomial to their coefficients
--this is not the same as f.terms, which associated the NCMonomials (an inaccessible type) in f to their coefficients
coefficientHTable = method()
coefficientHTable (NCRingElement) := HashTable => f -> (
        fterms := terms f;
        hashTable(apply(fterms, i -> {leadMonomial i, leadCoefficient i}))
);


--This function converts a NC monomial to a list representing the corresponding word
--f is a monomial in an NCring
--The output is a list representing the word

ncMonToList = method()
ncMonToList (NCRingElement) := List => f -> (
    fmons := keys f.terms;
    monKey := (keys fmons#0)#1;
    R := ring f;
    varst := hashTable(toList apply(0..length(gens R)-1, i-> (baseName R_i,i+1)));
    (fmons#0)#(monKey) / ( i -> varst#i)
);

--linExt extends functions on words to the whole non commutative polynomial algebra
linExt = method();
linExt(FunctionClosure, NCRingElement) := RingElement => (fun, w) -> (
    lot := apply(terms w, i -> {leadCoefficient i, ncMonToList(i)});
    sum(length(lot),i->(lot#i)#0 * fun((lot#i)#1))
)


--polyIntegral computes integrals of polynomials with respect to one variable
--f is the integrand
--xn is a generator of the base ring

polyIntegral = method()
polyIntegral (RingElement, RingElement) := RingElement => (f, xn) ->(
    R := ring f;
    indexn := index xn;
    termsf := terms f;
    return sum(termsf, i->(1_R/(((((exponents(i))#0)#(indexn)+1))) * i * xn))
);



-- polySigGen computes the signature of a polynomial path for words
-- l is the list of components of the polynomial path, each represented by a list
-- Here, a polynomial is represented by its list form, see M2 documentation for listForm
-- w is a list representing a word as in linsig
-- br is the base ring of the coefficients

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


-- Diagonal matrix action on tensors
matrixAction = method();
matrixAction (Matrix,  NCRing, NCRing) := NCRingElement => (M, A, B) -> (
    N :=transpose entries M;
    f := ncMap(B, A, apply(N, j->sum(length(j), i->j#i*(gens B)#i)));
    return(f);
)

matrixAction (Matrix,  NCRingElement, NCRing) := NCRingElement => (M, p, B) -> (
    f := matrixAction(M,ring p, B);
    return(f(p));
)

-- Matrix * Tensor also computes the diagonal matrix action on a tensor, but creates the output nc ring automatically
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


-- Hard coded canonical axis path tensor simple components as in 
-- Example 2.1 of "varieties of signature tensors" 
-- C. Amendola et al, 2018
--Inputs: 
--  w, a word in a NCpolynomial ring 

CAxisComponent = method();
CAxisComponent (NCRingElement) := QQ => w -> (
    L := ncMonToList (w);
    if(L!=sort(L)) then return 0;
    distinctPermutations := (#L)!/(product( apply(values tally L, i-> i !)));
    distinctPermutations/((#L))!
);


-- Hard coded canonical moment path tensor simple components as in 
-- Example 2.3 of "varieties of signature tensors" 
-- C. Amendola et al, 2018
--Inputs: 
--  w, a word in a NCpolynomial ring

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

-- tensorParametrization takes a tensor T, constructs a ring R with one variable for each word appearing in T and creates the map that sends a variable to the coefficient of the corresponding word.

tensorParametrization = method(Options=>{CoefficientRing => QQ})
tensorParametrization(NCRingElement) := opts -> (f) -> (
    t := terms f;
    lc := t / leadCoefficient;
    lm := t / leadMonomial;
    b := getSymbol("b");
    varis := apply(lm, i -> b_(wordString i));
    bR := coefficientRing (class f);
    R := opts.CoefficientRing monoid(new Array from varis);
    return(map(bR,R,lc));
)

-- create the non commutative algebra over alphabet given by a list.

wordAlgebra = method(Options=>{CoefficientRing => QQ});
wordAlgebra (List) := opts -> (l) -> (
    Lt := getSymbol("Lt");
    myvars := apply(l,i-> (Lt_i));
    return(opts.CoefficientRing myvars);
)

-- create the non commutative algebra over alphabet 1..z

wordAlgebra (ZZ) := opts -> (z) -> (
    return(wordAlgebra(toList(1..z), CoefficientRing => opts.CoefficientRing));
)

-- define shuffle products on words, use linExt to extend to NCRingElements. Define operator ** as shuffle product in NCAlgebra

--Intermediate operations for shuffle product of two words
shuffleHelper= method(); 
shuffleHelper(List,List,NCRing) := (w1,w2,R) -> (
    l1 := length(w1);
    l2 := length(w2);
    if(l1 == 0 and l2 == 0) then return 1_R;
    if(l1 == 0) then return (new Array from w2)_R;
    if(l2 == 0) then return (new Array from w1)_R;
    w1l := w1_{0..l1-2};
    w2l := w2_{0..l2-2};
    i := w1#-1;
    j := w2#-1;

    return(shuffleHelper(w1,w2l,R)*[j]_R + shuffleHelper(w1l,w2,R)*[i]_R);
);

shuffleHelper(NCRingElement, List) := (f,w2) -> linExt(i->shuffleHelper(i,w2,ring f),f);

shuffleHelper(NCRingElement, NCRingElement) := (f,g) -> (
    if(ring f === ring g) then (
        return(linExt(i->shuffleHelper(f,i),g));)
    else (
        error "Can not apply shuffle to polynomials from different rings";
    )
)

-- Exposed versions of shuffle

shuffle = method();
shuffle (NCRingElement, NCRingElement) := (a, b) -> shuffleHelper(a,b); 

NCRingElement ** NCRingElement := (f,g) -> (
    shuffle(f,g)
)

-- the antipode of the nc polynomial ring as a Hopf algebra

antipode NCRingElement := (f) -> (
    R := ring f;
    linExt(w -> (-1)^(length(w)) * (new Array from reverse(w))_R, f)
);

TEST ///
A3 = wordAlgebra(3);
assert((antipode (antipode [1,2,3,2,1]_A3)) == [1,2,3,2,1]_A3)
///

-- define halfshuffle on nc polynomials and words, then extend to nc pols via linExt

halfshuffleHelper = method();
halfshuffleHelper(NCRingElement, List) := (f,w) -> (
    wl := w_(toList(0..length(w)-2));
    wr := w_(-1);
    return( shuffleHelper(f,wl) * (ring f)_(wr-1) );
)

halfshuffle = method();
halfshuffle (NCRingElement, NCRingElement) := (f,g) -> (
    if(ring f === ring g) then (
        if(degree f == 0 or degree g == 0) then error("Can not apply halfshuffle to polynomials of degree zero.");
        return(linExt(i->halfshuffleHelper(f,i),g));)
    else (
        error "Can not apply halfshuffle to polynomials from different rings";
    )
)

installMethod(symbol >>, NCRingElement, NCRingElement, (f,g)->halfshuffle(f,g))

-- methods for output of nc polynomials

-- should mention reference? (copied and adapted code from NCAlgebra package)
wordFormat = method();
wordFormat NCRingElement := f -> (
   if #(f.terms) == 0 then return net "0";
   
   firstTerm := true;
   myNet := net "";
   isZp := (class coefficientRing ring f === QuotientRing and ambient coefficientRing ring f === ZZ);
   for t in sort pairs coefficientHTable f do (
      tempNet := (if(instance(t#1, Number)) then (if(t#1 < 0) then (if(firstTerm) then net "- " else net " - ") | net abs(t#1) else net t#1) else net t#1) | net " ";
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
               else if t#1 == -1 then (if(firstTerm) then net "- " else net " - ")
               else net "") |
              (if printParens then net ") " else net "") |
              (if t#0 === {} and (t#1 == 1 or t#1 == -1) then net "1" else (net new Array from ncMonToList(t#0)));
      firstTerm = false;
   );
   myNet
)

wordString = method();
wordString NCRingElement := f -> (
   toString(wordFormat f)
)


applyDeep = method(); -- auxiliary function for tensorArray
applyDeep (Thing, FunctionClosure) := (l,f) -> (
    if(class l === List) then (
        l1 := apply(l,i->applyDeep(i,f));
        return(l1);
    );
    f(l)
)

-- converts a polynomial f in an nc ring R to a list of multi-dimensional arrays of depth 1,...,k, where k is the degree of f and the entry (j,i_1,...,i_j) is the coefficient of [i_1,...,i_j]_R in f.
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

-- returns only the depth h component of tensorArray
tensorArray(NCRingElement,ZZ) := (f,h) -> (
    H := coefficientHTable f;
    R := ring f;
    genv := gens R;
    applyDeep(product(h,k->genv),w->(if(H#?w) then H#w else 0))
)

NCRingElement @ ZZ := (f,h) -> tensorArray(f,h);

-- the inner product on tensor space
innerHelper = method();
innerHelper(List, NCRingElement) := (l,f) -> (
    H := coefficientHTable f;
    mon := (new Array from l)_(ring f);
    return(if(H#?mon) then H#mon else 0);
)

inner = method();
-- the first argument is to be viewed as an element of the dual space
inner(NCRingElement, NCRingElement) := (fv,f) -> (
    return(linExt(w->innerHelper(w,f),fv));
)

NCRingElement @ NCRingElement := (f,m) -> inner(f,m);

-- installs operator to work with words [i1,...,ik]_R in an NC ring R
Array _ NCPolynomialRing := (a, R) -> (
    if(max(toList a)>length(gens R)) then (error(toString(net "Not enough letters in ring " | net R | ".")));
    
    product(a,i->R_(i-1))
)

-- returns the word in an NC ring that corresponds to the signed volume under the signature
signedVolume = method();
signedVolume NCPolynomialRing := (R) -> (
    perms := permutations(toList(1..length(gens R)));
    (1/(length(gens R))!) * sum(perms,i-> sign(permutation i) * (new Array from i)_R)
);


-- adjointWord computes values of the half-shuffle homomorphism M_p of nc rings adjoint to polynomial maps of affine spaces under the signature.

-- Returns the image of a monomial under the map \varphi: R[x_1..x_d] \to T(R^d), x_i\maptso i, x_{i_1},...,x_{i_l}\mapsto x_{i_1}\shuffle .... \shuffle x_{i_l}
-- This function is then extended linearly in "phiMap"  

phiMapMon = method();
phiMapMon(List, NCPolynomialRing) := (l, A) -> (
    L := flatten apply(length(l), i -> toList((l#i : [i+1]_A)));
    fold(L, (i,j) -> i**j)
)

-- Returns the image of a polynomial under the map \varphi: R[x_1..x_d] \to T(R^d), x_i\maptso i, x_{i_1},...,x_{i_l}\mapsto x_{i_1}\shuffle .... \shuffle x_{i_l} 
-- Extends the previous function linearly.

phiMap = method();
phiMap(RingElement,NCPolynomialRing) := (p, A) -> (
    cA := coefficientRing A;
    sum(listForm p, i-> sub(i#1,cA) * phiMapMon(i#0,A))
)

adjointWordHelper = method();
adjointWordHelper (List, NCPolynomialRing, List) := (w, A, P) -> (

    w2 := {phiMap(P#(w#0 - 1),A)} | w_{1..length(w)-1};
    fold((i,j) -> i >> (phiMap(P#(j-1),A)), w2)
)

-- f is the input nc polynomial, A is the output nc ring and P is the polynomial transformation, given as a list of polynomials

adjointWord = method();
adjointWord (NCRingElement, NCPolynomialRing, List) := (f, A, P) -> (
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
    return(linExt(w->adjointWordHelper(w,A,P), f));
)


-- Lyndon words and more.

-- Implementation of Duval's algorithm. Given d and k, nextLyndon(w,d,k) creates the next Lyndon word of length at most k in d letters after w in lexicographical order

nextLyndonWord = method();
nextLyndonWord(Array,ZZ,ZZ) := Array => (ar,d,k) -> (
    l := toList ar;
    nl := fold((ceiling(k/length(l))):l, (i,j)->i|j);
    if(length(nl)>k) then (nl = nl_{0..k-1});
    while(nl_(-1) == d and length(nl)>1) do (
        nl = nl_{0..length(nl)-2};
    );
    if(nl != {d}) then nl = nl + toList(((length(nl)-1):0) | (1:1));
    return(new Array from nl)
);

-- lyndonWords(d,k) returns a list of all Lyndon words of length at most k in d letters

lyndonWords = method();
lyndonWords (ZZ,ZZ) := (d,k) -> (
    if(d <= 0) then error("d must be a positive integer in lyndonWords(d,k).");
    if(k <= 0) then error("k must be a positive integer in lyndonWords(d,k).");
    l:={[1]};
    while(l_(-1) != [d]) do (
        l = l | {nextLyndonWord(l_(-1),d,k)};
    );
    return(l);
)

-- lie(a,b) returns the lie bracket of a and b

lie = (a,b) -> (a*b - b*a);

-- isLyndon(l) checks if l is a Lyndon word

isLyndon = method();
isLyndon Array := (w) -> (
    l := toList w;
    out := true;
    scan(1..length(l)-1, i->( out = (l < l_{i..(length(l)-1)})));
    return(out)
)

-- lyndonFact(l) computes the standard decomposition of l

lyndonDecomposition = method();
lyndonDecomposition Array := (w) -> (
    i := length(w)-1;
    ls := apply(0..length(w)-2,i-> {new Array from w_{0..i},new Array from w_{i+1..length(w)-1}});
    cand := select(ls,i-> isLyndon(i_0) and isLyndon(i_1));
    return cand_(-1)
)

-- lieBasis(l, A) yields the basis element corresponding to the Lyndon word l in the free Lie algebra, realized in A

lieBasis = method();
lieBasis(Array, NCPolynomialRing) := (w,R) -> (
    if(length(w) == 0) then error("lieBasis expected a non-empty list as input.");
    if(length(w) == 1) then return R_(w_(-1) - 1);
    fact := apply(lyndonDecomposition(w),i-> lieBasis(i,R));
    return(lie(fact_0,fact_1))
)

lieBasis(List, NCPolynomialRing) := (l, R) -> lieBasis (new Array from l, R);

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












