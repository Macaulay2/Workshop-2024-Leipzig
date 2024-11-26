needsPackage "NCAlgebra"

-----------------------------------------
--Signature of a linear path
-----------------------------------------
linsig = method()
linsig (List, List) := QQ => (u, w)-> (
    h := length (w);
    if h==0 then (return(1));
    product(h, i-> u#(w#i-1))/(h!)
)


-----------------------------------------
--Signature of a piecewise linear path
--Build calling recursively linsig
-----------------------------------------
pwlsigw = method()
pwlsigw (List, List) := QQ => (M, w)-> (
    h := length (w); 
    m := length(M);

    --base case
    if(m==1) then return linsig(M#0,w);     
    
    --matrix check
    if not(isMatrix(M)) then(               
        error("Expected list representing matrix, got list of lists of lengths:",for i from 0 to length(M)-1 list length(M_i)) ;
    );

    -- First m-1 pieces
    Mrec := M_{0..m-2};
    -- last piece
    Mlast := M#(m-1);

    sum(h+1, i -> (
        pwlsigw(Mrec, w_{0..i-1})*linsig(Mlast,w_{i..h-1}))
    )
);


----------------------------------------
--Checks if a list represents a matrix
----------------------------------------
isMatrix = method()
isMatrix (List) := Boolean => M ->(
    lens := for i from 0 to length(M)-1 list length(M_i); 
    if(#(set(lens))>1) then(
        return false
    );
    return true
)

ncMonToList = method()
ncMonToList (NCRingElement) := List => f -> (
    fmons = keys f.terms;
    monKey = (keys fmons#0)#1;
    (fmons#0)#(monKey) / ( i -> last baseName i)
);

linExt = method();
linExt(FunctionClosure, NCRingElement) := RingElement => (fun, w) -> (
    lot := apply(terms f, i -> {leadCoefficient i, ncMonToList(i)});
    sum(length(lot),i->(lot#i)#0 * fun((lot#i)#1))
)

pwlsig = method();
pwlsig (Matrix, NCRingElement) := QQ => (M, w)-> (
    Mentries = entries M;
    linExt(i->pwlsigw(Mentries,i),w)
);

R = QQ{l_1..l_5};
f = 1/2*(l_1*l_2 - l_2*l_1);
A = {{2,0},{0,2},{-2,0},{0,-2}}
pwlsig(A, f)
