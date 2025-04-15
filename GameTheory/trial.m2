newPackage(
   "GameTheory",
   Version => "0.1",
   Date => "April, 2025",
   Authors => {
      {Name => "Irem Portakal",
         Email => "mail@irem-portakal.de",
         HomePage => "https://www.irem-portakal.de"},
      {Name => "Lars Kastner",
         Email => "kastner@math.tu-berlin.de",
         HomePage => "https://lkastner.github.io"},
      {Name => "",
         Email => "",
         HomePage => ""},
      {Name => "",
         Email => "",
         HomePage => ""},,
      {Name => "",
         Email => "",
         HomePage => ""},,
      {Name => "",
         Email => "",
         HomePage => ""},,
      {Name => "",
         Email => "",
         HomePage => ""},,
      {Name => "",
         Email => "",
         HomePage => ""},,
      {Name => "",
         Email => "",
         HomePage => ""},
   },
   Headline => "A package for computing equilibria in game theory",
   Keywords => {"Game Theory","Equilibria","Nash","Correlated","Dependency","Spohn","Conditional Independence"},
   PackageExports => {"Polyhedra","GraphicalModels"},
   PackageImports => {"Polyhedra"}
   )

export {
   "enumerateTensorIndices",
   "Tensor",
   "zeroTensor",
   "randomTensor",
   "slice",
   "getVariableToIndexset",
   "assemblePolynomial",
   "assemblePlayeriPolynomials",
   "correlatedEquilibria"
}



--***************************************--
--  Methods for correlated equlilibria   --
--***************************************--



---------------------------------------------------
-- enumerateTensorIndices ZZ
-- enumerateTensorIndices List
--
-- Returns the list of index tuples for a tensor 
-- with the given dimensions.
--
-- Note: Indices start at 0 and go up to d_i-1,
-- where d_i is the i-th element of the input list.
---------------------------------------------------

enumerateTensorIndices = method()
enumerateTensorIndices ZZ := z -> apply(toList (0..z-1), e->{e})
enumerateTensorIndices List := s -> (
   if length s == 1 then 
      return enumerateTensorIndices s#0
   else
      start := enumerateTensorIndices s#0;
      ri := toList (1..(length(s)-1));
      rest := enumerateTensorIndices s_ri;
      result := {};
      for s in start do
         for r in rest do
            result = append(result, join(s,r));
      result
)

---------------------------------------------------------
-- Defines a new type "Tensor" based on MutableHashTable.
---------------------------------------------------------

Tensor = new Type of MutableHashTable

-----------------------------------------------------------
-- zeroTensor (Ring, List)
--
-- The method creates a zero tensor with the given format and ring.
-----------------------------------------------------------

zeroTensor = method()
zeroTensor List := dims -> zeroTensor(QQ,dims)
zeroTensor(Ring,List) := (R,dims) -> (
   result := new Tensor;
   indexset := enumerateTensorIndices dims;
   for i in indexset do
      result#i = 0_R;
   result#"format" = dims;
   result#"coefficients" = R;
   result#"indexes" = indexset;
   result
)

---------------------------------------------------------------------
-- randomTensor (Ring, List)
--
-- The method creates a random tensor with the given format and ring.
---------------------------------------------------------------------


randomTensor = method()
randomTensor List := dims -> randomTensor(QQ,dims)
randomTensor(Ring,List) := (R,dims) -> (
   result := new Tensor;
   indexset := enumerateTensorIndices dims;
   for i in indexset do
      result#i = random R;
   result#"format" = dims;
   result#"coefficients" = R;
   result#"indexes" = indexset;
   result
)

----------------------------------------------
-- format Tensor
--
-- It prints the format of the defined tensor.
----------------------------------------------

format Tensor := T -> T#"format"
coefficientRing Tensor := T -> T#"coefficients"
indexset = method()
indexset Tensor := T -> T#"indexes"

