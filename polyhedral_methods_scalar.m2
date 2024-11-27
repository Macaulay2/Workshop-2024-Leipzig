needsPackage "Polyhedra";

-- multiply polyhedral objects by a scalar
multScalar = method();
multScalar (PolyhedralComplex, QQ) := (PC, lambda) -> (
    lambda = promote(lambda, QQ);
    newPolyhedra = for P in maxPolyhedra PC list (
        indices1 = P#0;
        indices2 = P#1;
        M = (vertices PC)_indices1;
        n = numColumns(M);
        V = lambda * M;
        convexHull(V, (rays PC)_indices2, linealitySpace PC)
    );
    polyhedralComplex newPolyhedra
)


multScalar(Cone, QQ) := (C, lambda) -> (
    lambda = promote(lambda, QQ);
    R := rays C;
    if lambda == 0 then return "point"
    else if lambda > 0 then return C
    else return coneFromVData(-R)
    )


multScalar(Fan, QQ) := (F, lambda) -> (
    lambda = promote(lambda, QQ);
    if lambda == 0 then return "point"
    else if lambda > 0 then return F
    else (
        C := maxCones F;
        R = rays F;
        newCones = for cone in C list (
            coneFromVData(-R_cone) 
            );
        return fan newCones 
    );
    )


multScalar(Polyhedron, QQ) := (P, lambda) -> (
    lambda = promote(lambda, QQ);
    V = lambda * vertices P;
    convexHull(V, rays P, linealitySpace P)
    )



QQ * PolyhedralObject := (lambda, PC) -> (
    multScalar(PC, lambda)
)

PolyhedralObject * QQ := (PC, lambda) -> (
    multScalar(PC, lambda)
)



-- HERE ARE RANDOM EXAMPLES FOR THE PRESENTATION :

-- We define different types of scalars to be played with
lambda1 = promote(0, QQ);
lambda2 = promote(1, QQ);
lambda3 = promote(-1, QQ);
lambda4 = promote(2, QQ);
lambda5 = promote(-2, QQ);
lambda6 = 2/5;
lambda7 = -2/5;
lambda8 = random(QQ);
lambda9 = random(QQ);

-- Example 1 : scalar multiplication of a polyhedron
P = convexHull matrix {{random(ZZ), random(ZZ), random(ZZ)},{random(ZZ), random(ZZ), random(ZZ)}}
print(lambda8, lambda9);
print("");
print(lambda8 * P == lambda9 * P);
print("");

-- Example 2 : scalar multiplication of a polyhedral complex
PC = polyhedralComplex crossPolytope 3;
print(lambda8);
print("");
print(lambda8 * PC);
print("");
P1 = convexHull matrix {{random(ZZ), random(ZZ), random(ZZ)},{random(ZZ), random(ZZ), random(ZZ)}};
P2 = convexHull matrix {{random(ZZ), random(ZZ), random(ZZ)},{random(ZZ), random(ZZ), random(ZZ)}};
P3 = convexHull matrix {{random(ZZ), random(ZZ), random(ZZ)},{random(ZZ), random(ZZ), random(ZZ)}}
P4 = convexHull matrix {{random(ZZ), random(ZZ), random(ZZ)},{random(ZZ), random(ZZ), random(ZZ)}}
PC = polyhedralComplex {P1,P2,P3,P4};
Q = PC * lambda8;

-- Example 3 : scalar multiplication of a cone
C1 = coneFromVData(
    transpose matrix {{1,0,0}}, -- ray in direction (1,0,0)
    transpose matrix {{0,1,0},{0,0,1}} -- linealitySpace spanned by (0,1,0), (0,0,1)
    );
print(halfspaces C1);
print("");
print(halfspaces(lambda2 * C1));
print("");
print(halfspaces(lambda3 * C1));
print("");
print(halfspaces(lambda4 * C1));
print("");
print(halfspaces(lambda5 * C1));
print("");
print(halfspaces(lambda6 * C1));
print("");
print(halfspaces(lambda7 * C1));
print("");
print(lambda8, lambda9);
print("");
print(lambda8 * C1 == lambda9 * C1);
print("");

-- Example 4 : scalar multiplication of a fan
F = normalFan crossPolytope 3;
print(lambda8 * F);