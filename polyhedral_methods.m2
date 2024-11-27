needsPackage "Polyhedra";

-- translate polyhedral objects by a vector
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


addVector(Cone, Matrix) := (C, v) -> (
    -- hint: cone is similar to a PolyhedralComplex
    -- except is does not have vertices. Cones have
    -- rays and linealitySpace:
    R := rays C;
    L := linealitySpace C;
    -- TASK --
    -- create a polyhedral complex with one
    -- polyhedron (use convexHull) that has a
    -- vertex v, rays R, and linealitySpace L
    -- test the result with addVector(C1, v1)x
    )


addVector(Fan, Matrix) := (F, v) -> (
    -- hint: fan is similar to a PolyhedralComplex
    -- Fans have rays, linealitySpace, and maxCones
    R := rays F;
    L := linealitySpace F;
    C := maxCones F;
    -- maxCones is a list of maximal cones, just like maxPolhedra, of
    -- indices of rays that form the cone
    
    -- TASK --
    -- create a polyhedral complex with one
    -- polyhedron (use convexHull) for each maximal cone
    -- (i.e., for inds in C list)
    -- with a vertex v, rays R_inds, and linealitySpace L
    -- test the result with addVector(F, v1)
    )


addVector(Polyhedron, Matrix) := (P, v) -> (
    -- hint: a polyhedron has vertices, rays, and linealitySpace
    
    -- TASK --
    -- create a polyhedral complex with one polyhedron
    -- the vertices should be translated by v

    -- TASK --
    -- test the function with addVector(P1, v')
    )



-- TASK --
-- once you have implemented the above addVector methods
-- change 'PolyhedralComplex' below to 'PolyhedralObject'
-- You should then be able to use '+' with Polyhedron, Cone, Fan,
-- and PolyhedralComplex objects. Test it with the examples below.
Matrix + PolyhedralComplex := (v, PC) -> (
    addVector(PC, v)
)

PolyhedralComplex + Matrix := (PC, v) -> (
    addVector(PC, v)
)



-- examples:
P = polyhedralComplex crossPolytope 3;
v = transpose matrix {{1,0,0}}
Q = P+v

P1 = convexHull matrix {{2,2,0},{1,-1,0}};
P2 = convexHull matrix {{2,-2,0},{1,1,0}};
P3 = convexHull matrix {{-2,-2,0},{1,-1,0}};
P4 = convexHull matrix {{-2,2,0},{-1,-1,0}};

F = polyhedralComplex {P1,P2,P3,P4};

v' = transpose matrix{{1,2}};
Q' = F+v'

C1 = coneFromVData(
    transpose matrix {{1,0,0}}, -- ray in direction (1,0,0)
    transpose matrix {{0,1,0},{0,0,1}} -- linealitySpace spanned by (0,1,0), (0,0,1)
    )
-- C1 is a halfspace {x : x_1 >= 0}
-- to see this, use halfspaces C1

v1 = transpose matrix {{1,0,0}}
-- TASK --
-- show that C1+v1 is the affine half-space {x : x_1 >= 1}

F = normalFan crossPolytope 3
-- TASK --
-- understand what this looks like

-- TASK --
-- check that F+v1 is what you expect 




end --

-- testing
load "polyhedral_methods.m2"
