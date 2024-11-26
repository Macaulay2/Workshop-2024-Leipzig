newPackage(
    "PositiveBergmanFan",
    Version => "0.1",
    Date => "November 2024",
    Headline => "Methods for computing positive Bergman fans",
    Authors => {{ Name => "Renata Picciotto", Email => "", HomePage => ""}},
    AuxiliaryFiles => false,
    DebuggingMode => false,
    PackageExports => {"Matroids", "Tropical"}
    )

export {"signedCircuits"}

-* Code section *-
signedCircuits = method()
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
