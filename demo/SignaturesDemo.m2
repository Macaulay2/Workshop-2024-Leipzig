-----------------------------------------------------------------------------------------------------------
-- Authors: Felix Lotter, Oriol Reig, Angelo El Saliby, Carlos Amendola
-----------------------------------------------------------------------------------------------------------

load("../PathSignatures.m2")

///
The k-th level signature of a path $X:[0,1]\rightarrow \RR^d$  is a k-tensor whose coordinates are iterated 
integrals of some of the derivatives of X over a k-dimensional simplex.

First of all, we solve the easy problem of computing the signatures of piece-wise linear and polynomial paths
///
d=5
X= id_(ZZ^d)
A = QQ{l_1..l_d}  --We encoded tensors through non commutative polynomials
pwlsig(X, l_1)
CAxisMatrix =matrix table(d,d,(i,j) -> pwlsig(X, l_(i+1)*l_(j+1))) --Piecewise linear 2nd level signature tensor

--Here, a polynomial \sum a_i x^i is represented by {a_0,a_1,...}
--We compute this for X(t)= (t, t^2, ..., t^d)
Y=apply(entries X, i-> prepend(0, i)); 
matrix table(d,d,(i,j) -> polysig(Y, l_(i+1)*l_(j+1)))

-- The two specific paths we just described turn out to generate interesting classes of paths through
-- equivariance (i.e. the natural action of a matrix on the tensors), namely the classes of piecewise 
-- linear paths with m segments and polynomial paths of degree at most m, in \RR^d.

-- There are closed formulas for the corresponding core tensors. They can be obtained in the following way:

CAxisTensor(2, A);
CMonTensor(2,A);  


-- Now we try to study the closure of the image of the 
