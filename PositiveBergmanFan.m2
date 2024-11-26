newPackage(
    "PositiveBergmanFan",
    Version => "0.1",
    Date => "November 2024",
    Headline => "Methods for computing positive Bergman fans",
    Authors => {{ Name => "Renata Picciotto, Julian Weigert", Email => "", HomePage => ""}},
    AuxiliaryFiles => false,
    DebuggingMode => false,
    PackageExports => {"Matroids", "Tropical"}
    )

export {"signedCircuits"}

-* Code section *-
signedCircuits = method();
signedCircuits Matrix := N -> (
    K:=transpose gens ker N;
    M:=matroid K;
    C:=circuits M;
    for support in C list(
		support=toList(support);
		K1:=K_support;
		V:=gens ker(K1);
		Pos:={};
		Neg:={};
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
