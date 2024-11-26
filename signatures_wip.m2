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
pwlsig = method()
pwlsig (List, List) := QQ => (M, w)-> (
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
        pwlsig(Mrec, w_{0..i-1})*linsig(Mlast,w_{i..h-1}))
    )
);

pwlsig({{1,2},{3,4}},{1,2})


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


