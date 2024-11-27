newPackage(
    "PositiveBergmanFan",
    Version => "0.1",
    Date => "November 2024",
    Headline => "Methods for computing positive Bergman fans",
    Authors => {{ Name => "Renata Picciotto, Julian Weigert, Alheydis Geiger, Chamir Ngandjia", Email => "", HomePage => ""}},
    AuxiliaryFiles => false,
    DebuggingMode => false,
    PackageExports => {"Matroids", "Tropical","Polyhedra"}
    )

export {"signedCircuits","isPositive","positiveBergmanFan","interiorVector"}

-* Code section *-
--------------------
--Bergman fan code
--------------------


-- BergmanconeC returns the matrix of generators of the cones
-- corresponding to the chain of flats C. It does not check whether C
-- is a chain of flats or not.

BergmanconeC  = (M, C) -> (
    groundSetM:=#M.groundSet;
    L := {};
    for F in C do(
    	  vect:={};
    	  scan(groundSetM, i->(
	    if member(i,F) then vect =  append(vect,1) else vect = append(vect,0);
	  ));
	L = append(L, vect)
	);
   transpose  matrix L
)

-- BergmanFan returns the fan of a loopless well-defined matroid
-- ground set must be [n]
-- depends on functions above
BergmanFan = (M) -> (
    if ( loops(M) != {} ) then
	    error("The current method only works for loopless matroids");
    E := toList M.groundSet;
    L := {};
    LM := latticeOfFlats M;
    redLM := dropElements(LM, {{}, E});
    if (redLM != {}) then (   
        redOrdcplx := maximalChains redLM;
        allOnes := apply(E,i->1);
        for C in redOrdcplx do(
        	L = append(L, coneFromVData(BergmanconeC(M,C),transpose matrix {allOnes}));
    	);
        F:= fan L;
        mults:=apply(#(maxCones F),i->1);
        tropicalCycle(F,mults)    
    );
    else (
        n := length E;
        LS := transpose matrix{apply(n,i->1)};
        Sigma := coneFromVData(map(ZZ^(n),ZZ^0,0), LS);
        tropicalCycle(fan(Sigma), {1});
    )
)

------------------------------------
--  Code for positive Bermgan Fan --
------------------------------------
signedCircuits = method();
signedCircuits Matrix := N -> (
    K:=transpose gens ker N;
    M:=matroid K;
    C:=circuits M;
    for support in C list(
		support=toList(support);
		K1:=K_support;
		V:=gens ker(K1);
		Pos:= new MutableList;
		Neg:=new MutableList;
		for i from 0 to numRows(V)-1 do(
			if  V_(i,0)>0 then
				Pos=append(Pos,support#i)
			else Neg=append(Neg,support#i)
		);
		{Pos,Neg}
	)
)

--take maximal cone S and test if it is positive with the given list of signed circuits C
isPositive = (S,C) -> (
    P := entries interiorVector S;
    boo := true;
    for c in C do (
        neg := c_1;
        pos := c_0;
        if (min P_neg != min P_pos) then (
            boo = false;
            break
        );
    );
    return boo;
)



positiveBergmanFan = method();
positiveBergmanFan Matrix := N ->(
    C := signedCircuits(N);
    K := transpose gens ker N;
    M := matroid K;
    T := BergmanFan M;
    Rays := rays T;
    S := maxCones T;
    print S;

    L := new MutableList;
    Sigma := coneFromVData (linealitySpace T);

    for s in S do (
        Sigma = coneFromVData(Rays_s,linealitySpace T);
        print(Sigma);
        if isPositive(Sigma,C) then (
            L=append(L,Sigma); 
        );
    );
    return fan toList(L);
)

-* Documentation section *-
beginDocumentation()

doc ///
    Key
        PositiveBergmanFan
    Headline 
        Methods for computing positive Bergman fans
///



-* Test section *-
TEST /// -* [insert short title for this test] *-
-- test code and assertions here
-- may have as many TEST sections as needed
///

end--

-* Development section *-
restart
debug needsPackage "PositiveBergmanFan"
check "PositiveBergmanFan"

uninstallPackage "PositiveBergmanFan"
restart
installPackage "PositiveBergmanFan"
viewHelp "PositiveBergmanFan"
