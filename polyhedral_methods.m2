needsPackage "Polyhedra";

P = polyhedralComplex crossPolytope 3;

P1 = convexHull matrix {{2,2,0},{1,-1,0}};
P2 = convexHull matrix {{2,-2,0},{1,1,0}};
P3 = convexHull matrix {{-2,-2,0},{1,-1,0}};
P4 = convexHull matrix {{-2,2,0},{-1,-1,0}};

F = polyhedralComplex {P1,P2,P3,P4};

addVector = method();
addVector (PolyhedralComplex, Matrix) := (PC, v) -> (
    newPolyhedra = for P in maxPolyhedra PC list (
        indices1 = P#0;
        indices2 = P#1;
        M = (vertices PC)_indices1;
        n = numColumns(M);
        V = M + v * matrix{toList(n:1)};
        convexHull(V, (rays PC)_indices2, linealitySpace PC)
    );
    polyhedralComplex newPolyhedra
)

v = transpose matrix{{1,2}};
addVector(F, v);

Matrix + PolyhedralComplex := (v, PC) -> (
    addVector(PC, v)
)

PolyhedralComplex + Matrix := (PC, v) -> (
    addVector(PC, v)
)