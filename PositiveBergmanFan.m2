newPackage(
    "PositiveBergmanFan",
    Version => "0.1",
    Date => "November 2024",
    Headline => "Methods for computing positive Bergman fans",
    Authors => {{ Name => "Renata Picciotto, Julian Weigert, Alheydis Geiger, Chamir Ngandjia, Mate Telek", Email => "", HomePage => ""}},
    AuxiliaryFiles => false,
    DebuggingMode => false,
    PackageExports => {"Matroids", "Tropical","Polyhedra"}
    )

export {"signedCircuits","isPositive","positiveBergmanFan","interiorVector"} --add BergmanFan ?

-* Code section *-
--------------------
--Bergman fan code
--------------------
-- BergmanconeC returns the matrix of generators of the cones
-- corresponding to the chain of flats C. It does not check whether C
-- is a chain of flats or not.
-- The following is commented out because we want this changes to happen in the tropical Package, they are only needed for rank 1 matroids
-- The function BergmanconeC is the same s in the Tropical package
-*BergmanconeC  = (M, C) -> (
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
BergmanFan2 = (M) -> (
    if ( loops(M) != {} ) then
	    error("The current method only works for loopless matroids");
    E := toList M.groundSet;
    L := {};
    LM := latticeOfFlats M;
    redLM := dropElements(LM, {{}, E});
    if (redLM_0 != {}) then (   
        redOrdcplx := maximalChains redLM;
        allOnes := apply(E,i->1);
        for C in redOrdcplx do(
        	L = append(L, coneFromVData(BergmanconeC(M,C),transpose matrix {allOnes}));
    	);
        F:= fan L;
        mults:=apply(#(maxCones F),i->1);
        return tropicalCycle(F,mults);    
    )
    else (
        n := #E;
        LS := transpose matrix{apply(n,i->1)};
        Sigma := coneFromVData(map(ZZ^(n),ZZ^0,0), LS);
        return tropicalCycle(fan(Sigma), {1});
    );
)
*-

------------------------------------
--  Code for positive Bermgan Fan --
------------------------------------
-- This function should be fixed in the Polyhedra Package
-- it allows to compute the interior Vector of a cone that is a linear space.
interiorVector Cone := C -> (
            if numColumns rays C == 0 then map(ZZ^(ambDim C),ZZ^1,0)
            else (
                 Rm := rays C;
                 ones := matrix toList(numColumns Rm:{1});
                 -- Take the sum of the rays
                 iv := Rm * ones;
                 transpose matrix apply(entries transpose iv, w -> (g := abs gcd w; apply(w, e -> e//g)))));

--given a matrix it computes the positive and negative parts of the circuits of the matroid arising from the columns
--Input: Matrix, Output: List of lists
signedCircuits = method();
signedCircuits Matrix := K -> (
    M:=matroid K;
    C:=circuits M;
    for c in C list(
		c=toList(c);
		K1:=K_c;
		V:=gens ker(K1);
		Pos:= new MutableList;
		Neg:=new MutableList;
		for i from 0 to numRows(V)-1 do(
			if  V_(i,0)>0 then
				Pos=append(Pos,c#i)
			else Neg=append(Neg,c#i)
		);
		{toList Pos,toList Neg}
	)
);

--take maximal cone S and test if it is positive with the given list of signed circuits C
--Input: Cone, List of lists, Output: Boolean
--Need to check if isPositive works for signed circuits with an empty list
--currently not working in the Terminal ... WHY?
isPositive := (S,C) -> (
    P := entries interiorVector S;
    for c in C do (
        neg := c_1;
        pos := c_0;
        if (neg == {} or pos == {}) then (
            return false;
        );
        if (min P_neg != min P_pos) then (
            return false;
        );
    );
    return true
)
-*isPositive := (S,C) -> (
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
*-

--This function computes the positive part of the Bergman fan. 
--Input: Matrix (the column matrix of the matroid), Output: a fan, OR error message if positive part emtpy
--TO DO: The error message
--TO DO: Special care needs ot be taken if the fan has no maximal cones! Test this and fix.
positiveBergmanFan = method();
positiveBergmanFan Matrix := K ->(
    C := signedCircuits(K);
    M := matroid K;
    T := BergmanFan M;
    Rays := rays T;
    S := maxCones T;
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


doc ///
	Key
		positiveBergmanFan
	Headline
		Compute the positive part of the Bergman fan given a matrix
	Usage
		positiveBergmanFan(matr)
	Inputs
		matr: Matrix
		    realization of matroid as column matrix
	Description
	    Text
	        This function computes the positive part of the Bergman Fan in the sense of Ardila-Klivans-Williams 2004
	    Example
    	        K = matrix {{0,1,1,0,0},{-1,1,0,0,-2},{0,0,0,1,1}}
                P = positiveBergmanFan K
                maxCones P
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
