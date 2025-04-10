needsPackage "GraphicalModels";

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
