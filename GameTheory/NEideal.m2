-- optimized NEpolynomials
needsPackage "GameTheory"

--mixedProbabilityRing; 
mixedProbabilityRing = method()
mixedProbabilityRing List := L ->(
    probabilityRing := QQ[flatten apply(#L, i -> apply(L#i, j->p_{i,j}))];
    probabilityRing
)
mixedProbabilityRing Tensor := T ->(
    indexSet := format T;
    mixedProbabilityRing indexSet
)

mixedProbabilityRing2 = method()
mixedProbabilityRing2 List := L ->(
    probabilityRing := CC[flatten apply(#L, i -> apply(L#i, j->p_{i,j}))];
    probabilityRing
)
mixedProbabilityRing2 Tensor := T ->(
    indexSet := format T;
    mixedProbabilityRing2 indexSet
)

differencesFromFirst = L -> (apply(toList(1..#L-1), i->L#i-L#0))

monomialfromIndex = method()
monomialfromIndex (List, ZZ, Ring):= (L, i, R) ->(
    monomial := product toList apply(pairs L, (j,r)->(s = if j >= i then j + 1 else j; p_{s,r}_R));
    monomial
)

NEpolynomials = method()
NEpolynomials (Tensor, ZZ, Ring) := (T, u, R)->(
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
        monomial := monomialfromIndex(k, u, R);
        apply(differencesFromFirst v, i-> i_R * monomial)
    ));
    sum polynomials
)

NERing = method()
NERing List := L -> (
    -- L is a list consisting of n- tensors; requires them to be of the same dimension/shape
    indexSet := format first L;
    polyring := mixedProbabilityRing indexSet;
    polyring
)
NEideal = method()
NEideal (Ring, List) := (R, L) -> (
    indexSet := format first L;
    probabilityRing := R;
    completeGeneratingSet := flatten(apply(pairs L, (i,T) -> NEpolynomials(T,i,probabilityRing)));
    linearRelations := apply(pairs indexSet, (i,j)-> sum(j, k->p_{i,k}_probabilityRing) - 1);
    fullGeneratingSet := join(completeGeneratingSet, linearRelations);
    neIdeal := ideal fullGeneratingSet;
    neIdeal
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

DeltaList = method()
DeltaList List := d -> (
    n := #d;
    result := {};
    for i from 0 to (n - 1) do (
        polyFactors = for j from 0 to (n - 1) list (
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

--Input the list of the dimension of the game, returning the mixed volume.
MaxNumberEquilibria = method()
MaxNumberEquilibria List := d -> (
    myTuple = DeltaList d;
    mv = mixedVolume(myTuple);
    print("The maximum number of totally mixed Nash equilibria for a " | toString(d) |
          " game is " | toString(mv));
    mv
)

-- Example usage:
d = {2,2,2}
MaxNumberEquilibria d
