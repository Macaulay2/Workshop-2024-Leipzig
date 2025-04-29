---------------------------------------------------------------------
--THE TYPE OF A POLYNOMIAL PATH
---------------------------------------------------------------------

------------------------------------------------------------------
--Defining the Type "Path" as a subclass of MutableHashTable.
--It should be able to allow for concatenation of piecewise linear
--and polynomial paths and to correctly call the functions
--already implemented depending on the type of path.
--A Path will then be an (ordered) list of LinPaths and PolyPaths
------------------------------------------------------------------


Path = new Type of MutableHashTable

protect type
protect pieces
protect dimension
protect numberOfPieces
protect bR


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


--------------------------------------------------------------
--Printing of paths
--------------------------------------------------------------
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



beginDocumentation()

doc ///

Node
    Key
        Path
        (symbol _, Path, List)
        (symbol _, Path, ZZ)
        (symbol _, Path, Sequence)
        (symbol ^, Path, ZZ)
        (getDimension, Path)
        getDimension
        (dim, Path)
        (getNumberOfPieces, Path)
        getNumberOfPieces
        (getPieces, Path)
        getPieces
        (getCoefficientRing, Path)
        getCoefficientRing
        (coefficientRing, Path)
        (net, Path)
    Description
        Text
            A polynomial path is a map $[0,1] \to \mathbb R^d$ whose coordinate functions are given by polynomials. A piecewise polynomial path is a concatenation of polynomial paths.
        Text
            To create a polynomial path, use @TO polyPath@, which takes a list of polynomials as input. These can be given as elements of a commutative polynomial ring with one generator or directly in @TO2 {"Macaulay2Doc :: listForm", "listForm"}@.
        Example
            R = QQ[t];
            X = polyPath({t,2*t^2,3*t^3})
            Y = polyPath({{({1},1)},{({2},2)},{({3},3)}})
        Text
            While the polynomials must be chosen from a polynomial ring with one generator, the coefficient ring of the polynomials can be chosen arbitrarily.
        Example
            R = QQ[a][t]; --QQ[a,t] will not work!
            X = polyPath({t,2*a*t^2,3*a^2*t^3})
        Text
            An important special case of polynomial paths are linear paths. These can be constructed directly from their increment using @TO linPath@.
        Example
            Y = linPath({2,3,4})
        Text
            Paths can be concatenated using @TO (symbol **, Path, Path)@. This concatenation is formal: the new Path object encodes the polynomial pieces and their order, but no parametrization is chosen. The concatenation @TO (symbol **, Path, Path)@ will automatically select a bigger coefficient ring for all polynomial pieces if an obvious choice is available.
        Example
            Z = X ** Y
        Text
            A piecewise linear path can be constructed directly from the increments of its segments using @TO pwLinPath@.
        Example
            A = matrix {{1,2,3},{2,3,4},{4,5,6}};
            W = pwLinPath(A)
        Text
            To read out the ambient dimension of a path, use @TO (getDimension, Path)@ or @TO (dim, Path)@. To get the pieces of the path in @TO2 {"Macaulay2Doc :: listForm", "listForm"}@ use @TO (getPieces, Path)@. To get the coefficient ring of the coordinate polynomials, use @TO (getCoefficientRing, Path)@ or @TO (coefficientRing, Path)@. Finally, @TO (getNumberOfPieces, Path)@ returns the number of pieces of the path.
        Example
            getDimension(Z) --The ambient dimension of the path
            getPieces(Z) --The polynomial pieces of the path, in listForm
            getCoefficientRing(Z) -- The coefficient ring of the polynomial components of the path
            getNumberOfPieces(Z) -- The number of polynomial pieces of the path
        Text
            To extract the pieces of a concatenated path one can use @TO (symbol _, Path, ZZ)@, @TO (symbol _, Path, List)@ and @TO (symbol _, Path, Sequence)@.
        Example
            Z_0
            Z2 = Z^2
            Z2_{0,-1}
        Text
            When considering the set of paths modulo tree-like equivalence, concatenation turns it into a groupoid. Use @TO (symbol ^, Path, ZZ)@ to compute powers and the inverse of a path in this groupoid. Note that the inverse of a path is just given by reversing its parametrization.
        Example
            X^4
            X^(-1)

    SeeAlso
        polyPath
        linPath

Node 
    Key
        concatPath
        (concatPath, Path, Path)
        (symbol **, Path, Path)
    Headline
        concatenation of paths
    Usage 
        concatPath(X,Y)
        X**Y
    
    Description
        Text
            This allows for concatenation of paths. The concatenation is formal, no parametrization is chosen.
        Example
            R = QQ[t];
            X = polyPath({t,t^2}) ** polyPath({t^3 + 3*t, t^2 - 1})
    SeeAlso
        polyPath
        linPath
Node
    Key
        (substitute,Path, Ring)
    Headline
        changes the coefficient ring of a path
    Usage
        Y = substitute(X,R)
    Inputs
        X: Path
        R: Ring -- an algebra over the coefficient ring of the polynomials defining X
    Outputs
        Y: Path -- a path with the same pieces as X but whose coordinate functions are now polynomials with coefficients in R
    Description
        Text
            Tries to substitute the coefficients of the polynomials defining the given path into the given ring, producing a new path.
        Example
            R = QQ[t];
            X = polyPath({t,t^2})
            coefficientRing X
            A = QQ[a];
            Y = substitute(X,A)
            coefficientRing Y
Node
    Key
        polyPath
        (polyPath,List)
    Headline
        constructor of single piece polynomial path
    Usage
        polyPath(polyPathList)
    Inputs
        polyPathList: List --A list of elements of the same ring, the components of the polynomial path.
    Outputs
        X: Path
    Description
        Text
            Takes as input a list of polynomials in the same ring. Constructs a @TO Path@ object with one piece equal to the list of normalForm 
            of the polynomial components of the path given in input. Automatically sets the dimension attribute of the
            object to the length of the list given as input.
        Example
            R = QQ[t];
            X = polyPath({t,t^2})
            X // getDimension 
    SeeAlso
        Path
        linPath
        (symbol **, Path, Path)

Node 
    Key
        linPath
        (linPath, List)
    Headline
        constructor of single piece polynomial path
    Usage
        linPath(v)
    Inputs
        v: List -- A list of elements of a ring, the endpoints of the linear path.
    Outputs
        X: Path
    Description
        Text
            Takes as input a list of elements in the same ring. Constructs a @TO Path@ object with one piece equal to the list given in input. Automatically sets the dimension attribute of the
            object to the length of the list given as input.
        Example
            R = QQ[x_1..x_5];
            X = linPath({x_1, x_2, x_3, x_4, x_5^2})
            X // getDimension
    SeeAlso
        Path
        polyPath
        (symbol **, Path, Path)
Node 
    Key
        pwLinPath
        (pwLinPath,Matrix)
    Headline
        constructor of a piecewise linear path from a matrix
    Inputs
        pwlMatrix: Matrix -- A matrix containing on its columns the articulation points (or increments) of the path
    Outputs
        X: Path --A piecewise linear path of dimension the number of rows of the input and with the same number of pieces as the columns of the input
    Usage
        pwLinPath(pwlMatrix)
    Description
        Text
            Creates a piecewise lienar @TO Path@ whose increments are the columns of the given matrix.
        Example
            M = id_(QQ^3)
            pwLinPath(M)
    SeeAlso
        Path


///