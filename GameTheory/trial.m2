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
      {Name => "Erin Connelly",
         Email => "erin.connelly@uni-osnabrueck.de",
         HomePage => "https://erinconnelly96.github.io/"},
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


----------------------------------------
-- Documentation toMarkovRing         --
----------------------------------------

doc ///
Key
 toMarkovRing
 (toMarkovRing, Ring)
Headline
 ring of joint probability distributions created with the markovRing function from the GraphicalModels package
Usage
 toMarkovRing R
Inputs
 R:PolynomialRing
 created using the probabilityRing method
Outputs
 :PolynomialRing
 a polynomial ring isomorphic to the input ring created by the markovRing method from the GraphicalModels pacakge,
 with variables $q_{(i_1+1, \dots , i_k+1)}$ corresponding to the variables $p_{\{i_1, \ldots, i_k\}}$
 of the input ring
Description
Text
 Given a ring created with the probabilityRing function, this function creates the canonically isomorphic ring
 defined by the markovRing function from the GraphicalModels package.
 The variable name of the output ring is set to be different from the variable name of the input ring:
 the default variable name of the output ring is "p",
 and if the variable name of the input ring is "p" then the variable name of the output ring becomes "q".

Example
 R = probabilityRing({2,3,4}, CoefficientRing => ZZ/32003, ProbabilityVariableName => "x")
 markovR = toMarkovRing R
 numgens markovR
 R_0, R_11, R_23

SeeAlso
 probabilityRing
 gaussianRing

///


--------------------------------------
-- Documentation mapToMarkovRing    --
--------------------------------------

doc ///

Key
 mapToMarkovRing
 (mapToMarkovRing, Ring)
Headline
 ring isomorphism from the given probabilityRing to the corresponding markovRing
Usage
 mapToMarkovRing R
Inputs
 R:Ring
 must be a probabilityRing
Outputs
 :RingMap
 the isomorphism identifying R with toMarkovRing(R).
 The variable $p_{\{i_1, \ldots, i_k\}}$ is sent to $q_{(i_1+1, \dots , i_k+1)}$.
 
Description
 Text
  This function creates the RingMap from a given probabilityRing to its canonically isomorphic
  markovRing.
 Example
  R = probabilityRing {2,3,4}
  markovR = toMarkovRing R
  F = mapToMarkovRing R
  target F
  source F
  isInjective F
  F.matrix

SeeAlso
 toMarkovRing
 mapToProbabilityRing

///

-------------------------------------------
-- Documentation mapToProbabilityRing    --
-------------------------------------------

doc ///
Key
 mapToProbabilityRing
 (mapToProbabilityRing, Ring)
Headline
 ring isomorphism to the given probabilityRing from the corresponding markovRing
Usage
 mapToProbabilityRing R
Inputs
 R:Ring
   must be a probabilityRing
Outputs
 :RingMap
 the isomorphism identifying R with toMarkovRing(R).
 The variable $q_{(i_1+1, \dots , i_k+1)}$ is sent to $p_{\{i_1, \ldots, i_k\}}$.
 
Description
 Text
  This function creates the RingMap to a given probabilityRing from its canonically isomorphic
  markovRing.
 Example
  R = probabilityRing {2,3,4}
  markovR = toMarkovRing R
  F = mapToProbabilityRing R
  target F
  source F
  isInjective F
  F.matrix

SeeAlso
 toMarkovRing
 mapToProbabilityRing

///

--------------------------------
-- Documentation ciIdeal      --
--------------------------------

doc ///
Key
 ciIdeal
 (ciIdeal, Ring, List)
 (ciIdeal, Ring, Graph)
 (ciIdeal, Ring, List, List)
 (ciIdeal, Ring, Graph, List)
Headline
 the ideal of a list of conditional independence statements
Usage
 ciIdeal (R, Stmts)
 ciIdeal (R, G)
 ciIdeal (R, Stmts, PlayerNames)
 ciIdeal (R, G, PlayerNames)
Inputs
 R:Ring
   must be created using probabilityRing
 Stmts:List
   the list of conditional independence statements 
 G:Graph
   the graph modelling the conditional dependencies between players
 PlayerNames:List
   the ordered list of players - the names of the random variables in the conditional independence
   statements or vertices of the graph. If PlayerNames is omitted, the players
   (or the vertices of G) are assumed to be labelled 1..n.
Outputs
 :Ideal
 the ideal in R of conditional independence relations
