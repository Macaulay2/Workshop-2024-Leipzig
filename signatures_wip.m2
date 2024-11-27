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

polyIntegral = method()
polyIntegral (RingElement, RingElement) := RingElement => (f, xn) ->(
    R := ring f;
    indexn := index xn;
    termsf := terms f;
    return sum(apply(termsf, i->(
        i = i/((((exponents(i))#0)#(indexn)+1));
        i= i* xn
    )))
);
polySigGen = method()

polySigGen (List, List) := RingElement => (l, w) ->(
    k:= length w;
    x := getSymbol "t";
    R := QQ[x_1..x_k];
    S := QQ[s];
    X := apply(l, i-> sum(1..length(i)-1, j -> (i#j)_S * s^j));

    res:= product for i from 1 to k list (
        comp := X#(w#(i-1)-1);
        if(comp == 0) then 0_R else sub(diff(s,comp), {s => R_(i-1)})
        );
    
    for i from 1 to k-1 do (
        indefinite := sub(polyIntegral(res, R_(i-1)),R);
        eval0 := substitute(indefinite, {R_(i-1) => 0_QQ});
        eval1:= substitute (indefinite, {R_(i-1) => R_(i)}); --(if i<n then t_{i+1} else 1_R)
        res = eval1-eval0;
        );
    res = sub(polyIntegral(res, R_(k-1)),R);
    res = substitute(res, {R_(k-1) => 1_QQ}) - substitute(res, {R_(k-1) =>0_QQ});
    return leadCoefficient res
);

polysig = method();
polysig (List, NCRingElement) := QQ => (l, w)-> (
    linExt(i->polySigGen(l,i),w)
);

errorDepth = 2;

end
restart
load("signatures_wip.m2")

R = QQ{l_1..l_5};
f = 1/2*(l_1*l_2 - l_2*l_1);
A = {{2,0},{0,2},{-2,0},{0,-2}}
pwlsig(A, f)
polysig({{0,1},{1,0,-1}},f)

polySigGen({{1,2,3},{1,1}},{1,2})