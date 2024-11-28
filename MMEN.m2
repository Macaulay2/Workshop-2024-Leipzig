loadPackage "Matroids";

--Preliminary functions

--Finds what are the flats that satisfy the mixed matroid eulerian conditions w.r.t. a
suitableFlats=method();
suitableFlats(Matroid,List):=(M,a)->(
    allFlats:=flats(M);
    n:=#M.groundSet-1;
    goodFlats:=new MutableList;
    for F in allFlats do (
        f:=toList(F);
        S:=sum(a_(toList(0..n-#f-1)));  
        if #f>0 and #f<n+1 and a#(n-#f)==0 and S==rank(M)-rank(M,F)-1 then goodFlats##goodFlats=f;
    );
    return toList(goodFlats);
);

--Finds the more central element on a list for which f(i) == true
centralPosition=method();
centralPosition(List,Function):= (L,f)->(
    n:=#L;
    k:=0;
    if even(n) then (
        k=sub(n/2,ZZ);
        for i from 0 to k-1 do(
            if f(L#(k-1-i)) then return k-1-i;
            if f(L#(k+i)) then return k+i;
        );
    ) else (
        k=sub((n+1)/2,ZZ);
        if f(L#(k-1)) then return k-1;
        for i from 1 to k-1 do(
            if f(L#(k-1-i)) then return k-1-i;
            if f(L#(k-1+i)) then return k-1+i;
        );
    );  
);



--Main method to compute Eulerian numbers given a matroid M and a sequence a
--Strategy "Last" picks the last non-zero entry of a as a reference
--Strategy "Central" picks the most central non-zero entry of a as a reference
--If no Strategy is provided, then "Central" will be used
MMEN=method(Options=>{Strategy=>"Central"});
MMEN(Matroid,List):=opts->(M,a)->(
    n:=#M.groundSet-1;

    --Checks if a is compatible with M
    if not (sum(a)==rank(M)-1) or not (#a==n) then (
        print("Length or sum of a don't math the matroid M");
	return 0;
    );
    if #loops(M) > 0 then (
        return 0;
    );

    --Base case for recursion computation
    if sum(a)==0 then return 1;

    --Choice of j according to the strategy
    j:=0;
    if opts#Strategy=="Last" then (
        j=position(a,i->(not (i==0)),Reverse=>true);
    ) else if opts#Strategy=="Central" then (
        j=centralPosition(a,k->(not k==0));
    ) else if opts#Strategy=="Maximum" then (
        j=maxPosition(a);
    ) else if opts#Strategy=="Minimum" then (
        j=minPosition(apply(a,j-> if j==0 then n else j));
    ); 

    --Finds suitable flats of M
    b:=apply(#a,k-> if k==j then (a#k)-1 else a#k);
    FlatList:=suitableFlats(M,b);

    --Recursion
    S:=0;
    for F in FlatList do(
        m:=min(j+1,n+1-#F)*(n+1-max(j+1,n+1-#F))/(n+1);
        M1:=M/set(F);
        a1:=apply(n-#F,k->b#k);
        M2:=M|set(F);
        a2:=apply(#F-1,k->b#(k+n+1-#F));
        factor1:=MMEN(M1,a1, Strategy=>opts#Strategy);
        factor2:=MMEN(M2,a2, Strategy=>opts#Strategy);
        S=S+m*factor1*factor2;
    );


    return S;
);





doc ///
    Key
    	matroidalMixedEulerianNumbers
    Headline
    	Compute the matroidal mixed Eulerian number associated to a matroid and a sequence of numbers
    Inputs
    	M:Matroid
	    a matroid of some rank r on a groundset of some size n+1.
        a:List
        a list of nonnegative integers of length n such that the sum of its entries is r-1.
        Strategy => String
        a strategy that should be used to de the recursion. Default value is "Central", possible options are "Last","Central","Minimum" and "Maximum".
    Outputs
        A_M(a):ZZ
	    the matroidal mixed Eulerian number associated to the matroid M and the sequence a
    Description 
    	Text
        Associated to a matroid $M$ one associates a class $[X_M]$ in the Chow ring of the permutohedral variety $\Pi_n$. Similarly for $i=1,\cdots,n$, the $i$-th hypersimplex conv$(sum_{k\in S}e_k| S\subseteq \{0,\ldots,n\}, |S|=i) gives a Divisor L_i in the permutohedral Chow ring. The matroidal mixed Eulerian number associated to M and a computes the intersection product $\int_{\Pi_n}[X_M]L_1^{a_1}\cdots L_n^{a_n}$. If $M$ has a loop this product is always zero, the same holds if the sequence $a$ does not sum to rank($M$)-1. The computation is based on a recursive algorithm by G. Liu, M. Micha\lek, J. Weigert. First an index $j$ is picked such that $a_j>0$ and the entry $a_j$ is reduced by one. Then summing over suitable flats $F$ of $M$ the intersection number is computed from intersection numbers of $M/F$ and $M|F$ corresponding to sequences obtained by splitting $a$ in half. The strategy option allows the user to influence the way the algorithm picks the index $j$.
	    Example
        M=specificMatroid("R10");
        a={0, 0, 2, 0, 1, 0, 0, 1, 0};
        time MMEN(M,a,Strategy=>"Central");
        time MMEN(M,a,Strategy=>"Last");
        time MMEN(M,a,Strategy=>"Minimum");
        time MMEN(M,a,Strategy=>"Maximum");

///


