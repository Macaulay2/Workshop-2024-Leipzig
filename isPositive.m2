interiorVector Cone := C -> (
            if numColumns rays C == 0 then map(ZZ^(ambDim C),ZZ^1,0)
            else (
                 Rm := rays C;
                 ones := matrix toList(numColumns Rm:{1});
                 -- Take the sum of the rays
                 iv := Rm * ones;
                 transpose matrix apply(entries transpose iv, w -> (g := abs gcd w; apply(w, e -> e//g)))));

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

positiveBergmanFan = method(Options=>{MaxConesOnly=>false});
positiveBergmanFan Matrix := Opts-> (N) ->(
    C := signedCircuits(N);
    K := transpose gens ker N;
    M := matroid K;
    T := BergmanFan M;
    d := dim T;
    Rays := rays T;
    S := maxCones T;
    if not Opts#MaxConesOnly then (
        for k in 1..d-1 do (
        S = S | cones(d-k,T);
        );
    );
    L := {};
    Sigma := coneFromVData (linealitySpace T);
    for s in S do (
        if s != {} then (
            Sigma = coneFromVData(Rays_s,linealitySpace T);
        )
        else (
            Sigma = coneFromVData(map(ZZ^(ambDim T),ZZ^0,0),linealitySpace T);
        );
        print s;
        if isPositive(Sigma,C) then (
            L=append(L,Sigma); 
        );
    );
    return fan L;
)