Description
 Text
  {\tt ciIdeal} computes the ideal of a list of conditional independence statements.
  The input can be the list of conditional independence statements itself,
  or a graph modelling the conditional dependencies between players.

  A single conditional independence statement is a list consisting of three disjoint
  lists of indices for random variables, e.g. $\{ \{1,2\},\{4\}, \{3\} \}$
  which represents the conditional independence statement ``$(X_1, X_2)$
  is conditionally independent of $X_4$ given $X_3$''.
  Given an undirected graph $G$, the conditional independence statements are produced via
  the globalMarkov function from the GraphicalModels package. A global Markov statement
  for $G$ is a list $\{A, B, C\}$ of three disjoint lists of vertices of $G$, where the
  subset $C$ separates the subset $A$ from the subset $B$ in the graph $G$.  

  The output is an ideal of the given ring PR, which must be created using the
  probabilityRing function. This function computes the ideal using the
  conditionalIndependenceIdeal function from the GraphicalModels package, then
  maps it to an ideal of PR via the mapToProbabilityRing function.

 Example
     FF = ZZ/32003
     d = {2,3,2};
     PR = probabilityRing (d, CoefficientRing => FF);
     G = graph ({}, Singletons => {1,2,3});
     I = ciIdeal (PR, G)

    Text
      Here is an example where the vertices of the graph need to be relabeled.
      
    Example  
     FF = ZZ/32003
     d = {2,3,2};
     PR = probabilityRing (d, CoefficientRing => FF);
     G = graph {{John,Matthew},{Matthew,Sarah}};
     I = ciIdeal (PR, G, {John,Matthew,Sarah})
     
    Text
      Here is an example where the conditional independence relations are given with a List.

    Example
      FF = ZZ/32003
      d = {2,3,2};
      PR = probabilityRing (d, CoefficientRing => FF);
      G = graph {{1,2},{2,3}};
      L = {{{1},{3},{2}}}
      I1 = ciIdeal (PR,G)
      I2 = ciIdeal (PR,L)
      I1 == I2
 
  SeeAlso
    conditionalIndependenceIdeal 
    mapToProbabilityRing
    toMarkovRing
    ciIdeal
    globalMarkov
///


--------------------------------------------
-- Documentation intersectWithCImodel     --
--------------------------------------------

doc ///
  Key
    intersectWithCImodel
    (intersectWithCImodel, Ideal, List)
    (intersectWithCImodel, Ideal, List, List)
    (intersectWithCImodel, Ideal, Graph)
    (intersectWithCImodel, Ideal, Graph, List) 
  Headline
    The ideal of the intersection of a given variety with the conditional independence model
  Usage
    intersectWithCImodel(V, Stmts)
    intersectWithCImodel(V, Stmts, PlayerNames)
    intersectWithCImodel(V, G)
    intersectWithCImodel(V, G, PlayerNames)
  Inputs
    V:Ideal 
      An ideal of a ring created with probabilityRing 
    Stmts:List
      the list of conditional independence statements 
    G:Graph
      the graph modelling the conditional dependencies between players
    PlayerNames:List
      the ordered list of players - the names of the random variables in the conditional independence
      statements or vertices of the graph. If PlayerNames is omitted, the players
      (or the vertices of G) are assumed to be labelled 1..n.    
  Outputs
    :Ideal 
       The ideal of the intersection of the given variety with the conditional independence model
       determined by the conditional independence statements/graph. 
  Description
    Text
      {\tt intersectWithCImodel} calculates the ideal of the intersection of the given variety V with
      the conditional independence model determined by a set of conditional probability statements or an undirected graph.
      More precisely, the output is the ideal of the closure of the variety given by removing the components in
      the coordinate hyperplanes from the intersection of the variety V and the conditional independence
      model.

      The input for the conditional independence model can be a set of conditional probability statements or
      an undirected graph.
      A single conditional independence statement is a list consisting of three disjoint
      lists of indices for random variables, e.g. $\{ \{1,2\},\{4\}, \{3\} \}$
      which represents the conditional independence statement ``$(X_1, X_2)$
      is conditionally independent of $X_4$ given $X_3$''. In the context of game theory, the variable
      $X_i$ represents the strategy of player $i$.

      Given an undirected graph $G$, the conditional independence statements are produced via
      the globalMarkov function from the GraphicalModels package. A global Markov statement
      for $G$ is a list $\{A, B, C\}$ of three disjoint lists of vertices of $G$, where the
      subset $C$ separates the subset $A$ from the subset $B$ in the graph $G$.
    Example
     FF = ZZ/32003
     d = {2,2,2};
     X = randomGame(d, CoefficientRing => FF);
     PR = probabilityRing(d, CoefficientRing => FF);
     V = spohnIdeal(PR, X);
     G1 = graph ({}, Singletons => {1,2,3});
     G2 = graph ({{1,2}}, Singletons => {3});
     I1 = intersectWithCImodel(V, G1)
     I2 = intersectWithCImodel(V, G2)

    Text
      Here is an example where the vertices of the graph need to be relabeled.
      
    Example  
     FF = ZZ/32003;
     d = {2,2,2};
     X = randomGame(d, CoefficientRing => FF);
     PR = probabilityRing(d, CoefficientRing => FF);
     V = spohnIdeal(PR, X);
     G1 = graph {{John,Matthew},{Matthew,Sarah}};
     G2 = graph {{a,b},{b,c},{c,a}};
     I1 = intersectWithCImodel(V, G1, {John,Matthew,Sarah})
     I2 = intersectWithCImodel(V, G2, {a,b,c}) 
      
    Text
      Here is an example where the conditional independence relations are given with a List.

    Example
      FF = ZZ/32003;
      d = {2,2,2};
      X = randomGame(d, CoefficientRing => FF);
      PR = probabilityRing(d, CoefficientRing => FF);
      V = spohnIdeal(PR, X);
      G = graph ({{1,2}},Singletons => {3});
      L = {{{1,2},{3},{}}};
      I1 = intersectWithCImodel(V, G)
      I2 = intersectWithCImodel(V, L)
      I1 == I2

    Text
      The Verbose=>true option prints the progress of each step in the saturation process -
      a message is printed after saturating the ideal $V$, the conditional independence ideal $I$,
      and the sum $V + I$ with respect to each hyperplane of the probablity simplex.
    Example
      FF = ZZ/32003;
      d = {2,3,2};
      X = randomGame(d, CoefficientRing => FF);
      PR = probabilityRing(d, CoefficientRing => FF);
      V = spohnIdeal(PR, X);
      L = {{{1,2},{3},{}}};
      I = intersectWithCImodel(V, L, Verbose=>true);
 
  SeeAlso
    conditionalIndependenceIdeal 
    mapToProbabilityRing
    toMarkovRing
    ciIdeal
    globalMarkov
