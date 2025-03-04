---------

-- Input (i,n):
-- Implement list of length n, all entries 0 except at idx i, there entry is 1.
basisList := (i,n) -> (
    M := mutableMatrix(ZZ, 1, n); -- filled with zeros
    M_(0,i) = 1;
    (entries M)_0
);

-- Differentiate a matrix entrywise w.r.t. \partial^exps, i.e. \partial^{1,0} = \partial_x
differentiateMatrix(List, Matrix) := (exps, M) -> matrix (apply(entries M, row -> (apply(row, entry ->  diffRatFun(exps, entry)))));
-- differentiateMatrix(Number, Number, Matrix) := (i, n, M) -> matrix (apply(entries M, row -> (apply(row, entry ->  diffRatFun(basisList(i,n) , entry)))))

---------

W = makeWA(QQ[a,b,c,c', DegreeRank => 0][x,y])
I = ideal(
dx*(x*dx + c  - 1) - (x*dx + y*dy + a)*(x*dx + y*dy + b),
dy*(y*dy + c' - 1) - (x*dx + y*dy + a)*(x*dx + y*dy + b))
A = pfaffians I;
R = fractionField(W);




commutators = apply(toSequence \ subsets(numgens W // 2, 2), (i,j) -> sub(A_i * A_j - A_j * A_i, R ));
dAs = apply(toSequence \ subsets(numgens W // 2, 2), (i,j) ->  differentiateMatrix(basisList(i, numgens W // 2), sub(A_j, R)) - differentiateMatrix(basisList(j, numgens W // 2), sub(A_i, R)));

assert(commutators == dAs)  -- i.e. we need to check:      [A_i, A_j] = d_i(A_j) - d_j(A_i)  for all i,j
-- Here they are vastly different. Also: How to actually write this more cleanly?