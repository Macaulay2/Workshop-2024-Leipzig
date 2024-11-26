n=10;
R = QQ[x_1..x_n];
p = x_1*x_2^3;


-----------------------------------------------------------------------
--Computes the indefinite integral of f with respect to the varaible xn
-----------------------------------------------------------------------
partialPolyIntegral = method()
polyIntegral (RingElement, RingElement) := RingElement => (f, xn) ->(
    R := ring f;
    indexn := index xn;
    termsf := terms f;
    return sum(apply(termsf, i->(
        i = i/((((exponents(i))#0)#(indexn)+1));
        i= i* xn
    )))
);
polySigGen = method()

polySigGen (List, List) := RingElement => (X, w) ->(
    k:= length w;
    R:= (baseRing ring X#0)[t_1..t_k];
    res:= product(for i from 1 to k list sub(diff((generators (ring X#(w#(i-1)-1)))#0,X#(w#(i-1)-1)), {(generators (ring X#(w#(i-1)-1)))#0 => t_(i)}));
    for i from 1 to k-1 do (
        indefinite := polyIntegral(res, t_i);
        print(indefinite);
        eval0 := substitute(indefinite, {t_i =>0});
        print(eval0);
        eval1:= substitute (indefinite, {t_i=> t_(i+1)}); --(if i<n then t_{i+1} else 1_R)
        print(eval1);
        res = eval1-eval0;
        );
    
    return res
); 


TEST ///

R= QQ[x,y,z];
p=x^2*y+z^2*x;
intx = x^3*y/3 + z^2*x^2/2;
assert(intx === polyIntegral(p, x)); 
///

