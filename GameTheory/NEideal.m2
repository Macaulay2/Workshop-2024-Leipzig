-- optimized NEpolynomials
needsPackage "GameTheory"

--mixedProbabilityRing; 
mixedProbabilityRing = method()
mixedProbabilityRing List := L ->(
    p := getSymbol "p";
    probabilityRing := QQ[flatten apply(#L, i -> apply(L#i, j->p_{i,j}))];
    probabilityRing
)
mixedProbabilityRing Tensor := T ->(
    indexSet := format T;
    mixedProbabilityRing indexSet
)

differencesFromFirst = L -> (apply(toList(1..#L-1), i->L#i-L#0))

monomialFromIndex = method()
monomialFromIndex (List, ZZ, Ring):= (L, i, R) ->(
    p := getSymbol "p";
    monomial := product toList apply(pairs L, (j,r)->(s := if j >= i then j + 1 else j; p_{s,r}_R));
    monomial
)

equilibriumPolynomials = method()
equilibriumPolynomials (Tensor, ZZ, Ring) := (T, u, R)->(
    indexSet := format T;
    tensorIndices := T#"indexes";
    nStrategies := indexSet#u;
    accumulatedHash := new MutableHashTable;
    for tensorIndex in tensorIndices do (
        newCoefficient := T#tensorIndex;
        thisStrategy := tensorIndex#u;
        monomialIndex := drop(tensorIndex,{u,u});
        if not (accumulatedHash #? monomialIndex) then accumulatedHash#monomialIndex = new MutableList from nStrategies: 0;
        accumulatedHash#monomialIndex#thisStrategy = newCoefficient;
    );
    polynomials := apply(pairs accumulatedHash, (k,v)->(
        monomial := monomialFromIndex(k, u, R);
        apply(differencesFromFirst v, i-> i_R * monomial)
    ));
    sum polynomials
)

nashEquilibriumRing = method()
nashEquilibriumRing List := L -> (
    -- L is a list consisting of n- tensors; requires them to be of the same dimension/shape
    indexSet := format first L;
    polyRing := mixedProbabilityRing indexSet;
    polyRing
)
nashEquilibriumIdeal = method()
nashEquilibriumIdeal (Ring, List) := (R, L) -> (
    indexSet := format first L;
    probabilityRing := R;
    completeGeneratingSet := flatten(apply(pairs L, (i,T) -> equilibriumPolynomials(T,i,probabilityRing)));
    p := getSymbol "p";
    linearRelations := apply(pairs indexSet, (i,j)-> sum(j, k->p_{i,k}_probabilityRing) - 1);
    fullGeneratingSet := join(completeGeneratingSet, linearRelations);
    ideal fullGeneratingSet
)

needsPackage "Polyhedra"

directProductList = method()
directProductList List := L -> (
    if #L == 0 then error "Empty list of polytopes";
    P := L#0;
    for i from 1 to (#L - 1) do (
        P = directProduct(P, L#i);
    );
    P
)

deltaList = method()
deltaList List := d -> (
    n := #d;
    result := {};
    for i from 0 to (n - 1) do (
        polyFactors := for j from 0 to (n - 1) list (
            if j == i then (
                convexHull(matrix(apply(d#i - 1, k -> {0})))
            ) else (
                simplex(d#j - 1)
            )
        );
        P := directProductList(polyFactors);
        for rep from 1 to (d#i - 1) do (
            result = append(result, P)
        );
    );
    result
)

maxNumberEquilibria = method()
maxNumberEquilibria List := d -> (
    myTuple := deltaList d;
    mv := mixedVolume(myTuple);
    print("The maximum number of totally mixed Nash equilibria for a " | toString(d) |
          " game is " | toString(mv));
    mv
)


