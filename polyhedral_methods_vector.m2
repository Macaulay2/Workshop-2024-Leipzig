needsPackage "Polyhedra";

-- translate polyhedral objects by a vector
addVector = method();
addVector (PolyhedralComplex, Matrix) := (PC, v) -> (
    newPolyhedra = for P in maxPolyhedra PC list (
        indices1 = P#0;
        indices2 = P#1;
        M = (vertices PC)_indices1;
        n = numColumns(M);
        V = M + v * matrix{toList(n : 1)};
        convexHull(V, (rays PC)_indices2, linealitySpace PC)
    );
    polyhedralComplex newPolyhedra
)


addVector(Cone, Matrix) := (C, v) -> (
    R := rays C;
    L := linealitySpace C;
    convexHull(v, R, L)
    )


addVector(Fan, Matrix) := (F, v) -> (
    R := rays F;
    L := linealitySpace F;
    C := maxCones F;
    newPolyhedra = for inds in C list (
        convexHull(v, R_inds, L)
        );
    polyhedralComplex newPolyhedra
    )


addVector(Polyhedron, Matrix) := (P, v) -> (
    n = numColumns vertices P;
    V = vertices P + v * matrix{toList(n : 1)};
    convexHull(V, rays P, linealitySpace P)
    )



Matrix + PolyhedralObject := (v, PC) -> (
    addVector(PC, v)
)

PolyhedralObject + Matrix := (PC, v) -> (
    addVector(PC, v)
)



-- HERE ARE RANDOM EXAMPLES FOR THE PRESENTATION :

-- We define different types of vectors to be played with
v1 = transpose matrix {{1,0,0}};
v2 = transpose matrix {{random(ZZ), random(ZZ)}};
v3 = transpose matrix {{random(ZZ), random(ZZ)}};
v4 = transpose matrix {{random(ZZ), random(ZZ), random(ZZ)}};

-- Example 1 : vector addition of a polyhedron
P1 = convexHull matrix {{random(ZZ), random(ZZ), random(ZZ)},{random(ZZ), random(ZZ), random(ZZ)}};
print(P1 + v2);
print("");
print(P1 + v2 == P1 + v3);
print("");

-- Example 2 : vector addition of a polyhedral complex
P = polyhedralComplex crossPolytope 3;
v = transpose matrix {{1,0,0}}
print(P + v1);
print("");
P1 = convexHull matrix {{random(ZZ), random(ZZ), random(ZZ)},{random(ZZ), random(ZZ), random(ZZ)}};
P2 = convexHull matrix {{random(ZZ), random(ZZ), random(ZZ)},{random(ZZ), random(ZZ), random(ZZ)}};
P3 = convexHull matrix {{random(ZZ), random(ZZ), random(ZZ)},{random(ZZ), random(ZZ), random(ZZ)}}
P4 = convexHull matrix {{random(ZZ), random(ZZ), random(ZZ)},{random(ZZ), random(ZZ), random(ZZ)}}
PC = polyhedralComplex {P1,P2,P3,P4};
Q = PC + v2

-- Example 3 : vector addition of a cone
C1 = coneFromVData(
    transpose matrix {{1,0,0}}, -- ray in direction (1,0,0)
    transpose matrix {{0,1,0},{0,0,1}} -- linealitySpace spanned by (0,1,0), (0,0,1)
    );
print(halfspaces C1);
print("");
print(halfspaces(C1 + v1));
print("");

-- Example 4 : vector addition of a fan
F = normalFan crossPolytope 3;
print(F + v4);