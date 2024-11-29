

--Input: F a ChainComplex of free graded S-module
--Output: an element of Q(S), whose divisor measures the homology in codim 1
--        according to Cayley
determinantOfAComplex=method()
determinantOfAComplex(ChainComplex) := F -> (
    S := ring F;
    numDet := 1;
    denDet := 1;
    T := F_0;
    p := id_(T);
    if (l:=length(F))==0 then return 0_(frac R);
    for i from 1 to l do(
	S1 :=  S^(-(degrees F_i)_{0..(numrows(p)-1)});
	j := random( F_i, S1 );
	D  := p * (F.dd_i) * j;
        if( i%2 == 0 ) then(
            numDet = numDet * det(D);
        ) else (denDet = denDet * det(D)); 
        p = transpose syz transpose j;
	T = coker p;
    );
    return numDet/denDet
)


----------------------------------
----------------------------------
kk=ZZ/101
S=kk[y_0..y_14]
m=genericSkewMatrix(S,y_0,5)
F=res pfaffians(4,m)

detCompl = determinantOfAComplex(F)


----------------------------------
----------------------------------

-- generic or random n+1 x m matrix of linear forms , 
-- ideal of m minors multiplied by some variable
-- resolve the ideal
-- take the determinant of the resolution

n=3
m=2
--Mat = matrix( for i in 0..n list(for j in 0..(m-1) list( random(1,S))))
Mat = genericMatrix(S,n+1,m)

I = ideal(y_1)*minors(2,Mat)
F = res I

determinantOfAComplex(F)


