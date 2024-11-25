linsig = method()

linsig (List, List) := QQ => (u, w)-> (
    h := length (w);
    if h==0 then (return(1));
    product(h, i-> u#(w#i-1))/(h!)
)


pwlsig = method()

pwlsig (List, List) := QQ => (M, w)-> (
    h := length (w);
    m := length(M);
    if(m==1) then return linsig(M#0,w);
    Mrec := M_{0..m-2};
    print(Mrec);
    Mlast := M#(m-1);

    sum(h+1, i -> (
        pwlsig(Mrec, w_{0..i-1})*linsig(Mlast,w_{i..h-1})
        
        ))
);

pwlsig({{1,2},{3,4}},{1,2})

