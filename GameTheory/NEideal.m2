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
    linearRelations := apply(pairs indexSet, (i,j)-> sum(j, k->p_{i,k}) - 1);
    fullGeneratingSet := join(completeGeneratingSet, linearRelations);
    neIdeal := ideal fullGeneratingSet;
    neIdeal
)
