needsPackage "Matroids"
signedCircuits=N -> (
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
end
