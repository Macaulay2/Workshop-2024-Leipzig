-----------------------------------------------------------------------------------------------------------
-- Authors: Felix Lotter, Oriol Reig, Angelo El Saliby, Carlos Amendola
-----------------------------------------------------------------------------------------------------------

--installPackage("PathSignatures",FileName => "../PathSignatures.m2")
needsPackage "PathSignatures";
///
The k-th level signature of a path $X:[0,1]\rightarrow \RR^d$  is a k-tensor whose coordinates are iterated 
integrals of some of the derivatives of X over a k-dimensional simplex.
///

-- A path can be constructed in different ways

X = linPath({2,3}) -- a linear path with increment {2,3}
Y = polyPath({{({1},1)},{({2},2)}}) -- polynomials can be given in list form...
R = QQ[t]
Y = polyPath({t,2*t^2}) --or as actual polynomials
Z = X**Y -- concatenate paths using **

-- The signature of a path is evaluated at non-commutative polynomials in the coordinates

R = wordAlgebra(2) -- create a free associative algebra over two letters Lt_1, Lt_2

f= [1,2]_R -- [i_1,...,i_k]_R defines a word.

letterFormat f -- write the polynomial in word notation

-- words can be shuffled and half-shuffled

f = ([1,2]_R ** [1,2]_R) -- shuffle product
f // letterFormat

-- Finally, to compute the signature of a path, use sig.

sig(Z**Z,[1,2]_R**[1,2]_R) == (sig(Z**Z,[1,2]_R))^2

-- The base ring does not need to be QQ

S = QQ[a_1..a_4]
A = genericMatrix(S,2,2)
X = pwlinPath(A) -- creates a piecewise linear path from a matrix with increments given by columns
Lev2 = matrix table(2,2,(i,j) -> sig(X, [i+1,j+1]_R, BaseRing => S)) -- 2nd level signature tensor
sig(X, signedVolume(R), BaseRing => S) -- the signed volume of X

-- Polynomial and piecewise linear paths turn out to generate interesting classes of paths through
-- equivariance (i.e. the natural action of a matrix on the tensors), namely the classes of piecewise 
-- linear paths with m segments and polynomial paths of degree at most m, in \RR^d.

-- There are closed formulas for the corresponding core tensors. They can be obtained in the following way:

R = wordAlgebra(2, BaseRing => S)
CAxisTensor(2, R) -- core tensor in degree 2
CMonTensor(2,R) -- core tensor in degree 2

-- The action of a matrix A on a tensor T can be computed as A*T

Lev2
(A * CAxisTensor(2,R)) // letterFormat


-- Sending a matrix to the tensor obtained by acting on the level k core tensor with that matrix yields a homogeneous map of affine varieties. This map can be constructed in the following way:

coreTensor = CAxisTensor(3, R); coreTensor // letterFormat -- core tensor in degree 3
ourmap = createMapFromCoreTensor(coreTensor,2,GroundField=>QQ); -- paths in R^2 with 3 segments

-- Then we can use inbuilt functions and packages to study its kernel. In other words, we can study the Zariski closure of the image of the map above.

I = kernel ourmap
dim I

needsPackage "MultigradedImplicitization"


flatten values componentsOfKernel(3,ourmap)


needsPackage "PathSignatures";
S=QQ[x,y];
T=QQ{l_1,l_2,l_3}

--Polynmials defining the function:
L={x^2,y^3,x-y};
d=2

functionMp(l_1, T,d,L)


functionMp(l_2, T,d,L)

functionMp(l_3, T,d,L)

functionMp(l_3^2, T,d,L)