------------------------------------------------------
-- slice (Tensor, List, List)
--
-- The first list (Lstart) specifies the fixed indices 
-- before the varying position, and the second list 
-- (Lend) specifies the fixed indices after it.
--
-- The method varies the index at the position 
-- given by the length of Lstart, from 0 to d_i-1, 
-- where d_i is the corresponding dimension size.
-----------------------------------------------------


slice = method()
slice (Tensor, List, List) := (T, Lstart, Lend) -> (
   dims := format T;
   iteratingPosition := length Lstart;
   result := {};
   for i from 0 to dims#iteratingPosition -1 do (
      mindex := join(Lstart, {i}, Lend);
      result = append(result, T#mindex);
   );
   result
)


---------------------------------------------------
-- getVariableToIndexset(Ring, List)
--
-- Given a ring R and a list ki representing the
-- indices,returns the corresponding generator.
---------------------------------------------------


getVariableToIndexset = method()
getVariableToIndexset(Ring, List) := (R, ki) -> (
   p := position(apply(gens R, i -> last baseName i), i -> i == ki);
   R_p
)


--------------------------------------------------------
-- assemblePolynomial(Ring, Tensor, List)
--
-- Constructs a single linear inequality (polynomial)
-- representing a deviation condition for correlated 
-- equilibrium constraints.
--
-- Inputs:
--   - PR: Polynomial ring containing variables p_{...}
--   - Xi: Tensor of strategy probabilities
--   - ikl: A list {i, k, l} where:
--        i = player index
--        k = current strategy
--        l = deviating strategy
-------------------------------------------------------