///

--------------------------------------------
-- Documentation spohnCI
--------------------------------------------

doc ///
  Key
    spohnCI
    (spohnCI, Ring, List, Graph)
    (spohnCI, Ring, List, Graph, List)
    (spohnCI, Ring, List, List)
    (spohnCI, Ring, List, List, List) 
  Headline
    The ideal of the Spohn conditional independence (CI) variety
  Usage
    spohnCI(PR, X, G)
    spohnCI(PR, X, G, PlayerNames)
    spohnCI(PR, X, Stmts)
    spohnCI(PR, X, Stmts, PlayerNames)
  Inputs
    PR:Ring 
      The probability ring (must be created with {\tt probabilityRing})
    X:List 
      The game tensor
    G:Graph
      The graph specifying the conditional independence conditions
    Stmts:List
      A list of lists {L1,L2,L3} corresponding to the relation "L1 and L2 are conditionally independent given L3".    
    PlayerNames:List
      the ordered list of players - the names of the random variables in the conditional independence
      statements or vertices of the graph. If PlayerNames is omitted, the players
      (or the vertices of G) are assumed to be labelled 1..n.
  Outputs
    :Ideal 
       The ideal of the Spohn CI variety
  Description
    Text
      {\tt spohnCI} computes the ideal of the Spohn conditional independence variety for a game $X$ and
      conditional independence model determined by an undirected graph $G$ or set of conditional
      independence statements $Stmts$.
      
    Example
      FF = ZZ/32003
      d = {2,2,2};
      X = randomGame(d, CoefficientRing => FF);
      PR = probabilityRing(d, CoefficientRing => FF);
      G1 = graph ({}, Singletons => {1,2,3});
      G2 = graph ({{1,2}}, Singletons => {3});
      I1 = spohnCI(PR,X,G1)
      I2 = spohnCI(PR,X,G2)
      
    Text
      Here is an example where the vertices of the graph need to be relabeled.
      
    Example  
      FF = ZZ/32003
      d = {2,3,2};
      X = randomGame(d, CoefficientRing => FF);
      PR = probabilityRing(d, CoefficientRing => FF);
      G1 = graph {{John,Matthew},{Matthew,Sarah}};
      G2 = graph {{a,b},{b,c},{c,a}};
      I1 = spohnCI(PR,X,G1, {John,Matthew,Sarah})
      I2 = spohnCI(PR,X,G2, {a,b,c}) 
      
    Text
      Here is an example where the conditional independence relations are given with a List.

    Example
      FF = ZZ/32003
      d = {2,2,2};
      X = randomGame(d, CoefficientRing => FF);
      PR = probabilityRing(d, CoefficientRing => FF);
      G = graph ({{1,2}},Singletons => {3});
      L = {{{1,2},{3},{}}};
      I1 = spohnCI(PR,X,G)
      I2 = spohnCI(PR,X,L)
      I1 == I2
 
  SeeAlso
    spohnIdeal
    ciIdeal
    intersectWithCImodel
    conditionalIndependenceIdeal
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



