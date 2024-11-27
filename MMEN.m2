loadPackage "Matroids";




MMEN=method(Options=>{Strategy=>"Last",Strategy=>"Central"});
MMEN(Matroid,List):=opts->(M,a)->(
    n:=#M.groundSet-1;
    if not (sum(a)==rank(M)-1) or not (#a==n) then (
        print("Invalid sequence");
        print(M,a);
        break;
    );
    if sum(a)==0 then return 1;
    if opts#Strategy=="Last" then (
        j:=position(a,i->(not (i==0)),Reverse=>true);
    ) else if opts#Strategy=="Central" then (
        j:=centralPosition(a,k->(not k==0));
    ); 
    b:=apply(#a,k-> if k==j then (a#k)-1 else a#k);
    FlatList:=suitableFlats(M,b);
    S:=0;
    for F in FlatList do(
        m:=min(j+1,n+1-#F)*(n+1-max(j+1,n+1-#F))/(n+1);
        M1:=M/F;
        a1:=apply(n-#F,k->b#k);
        M2:=M|F;
        a2:=apply(#F-1,k->b#(k+n+1-#F));
        factor1:=MMEN(M1,a1, Strategy=>opts#Strategy);
        factor2:=MMEN(M2,a2, Strategy=>opts#Strategy);
        S=S+m*factor1*factor2;
    );
    return S;
);


suitableFlats=method();
suitableFlats(Matroid,List):=(M,a)->(
    allFlats:=flats(M);
    n:=#M.groundSet-1;
    goodFlats:={};
    for F in allFlats do (
        f:=toList(F);
        S:=sum(a_(toList(0..n-#f-1)));  
        if #f>0 and #f<n+1 and a#(n-#f)==0 and S==rank(M)-rank(M,F)-1 then goodFlats=append(goodFlats,f);
    );
    return goodFlats;
);

centralPosition=method();
centralPosition(List,Function):= (L,f)->(
    n:=#L;
    if even(n) then (
        k:=sub(n/2,ZZ);
        for i from 0 to k-1 do(
            if f(L#(k-1-i)) then return k-1-i;
            if f(L#(k+i)) then return k+i;
        );
    ) else (
        k:=sub((n+1)/2,ZZ);
        if f(L#(k-1)) then return k-1;
        for i from 1 to k-1 do(
            if f(L#(k-1-i)) then return k-1-i;
            if f(L#(k-1+i)) then return k-1+i;
        );
    );  
);





