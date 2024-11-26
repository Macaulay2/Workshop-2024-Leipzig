restart
kk = ZZ/101
n = 3
E = kk[e_0..e_n, SkewCommutative=>true]
M = kk[x_0..x_n, SkewCommutative=>true]


expsToMon = (l,R) -> product(gens R, xi -> xi^(l#(index xi)));
contractAgainstBasisVector = (w,b) -> ( --b is the index of e_b !!!
    if w == 0 then return 0_M;
    t := apply(listForm w, (exps,coef) -> (
        if exps#b == 0 then return 0_M;
        sign := (-1)^(sum(b,i->exps#i));
        return sign * coef * expsToMon(replace(b,0,exps), M);
    ));
    return (-1)^((degree w)_0) * sum(t);
)
contractExt = (w,v) -> sum(listForm v, (exps,coef) -> coef*fold(contractAgainstBasisVector, w, positions(exps,i->i==1)))

w = random(3,M)
contractExt(w,e_1*e_3)


listOfMonomials = (i,R) -> rsort flatten entries basis(i,R);

-- a in E_(i-j) (i>j), then this is the matrix representing the map M_i -> M_j, with standard basis of M_i,M_j sorted wrt the monomial order (of M).
contractionMatrix = (i,a) -> (
    j := i - (degree a)_0;
    Bi := listOfMonomials(i,M);
    Bj := listOfMonomials(j,M);
    images := apply(Bi, w -> last coefficients(contractExt(w,a), Monomials=>Bj));
    return sub(fold(images, (C1,C2)-> C1|C2), kk);
)
v = random(1,E)
contractionMatrix(3,v)