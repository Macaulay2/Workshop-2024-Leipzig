newPackage("PathSignatures",
         Version => "1.0",
         Authors => {{Name => "Felix Lotter", HomePage => "https://felixlotter.gitlab.io"}, {Name => "Oriol Reig"}, {Name => "Angelo El Saliby"}, {Name => "Carlos Amendola"}},
         Headline => "A package for working with signatures of algebraic paths",
         AuxiliaryFiles => true,
         PackageExports => {"NCAlgebra", "Permutations"}
);
export {
    --types
    "Path",
    --methods
    "sig",
    "polyPath",
    "linPath",
    "pwLinPath",
    "concatPath",
    "matrixAction",
    "CAxisTensor",
    "CMonTensor",
    "tensorParametrization",
    "wordAlgebra",
    "signedVolume",
    "shuffle",
    "halfshuffle",
    "wordFormat",
    "wordString",
    "getDimension",
    "getPieces",
    "getCoefficientRing",
    "getNumberOfPieces",
    -- symbols
    "adjointWord",
    "tensorArray",
    "inner",
    "lyndonWords",
    "lie",
    "lieBasis",
    "tensorExp",
    "toLyndonShuffle"
    -- "type",
    -- "pieces",
    -- "dimension",
    -- "numberOfPieces",
    -- "bR"
};

exportFrom("NCAlgebra",{"NCRingElement", "NCPolynomialRing"})





TEST ///
R = QQ{symbol s_1..symbol s_5};
f = 1/2*(s_1*s_2 - s_2*s_1);
A = QQ[symbol x_1..symbol x_3]

pR = A[t];
X = polyPath({0,x_2*t^2}) ** polyPath({x_3*t^3 + 3*t, t^2 - 1})
<<<<<<< HEAD
r = sig(X,f)
///



TEST ///
R= QQ[t];

X = polyPath({t, t^2});
assert(getNumberOfPieces X === 1);
assert(dim p === 2);
Y = linPath({1,2});

XY = X**Y;
assert(getNumberOfPieces XY === 2);
assert(dim XY === 2);
///



--------------------------------------------
--Include interface for NCAlgebra
load "./PathSignatures/interfaceNCAlgebra.m2"

--Include tensor algebra
load "./PathSignatures/algebra.m2"

--Include types
load "./PathSignatures/types.m2"

--Include signatures
load "./PathSignatures/signatures.m2"

--Include documentation
load "./PathSignatures/documentation.m2"
--------------------------------------------


endPackage;












