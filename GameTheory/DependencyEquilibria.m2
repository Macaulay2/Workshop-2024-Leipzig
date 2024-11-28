needsPackage "GameTheory"

-- ProbabilityRing = new Type of Ring

probabilityRing = method(Options => { CoefficientRing => QQ, ProbabilityVariableName => "p" })
probabilityRing List := Ring => opts -> Di -> (
    J := enumerateTensorIndices Di;
    p := getSymbol opts.ProbabilityVariableName;
    K := opts.CoefficientRing;
    -- R := new ProbabilityRing;
    R := K[apply(J, j -> p_j)];

    P := zeroTensor(R, Di);
    for j in J do P#j = (p_j)_R;
    R#"probabilityVariable" = P;

    R#"gameFormat" = Di;
    R)

-- PayoffProbabilityRing = new Type of ProbabilityRing

payoffProbabilityRing = method(Options => { CoefficientRing => QQ, ProbabilityVariableName => "p", PayoffVariableName => "x" })
payoffProbabilityRing List := Ring => opts -> Di -> (
    J := enumerateTensorIndices Di;
    p := getSymbol opts.ProbabilityVariableName;
    x := getSymbol opts.PayoffVariableName;
    K := opts.CoefficientRing;

    L := toList(0 .. (#Di - 1));
    E := L ** J;
    R := K[apply(E, e -> x_e), apply(J, j -> p_j)];

    P := zeroTensor(R, Di);
    for j in J do P#j = (p_j)_R;
    R#"probabilityVariable" = P;

    X := apply(#Di, i -> zeroTensor(R, Di));
    for i to #Di-1 do
        for j in J do X_i#j = x_(i, j)_R;
    R#"payoffVariable" = X;

    R#"gameFormat" = Di;
    R)

randomGame = method(Options => {CoefficientRing => QQ})
randomGame List := List => opts -> Di -> (
    K := opts.CoefficientRing;
    apply(length Di, i -> randomTensor(K, Di)))

genericGame = method()
genericGame Ring := List => PPR -> (
    Di := PPR#"gameFormat";
    x := PPR#"payoffVariable";
    apply(#Di, i -> (result := new Tensor;
                     J := enumerateTensorIndices Di;
                     apply(J, j -> result#j = x_i#j);
                     result#"format" = Di;
                     result#"coefficients" = PPR;
                     result#"indexes" = J;
                     result)))

spohnMatrices = method()
spohnMatrices (Ring, List) := List => (PR, X) -> (
    p := PR#"probabilityVariable";
    n := length X;
    d := format X_0;
    J := indexset X_0;
    apply(n, i -> matrix apply(d_i, k -> {sum(select(J, j -> j_i==k), j -> p#j),
                                          sum(select(J, j -> j_i==k), j -> (X_i)#j * p#j) })))

spohnIdeal = method()
spohnIdeal (Ring, List) := List => (PR, X) -> (
    M := spohnMatrices(PR, X);
    sum(M, m -> minors(2, m)))

konstanzMatrix = method(Options=>{ KonstanzVariableName => "k" })
konstanzMatrix (Ring, List) := Matrix => opts -> (PR, X) -> (
    k := getSymbol opts.KonstanzVariableName;
    Di := PR#"gameFormat";
    p := PR#"probabilityVariable";
    n := #Di;
    J := enumerateTensorIndices Di;
    konstanzRing := PR[apply(n, i -> k_i)];
    M := spohnMatrices(PR, X);
    LinearForms := apply(n, i -> (M_i * matrix{{(k_i)_konstanzRing}, {-1}} ));
    P := vector(apply(J, j -> p#j));
    fold((M0, M1) -> M0 || M1, 
         apply(n, i -> transpose matrix apply(Di_i,
                                              j -> diff(P, (LinearForms_i)_(j, 0)))))
)

-- end
-- restart
-- needs "DependencyEquilibria.m2"

-- Di = {2,3,2}

-- PPR = payoffProbabilityRing Di
-- G = genericGame PPR

-- PR = probabilityRing Di
-- G = randomGame Di
-- M = konstanzMatrix(PR, G, KonstanzVariableName=>"L")