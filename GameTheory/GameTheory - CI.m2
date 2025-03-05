needsPackage "GraphicalModels";

-- makes the corresponding markovRing from the GraphicalModels package
-- to a given probabilityRing from the DependencyEquilibria.m2 file

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

-- these two methods make RingMaps giving the isomorphisms between the two different types of Ring

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
    

-- the following method has a slightly different name to the original,
-- so that the two can be compared when loading the same file

intersectWithCImodel = method(Options => {Verbose => false})
intersectWithCImodel (Graph, Ideal, List, List) := o -> (G, V, Di, PlayerNames) -> (
    v := o.Verbose;
    R := ring (V);
    markovR := toMarkovRing R;
    F := mapToProbabilityRing(R);
    H := map(R,ZZ);
    S := globalMarkov G;
    I := F(conditionalIndependenceIdeal (markovR, S, PlayerNames));
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
intersectWithCImodel (Graph, Ideal, List) := o -> (G,V,Di) -> (
    v := o.Verbose;
    PlayerNames := toList (1..#Di);
    intersectWithCImodel(G, V, Di, PlayerNames, Verbose=>v)
    )
intersectWithCImodel (List, Ideal, List, List) := o -> (Stmts, V, Di, PlayerNames) -> (
    v := o.Verbose;
    R := ring (V);
    markovR := toMarkovRing R;
    F := mapToProbabilityRing(R);
    H := map(R,ZZ);
    I := F(conditionalIndependenceIdeal (markovR, Stmts, PlayerNames));
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
intersectWithCImodel (List, Ideal, List) := o -> (Stmts, V, Di) -> (
    v := o.Verbose;
    PlayerNames := toList (1..#Di);
    result = intersectWithCImodel (Stmts, V, Di, PlayerNames, Verbose=>v);
    result
    )


spohnCI = method(Options => {Verbose => false})
spohnCI (Graph, Ring, List) := o -> (G, PR, X) -> (
    v := o.Verbose;
    spohn := spohnIdeal(PR, X);
    Di := PR#"gameFormat";
    intersectWithCImodel(G, spohn, Di, Verbose => v)
    )
spohnCI (Graph, Ring, List, List) := o -> (G, PR, X, PlayerNames) -> (
    v := o.Verbose;
    spohn := spohnIdeal(PR, X);
    Di := PR#"gameFormat";
    intersectWithCImodel(G, spohn, Di, PlayerNames, Verbose => v)
    )
spohnCI (List, Ring, List) := o -> (L, PR, X) -> (
    v := o.Verbose;
    spohn := spohnIdeal(PR, X);
    Di := PR#"gameFormat";
    intersectWithCImodel(L, spohn, Di, Verbose => v)
    )
spohnCI (List, Ring, List, List) := o -> (L, PR, X, PlayerNames) -> (
    v := o.Verbose;
    spohn := spohnIdeal(PR, X);
    Di := PR#"gameFormat";
    intersectWithCImodel(L, spohn, Di, PlayerNames, Verbose => v)
    )
