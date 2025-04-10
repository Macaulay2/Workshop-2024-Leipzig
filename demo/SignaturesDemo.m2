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

wordFormat f -- write the polynomial in word notation

-- words can be shuffled and half-shuffled

f = ([1,2]_R ** [1,2]_R) -- shuffle product
f // letterFormat

-- Finally, to compute the signature of a path, use sig.

sig(Z**Z,[1,2]_R**[1,2]_R) == (sig(Z**Z,[1,2]_R))^2

-- The base ring does not need to be QQ

S = QQ[a_1..a_4]
A = genericMatrix(S,2,2)
X = pwLinPath(A) -- creates a piecewise linear path from a matrix with increments given by columns
Lev2 = matrix (sig(X, 2)@2) -- 2nd level signature tensor
sig(X, signedVolume(R)) -- the signed volume of X

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


--Demo for Oriols code

needsPackage "PathSignatures";
S=QQ[x,y];
T=QQ{l_1,l_2,l_3}

L={x^2,y^3,x-y};
d=2

R = QQ[t];
X = polyPath({t,t})
Y = polyPath({t^2,t^3,0_R})
w = l_1*l_2
adw = adjointWord(w,T,L)
sig(Y, w)
sig(X, adw)



adjointWord(l_2, T,L)

adjointWord(l_3, T,L)

adjointWord(l_3^2, T,L)


R = QQ{symbol s_1..symbol s_5};
f = 1/2*(s_1*s_2 - s_2*s_1);
A = QQ[symbol x_1..symbol x_3]

pR = A[t];
X = polyPath({t,x_2*t^2})
r = sig(X,2)


S=QQ[x,y];
T=QQ{l_1,l_2,l_3}

L={x^2-y,y^3+x,x-y};

R = QQ[t];
P={t,t^2+3*t^5}
X = polyPath(P)
PP=apply(L, q-> sub(q, {x=>P_0, y=>P_1}))
Y = polyPath(PP)
w = l_1*l_2
adw = adjointWord(w, T,L)
sig(Y, w)
sig(X, adw)


-- another demo

-- define a transformation of affine spaces:
S=QQ[x,y]; 
p = {x^2,x*y,y^2} -- the degree 2 Veronese R^2 -> R^3

-- create word algebras
wA2 = wordAlgebra(2); -- functions on R^2 path space
wA3 = wordAlgebra(3); -- functions on R^3 path space

-- create a path in 2 dimensional space
R = QQ[t]
X = polyPath({t,t^2})
-- create the transformed path in 3 dimensional space
PP= apply(p, q -> sub(q, {x=>t, y=>t^2}))
Y = polyPath(PP)

-- consider the signed volume in R^3
vol = signedVolume(wA3); vol // wordFormat
-- it transforms to a word in 2 letters
adw = adjointWord(vol, wA2, p); adw // wordFormat
sig(Y, w) -- the signed volume of the transformed path...
sig(X, adw) -- is given by evaluating at adw for the original path.

-- Tensor components

R = QQ[t]
X = polyPath({t,t^2})
sig(X,2)@2 -- get signature matrix
sig(X,3)@3 -- get third level signature as multi-dimensional array