--------------------------------------
-- TEST toMarkovRing
--------------------------------------

TEST///
    R = probabilityRing({2,3,4}, CoefficientRing => ZZ/32003, ProbabilityVariableName => "x");
    markovR = toMarkovRing R;
    correctGens = {p_(1,1,1), p_(1,1,2), p_(1,1,3), p_(1,1,4), p_(1,2,1), p_(1,2,2),
      p_(1,2,3), p_(1,2,4), p_(1,3,1), p_(1,3,2), p_(1,3,3), p_(1,3,4),
      p_(2,1,1), p_(2,1,2), p_(2,1,3), p_(2,1,4), p_(2,2,1), p_(2,2,2),
      p_(2,2,3), p_(2,2,4), p_(2,3,1), p_(2,3,2), p_(2,3,3), p_(2,3,4)};
    assert(gens markovR === correctGens)
///


--------------------------------------
-- TEST mapToMarkovRing
--------------------------------------

TEST///
    R = probabilityRing({2,3,4}, CoefficientRing => ZZ/32003, ProbabilityVariableName => "x");
    markovR = toMarkovRing R;
    F = mapToMarkovRing R;
    assert(target F === markovR)
    assert(source F === R)
    assert(isInjective F === true)
///


--------------------------------------
-- TEST mapToProbabilityRing
--------------------------------------

TEST///
    R = probabilityRing({2,3,4}, CoefficientRing => ZZ/32003, ProbabilityVariableName => "x");
    markovR = toMarkovRing R;
    F = mapToMarkovRing R;
    assert(target F == R)
    assert(source F == markovR)
    assert(isInjective F == true)
///

--------------------------------------
-- TEST ciIdeal
--------------------------------------

TEST///
     FF = ZZ/32003
     PR = probabilityRing(d, CoefficientRing => FF);
     G1 = graph ({{1,2},{2,3},{1,3}});
     G2 = graph ({}, Singletons => {1,2,3});
     I1 = ciIdeal(PR, G1);
     I2 = ciIdeal(PR, G2);
     assert(I1_0==0)
     assert(numcols mingens I2 == 9)
///

TEST///
     FF = ZZ/32003
     PR = probabilityRing(d, CoefficientRing => FF);
     G = graph ({{1,2},{2,3}});
     I = ciIdeal(PR, G);
     assert(I==ideal(-p_{0, 0, 1}*p_{1, 0, 0}+p_{0, 0, 0}*p_{1, 0, 1},-p_{0, 1, 1}*p_{1, 1, 0}+p_{0, 1, 0}*p_{1, 1, 1}))
///

--------------------------------------
-- TEST intersectWithCImodel
--------------------------------------

TEST///
     FF = ZZ/32003
     d = {2,3,2};
     X = randomGame(d, CoefficientRing => FF);
     PR = probabilityRing(d, CoefficientRing => FF);
     G = graph ({{1,2}},Singletons => {3});
     L={{{1,2},{3},{}}};
     V = spohnIdeal(PR, X);
     I1 = intersectWithCImodel(V, L);
     I2 = intersectWithCImodel(V, G);
     assert(I1==I2)
     assert(numcols mingens I1 == 20)
///

TEST///
     FF = ZZ/32003
     d = {2,2,2};
     X = randomGame(d, CoefficientRing => FF);
     PR = probabilityRing(d, CoefficientRing => FF);
     G = graph ({{1,2},{2,3},{1,3}});
     V = spohnIdeal(PR, X);
     I = intersectWithCImodel(V, G);
     assert(V==I)
///

--------------------------------------
-- TEST spohnCI
--------------------------------------

TEST///
     FF = ZZ/32003
     d = {2,3,2};
     X = randomGame(d, CoefficientRing => FF);
     PR = probabilityRing(d, CoefficientRing => FF);
     G = graph ({{1,2}},Singletons => {3});
     L={{{1,2},{3},{}}};
     V = spohnIdeal(PR, X);
     I1 = spohnCI(PR, X, L);
     I2 = spohnCI(PR, X, G);
     assert(I1==I2)
///

TEST///
     FF = ZZ/32003
     d = {2,2,2};
     X = randomGame(d, CoefficientRing => FF);
     PR = probabilityRing(d, CoefficientRing => FF);
     V = spohnIdeal(PR, X);
     G = graph ({{1,2},{2,3}});
     I = spohnCI(PR, X, G);
     assert(numcols mingens I==8))
///

TEST///
     FF = ZZ/32003
     d = {2,2,2};
     X = randomGame(d, CoefficientRing => FF);
     PR = probabilityRing(d, CoefficientRing => FF);
     G = graph ({{1,2},{2,3},{1,3}});
     V = spohnIdeal(PR, X);
     I = spohnCI(PR, X, G);
     assert(V==I)
///