assemblePolynomial = method()
assemblePolynomial(Ring, Tensor, List) := (PR, Xi, ikl) -> (
   FBi := indexset Xi;
   reverseVarMap := new MutableHashTable;
   for k in FBi do (
      reverseVarMap#k = getVariableToIndexset(PR, k);
   );
   i := ikl#0;
   k := ikl#1;
   l := ikl#2;
   use PR;
   kindices := select(FBi, e->e#i==k);
   lindices := select(FBi, e->e#i==l);
   kterm := sum apply(kindices, ki -> Xi#ki*reverseVarMap#ki);
   lterm := sum apply(lindices , li->(tmp := new MutableList from li; tmp#i=k; a := toList tmp; Xi#li*reverseVarMap#a));
   ineq := kterm-lterm;
   ineq
)

-----------------------------------------------------
-- assemblePlayeriPolynomials(Ring, Tensor, ZZ)
--
-- Returns a list of all polynomials for a given
-- player i in a correlated equilibrium.
-----------------------------------------------------


assemblePlayeriPolynomials = method()
assemblePlayeriPolynomials(Ring, Tensor, ZZ) := (PR, Xi, i) -> (
   result := {};
   di := (format Xi)#i;
   for k from 0 to di-1 do (
      for l from 0 to di-1 do (
         poly := assemblePolynomial(PR, Xi, {i,k,l});
         result = append(result, poly);
      );
   );
   result
)

--------------------------------------------------------------
-- correlatedEquilibria(List)
--
-- Inputs:
--   - X: A list of tensors, one for each player's payoff

-- Assembles all incentive constraint polynomials and returns
-- a polytope by adding the probability constraints.
-------------------------------------------------------------


correlatedEquilibria = method()
correlatedEquilibria List := X -> (
   F := coefficientRing (X#0);
   FBi := indexset (X#0);
   p := getSymbol "p";
   PR := F[apply(FBi, fb->p_fb)];
   nplayers := length format X#0;
   L := flatten for i from 0 to nplayers-1 list assemblePlayeriPolynomials(PR, X#i, i);
   polyDim := length FBi;
   vectors := {};
   ineqs := for p in L list apply(generators PR, g -> coefficient(g, p));
   ineqs = (matrix ineqs) || (map identity (F^(#FBi)));
   ineqsrhs := transpose matrix {toList ((numRows ineqs):0_F)};
   eq := matrix {toList ((numColumns ineqs):1_F)};
   eqrhs := matrix {{1_F}};
   polyhedronFromHData(-ineqs, ineqsrhs,eq,eqrhs)
)





--***************************************--
--  Methods for dependency equlilibria   --
--***************************************--



-- ProbabilityRing = new Type of Ring

probabilityRing = method(Options => { CoefficientRing => QQ, ProbabilityVariableName => "p" })
probabilityRing List := Ring => opts -> Di -> (
    J := enumerateTensorIndices Di;
    p := getSymbol opts.ProbabilityVariableName;
    K := opts.CoefficientRing;
    -- R := new ProbabilityRing;
    R := K[apply(J, j -> p_j)];

    P := zeroTensor(R, Di);
    for j in J do P#j = (p_j)_R;
    R#"probabilityVariable" = P;

    R#"gameFormat" = Di;
    R)

-- PayoffProbabilityRing = new Type of ProbabilityRing

payoffProbabilityRing = method(Options => { CoefficientRing => QQ, ProbabilityVariableName => "p", PayoffVariableName => "x" })
payoffProbabilityRing List := Ring => opts -> Di -> (
    J := enumerateTensorIndices Di;
    p := getSymbol opts.ProbabilityVariableName;
    x := getSymbol opts.PayoffVariableName;
    K := opts.CoefficientRing;

    L := toList(0 .. (#Di - 1));
    E := L ** J;
    R := K[apply(E, e -> x_e), apply(J, j -> p_j)];

    P := zeroTensor(R, Di);
    for j in J do P#j = (p_j)_R;
    R#"probabilityVariable" = P;

    X := apply(#Di, i -> zeroTensor(R, Di));
    for i to #Di-1 do
        for j in J do X_i#j = x_(i, j)_R;
    R#"payoffVariable" = X;

    R#"gameFormat" = Di;
    R)

randomGame = method(Options => {CoefficientRing => QQ})
randomGame List := List => opts -> Di -> (
    K := opts.CoefficientRing;
    apply(length Di, i -> randomTensor(K, Di)))

genericGame = method()
genericGame Ring := List => PPR -> (
    Di := PPR#"gameFormat";
    x := PPR#"payoffVariable";
    apply(#Di, i -> (result := new Tensor;
                     J := enumerateTensorIndices Di;
                     apply(J, j -> result#j = x_i#j);
                     result#"format" = Di;
                     result#"coefficients" = PPR;
                     result#"indexes" = J;
                     result)))

spohnMatrices = method()
spohnMatrices (Ring, List) := List => (PR, X) -> (
    p := PR#"probabilityVariable";
    n := length X;
    d := format X_0;
    J := indexset X_0;
    apply(n, i -> matrix apply(d_i, k -> {sum(select(J, j -> j_i==k), j -> p#j),
                                          sum(select(J, j -> j_i==k), j -> (X_i)#j * p#j) })))

spohnIdeal = method()
spohnIdeal (Ring, List) := List => (PR, X) -> (
    M := spohnMatrices(PR, X);
    sum(M, m -> minors(2, m)))

konstanzMatrix = method(Options=>{ KonstanzVariableName => "k" })
konstanzMatrix (Ring, List) := Matrix => opts -> (PR, X) -> (
    k := getSymbol opts.KonstanzVariableName;
    Di := PR#"gameFormat";
    p := PR#"probabilityVariable";
    n := #Di;
    J := enumerateTensorIndices Di;
    konstanzRing := PR[apply(n, i -> k_i)];
    M := spohnMatrices(PR, X);
    LinearForms := apply(n, i -> (M_i * matrix{{(k_i)_konstanzRing}, {-1}} ));
    P := vector(apply(J, j -> p#j));
    fold((M0, M1) -> M0 || M1, 
         apply(n, i -> transpose matrix apply(Di_i,
                                              j -> diff(P, (LinearForms_i)_(j, 0)))))
)



--****************************************************--
--  Methods for conditional independence equlilibria  --
--****************************************************--



------------------------------------------------------------------------
-- toMarkovRing Ring
-- input must be a probabilityRing
------------------------------------------------------------------------

toMarkovRing=method()
toMarkovRing Ring := R -> (
    if not R#?"gameFormat" then error "expected a ring created with probabilityRing";
    d:= R#"gameFormat";
    kk := coefficientRing(R);
    variableName := substring ( 0, 1, toString (gens(R))#0 );
    if variableName == "p" then (
	markovRing(toSequence(d), Coefficients=>kk, VariableName=>"q")
	)
    else (
	markovRing(toSequence(d), Coefficients=>kk)
	)
    )

---------------------------------------------------------------------------------------------------
-- mapToMarkovRing Ring
-- mapToProbabilityRing Ring
-- inputs to both methods must be rings created with probabilityRing
---------------------------------------------------------------------------------------------------

mapToMarkovRing=method()
mapToMarkovRing Ring := R -> (
    markovR := toMarkovRing(R);
    F := map(markovR, R, gens(markovR));
    F
    )

mapToProbabilityRing=method()
mapToProbabilityRing Ring := R -> (
    markovR := toMarkovRing(R);
    F := map(R, markovR, gens(R));
    F
    )

------------------------------------------------------------------------
-- ciIdeal (PR, Stmts, PlayerNames)
-- ciIdeal (PR, Stmts)
-- ciIdeal (PR, G, PlayerNames)
-- ciIdeal (PR, G)
-- gives conditional independence ideal associated to a graogh G
-- or a set of conditional independence statements Stmts
-- as an ideal of the given probabilityRing
--------------------------------------------------------------------------------



ciIdeal = method()
ciIdeal (Ring, List, List) := (PR, Stmts, PlayerNames) -> (
    markovR := toMarkovRing(PR);
    phi := mapToProbabilityRing(PR);
    I := conditionalIndependenceIdeal ( markovR, Stmts, PlayerNames );
    phi I
    )
ciIdeal (Ring, List) := (PR, Stmts) -> (
    markovR := toMarkovRing(PR);
    phi := mapToProbabilityRing(PR);
    I := conditionalIndependenceIdeal ( markovR, Stmts );
    phi I
    )
ciIdeal (Ring, Graph, List) := (PR, G, PlayerNames) -> (
    Stmts := globalMarkov G;
    ciIdeal (PR, Stmts, PlayerNames)
    )
ciIdeal (Ring, Graph) := (PR, G) -> (
    Stmts := globalMarkov G;
    ciIdeal (PR, Stmts)
    )

-----------------------------------------------
-- intersectWithCImodel (V, Stmts, PlayerNames)
-- intersectWithCImodel (V, Stmts)
-- intersectWithCImodel (V, G, PlayerNames)
-- intersectWithCImodel (V, G)
-----------------------------------------------


intersectWithCImodel = method(Options => {Verbose => false})
intersectWithCImodel (Ideal, List, List) := o -> (V, Stmts, PlayerNames) -> (
    v := o.Verbose;
    R := ring V;
    H := map (R,ZZ);
    I := ciIdeal (R, Stmts, PlayerNames);
    if I + V == H(ideal(1)) then (
	result := H(ideal(1));
	result
	);
    for k from 0 to length(R_*)-1 do (
	I = saturate(I,R_k,Strategy=>Bayer);
	if v then print ("Completed step " | k+1 | " of saturating CI ideal");
	V = saturate(V,R_k,Strategy=>Bayer);
	if v then print ("Completed step " |k+1| " of saturating input ideal");
	);
    I = saturate(I,sum(R_*),Strategy=>Bayer);
    if v then print ("Completed step " |length(R_*)+1| " of saturating CI ideal");
    V = saturate(V, sum(R_*), Strategy=>Bayer);
    if v then print ("Completed step " |length(R_*) +1|" of saturating input ideal");
    J := I+V;
    for k from 0 to length(R_*)-1 do (
	J = saturate(J,R_k,Strategy=>Bayer);
	if v then print ("Completed step "|k+1|" of saturating sum");
	);
    J = saturate(J,sum(R_*),Strategy=>Bayer);
    result = J;
    result
    )
intersectWithCImodel (Ideal, List) := o -> (V, Stmts) -> (
    v := o.Verbose;
    d := (ring V)#"gameFormat";
    PlayerNames := toList (1..#d);
    intersectWithCImodel (V, Stmts, PlayerNames, Verbose=>v)
    )
intersectWithCImodel (Ideal, Graph, List) := o -> (V, G, PlayerNames) -> (
    v := o.Verbose;
    Stmts := globalMarkov G;
    intersectWithCImodel (V, Stmts, PlayerNames, Verbose=>v)
    )
intersectWithCImodel (Ideal, Graph) := o -> (V, G) -> (
    v := o.Verbose;
    d := (ring V)#"gameFormat";
    PlayerNames := toList (1..#d);
    intersectWithCImodel (V, G, PlayerNames, Verbose=>v)
    )

--------------------------------------
-- spohnCI (PR, X, G)
-- spohnCI (PR, X, G, PlayerNames)
-- spohnCI (PR, X, Stmts)
-- spohnCI (PR, X, Stmts, PlayerNames)
--------------------------------------


spohnCI = method(Options => {Verbose => false})
spohnCI (Ring, List, Graph) := o -> (PR, X, G) -> (
    v := o.Verbose;
    spohn := spohnIdeal(PR, X);
    intersectWithCImodel(spohn, G, Verbose => v)
    )
spohnCI (Ring, List, Graph, List) := o -> (PR, X, G, PlayerNames) -> (
    v := o.Verbose;
    spohn := spohnIdeal(PR, X);
    intersectWithCImodel(spohn, G, PlayerNames, Verbose => v)
    )
spohnCI (Ring, List, List) := o -> (PR, X, Stmts) -> (
    v := o.Verbose;
    spohn := spohnIdeal(PR, X);
    intersectWithCImodel(spohn, Stmts, Verbose => v)
    )
spohnCI (Ring, List, List, List) := o -> (PR, X, Stmts, PlayerNames) -> (
    v := o.Verbose;
    spohn := spohnIdeal(PR, X);
    intersectWithCImodel(spohn, Stmts, PlayerNames, Verbose => v)
    )


--******************************************--
-- DOCUMENTATION     	       	    	    -- 
--******************************************--

beginDocumentation()

doc ///
  Key
    GameTheory
  Headline
    A package for computing equilibria in game theory 
  Description
  
    Text
      {\bf Game Theory} is a package for several equilibrium concepts in game theory. It constructs the algebraic and
      combinatorial models for Nash, correlated, dependency and conditional independence equilibria.
       
      This package constructs ...
      
      Here is a typical use of this package.  

      
    Text
      
      
    Example
        
      
    Text
      The following people have generously contributed their time and effort to this project:  
      
      Name name<@HREF""@>.
      
  Caveat
     GameTheory requires GraphicalModels.m2...
///;


--------------------------------
-- Documentation randomTensor --
--------------------------------

doc ///
  Key
    randomTensor
    (randomTensor, List)
    (randomTensor, Ring, List)
  Headline
    construct a tensor with random entries from a given ring
  Usage
    randomTensor format
    randomTensor(R, format)
  Inputs
    format: 
      :List 
        A list of integers specifying the format of the tensor (e.g. {2,2,2} creates a 2x2x2 tensor)
    R: 
      @Ring@
        (Optional) A ring from which random coefficients will be drawn.
  Outputs
    :Tensor
      A tensor whose entries are randomly selected elements of the ring.
  Description

    Text
      This method constructs a tensor with the specified format and fills it with random elements from the given ring.
      Internally, it uses a hash table where each key is a multi-index (a list of positions) and the value is a random 
      element from the ring. Metadata such as the format, coefficient ring, and index set are stored in the 
      tensor as well.

    Example
      T = randomTensor {2,2,2}
      T#{0,1,1}
      format T
      peek T

    SeeAlso
      zeroTensor
/// 


----------------------------------------
-- Documentation correlatedEquilibria --
----------------------------------------

doc ///
  Key
    correlatedEquilibria
    (correlatedEquilibria, List)
  Headline
    compute the correlated equilibria polytope for a game
  Usage
    correlatedEquilibria X
  Inputs
    X:
      :List
        A list of tensors, one for each player. Each tensor encodes the payoffs for that player.
  Outputs
    :Polyhedron
      The polytope representing the set of correlated equilibria for the game.
  Description

    Text
      This method constructs and returns the correlated equilibrium polytope for a finite game.
      The input is a list of payoff tensors, one for each player. The tensor at position i gives the payoffs for player i.

    Example
      X1 = zeroTensor(QQ, {2,2});
      X2 = zeroTensor(QQ, {2,2});
      X0#{0,0} = -99; X0#{0,1} = 1; X0#{1,0} = 0; X0#{1,1} = 0;
      X1#{0,0} = -99; X1#{0,1} = 0; X1#{1,0} = 1; X1#{1,1} = 0;
      
      CE = correlatedEquilibria {X1, X2}
      vertices CE
      facets CE

    Example
      X1 = randomTensor(QQ, {2,2,3})
      X2 = randomTensor(QQ, {2,2,3})
      X3 = randomTensor(QQ, {2,2,3})
      
      CE = correlatedEquilibria {X1, X2, X3}
      vertices CE
      dim CE

      
  SeeAlso
    assemblePolynomial
    assemblePlayeriPolynomials
///


--******************************************--
-- TESTS     	       	    	      	    --
--******************************************--

-----------------------------------
--- TEST enumerateTensorIndices ---
-----------------------------------

TEST ///
assert(enumerateTensorIndices 3 === {{0}, {1}, {2}})
assert(enumerateTensorIndices {2,2} === {
    {0,0}, {0,1},
    {1,0}, {1,1}
})
assert(enumerateTensorIndices {2,1,2} === {
    {0,0,0}, {0,0,1},
    {1,0,0}, {1,0,1}
})
///

-----------------------
--- TEST zeroTensor ---
-----------------------

TEST ///
T = zeroTensor(QQ, {2,2})
assert(class T === Tensor)
assert(format T === {2,2})
assert(coefficientRing T === QQ)
assert(indexset T === {{0,0},{0,1},{1,0},{1,1}})
assert(all(select(keys T, k -> class k === List), k -> T#k == 0_QQ))
///

-------------------------
--- TEST randomTensor ---
-------------------------

TEST ///
T = randomTensor(QQ, {2,2})
assert(class T === Tensor)
assert(format T === {2,2})
assert(coefficientRing T === QQ)
assert(indexset T === {{0,0},{0,1},{1,0},{1,1}})
-- testing randomness is tricky.
///

------------------
--- TEST slice ---
------------------

TEST ///
T = zeroTensor(QQ, {2,3,2});
T#{0,0,0} = 5;
T#{0,1,0} = 6;
T#{0,2,0} = 7;
S = slice(T, {0}, {0});
assert(S === {5,6,7});
///

----------------------------------
--- TEST getVariableToIndexset ---
----------------------------------



----------------------------
--- TEST assemblePolynomial ---
----------------------------

---------------------------------------
--- TEST assemblePlayeriPolynomials ---
---------------------------------------



---------------------------------
--- TEST correlatedEquilibria ---
---------------------------------

TEST ///
X1 = randomTensor(QQ, {2,2,2})
X2 = randomTensor(QQ, {2,2,2})
X3 = randomTensor(QQ, {2,2,2})
CE = correlatedEquilibria {X1, X2, X3}
assert(class CE === Polyhedron)
assert(#vertices CE >= 1) -- CE polytope must be non-empty
///

---------------------------------
--- TEST correlatedEquilibria ---
---------------------------------

TEST ///
X1 = zeroTensor(QQ, {2,2});
X2 = zeroTensor(QQ, {2,2});
X0#{0,0} = -99; X0#{0,1} = 1; X0#{1,0} = 0; X0#{1,1} = 0;
X1#{0,0} = -99; X1#{0,1} = 0; X1#{1,0} = 1; X1#{1,1} = 0;
assert(class CE === Polyhedron)
assert(#vertices CE > ------
///
