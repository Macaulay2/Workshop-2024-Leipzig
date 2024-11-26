newPackage(
   "GameTheory",
   Version => "0.1",
   Date => "November, 2024",
   Authors => {
      {Name => "Irem Portakal",
         Email => "mail@irem-portakal.de",
         HomePage => "https://www.irem-portakal.de"},
      {Name => "Lars Kastner",
         Email => "kastner@math.tu-berlin.de",
         HomePage => "https://lkastner.github.io"}
   },
   Headline => "This is the only package you will ever need.",
   Keywords => {"Game Theory"},
   PackageExports => {"Polyhedra","GraphicalModels"},
   PackageImports => {"Polyhedra"}
   )

export {
   "zeroTensor",
   "Tensor",
   "randomTensor",
   "indexset",
   "correlatedEquilibria",
   "enumerateTensorIndices",
   "intersectCImodel"
}



enumerateTensorIndices = method()
enumerateTensorIndices ZZ := z -> apply(toList (0..z-1), e->{e})
enumerateTensorIndices List := s -> (
   if length s == 1 then 
      return enumerateTensorIndices s#0
   else
      start := enumerateTensorIndices s#0;
      ri := toList (1..(length(s)-1));
      rest := enumerateTensorIndices s_ri;
      result := {};
      for s in start do
         for r in rest do
            result = append(result, join(s,r));
      result
)

Tensor = new Type of MutableHashTable

zeroTensor = method()
zeroTensor List := dims -> zeroTensor(QQ,dims)
zeroTensor(Ring,List) := (R,dims) -> (
   result := new Tensor;
   indexset := enumerateTensorIndices dims;
   for i in indexset do
      result#i = 0_R;
   result#"format" = dims;
   result#"coefficients" = R;
   result#"indexes" = indexset;
   result
)

randomTensor = method()
randomTensor List := dims -> randomTensor(QQ,dims)
randomTensor(Ring,List) := (R,dims) -> (
   result := new Tensor;
   indexset := enumerateTensorIndices dims;
   for i in indexset do
      result#i = random R;
   result#"format" = dims;
   result#"coefficients" = R;
   result#"indexes" = indexset;
   result
)

format Tensor := T -> T#"format"
coefficientRing Tensor := T -> T#"coefficients"
indexset = method()
indexset Tensor := T -> T#"indexes"

slice = method()
slice (Tensor, List, List) := (T, Lstart, Lend) -> (
   dims := format T;
   iteratingPosition := length Lstart;
   result := {};
   for i from 0 to dims#iteratingPosition -1 do (
      mindex := join(Lstart, {i}, Lend);
      result = append(result, T#mindex);
   );
   result
)

getVariableToIndexset = method()
getVariableToIndexset(Ring, List) := (R, ki) -> (
   p := position(apply(gens R, i -> last baseName i), i -> i == ki);
   R_p
)

assemblePolynomial = method()
assemblePolynomial(Ring, Tensor, List) := (PR, Xi, ikl) -> (
   FBi := indexset Xi;
   reverseVarMap := new MutableHashTable;
   for k in FBi do (
      reverseVarMap#k = getVariableToIndexset(PR, k);
   );
   i := ikl#0;
   k := ikl#1;
   l := ikl#2;
   use PR;
   kindices := select(FBi, e->e#i==k);
   lindices := select(FBi, e->e#i==l);
   kterm := sum apply(kindices, ki -> Xi#ki*reverseVarMap#ki);
   lterm := sum apply(lindices , li->(tmp := new MutableList from li; tmp#i=k; a := toList tmp; Xi#li*reverseVarMap#a));
   ineq := kterm-lterm;
   ineq
)

assemblePlayeriPolynomials = method()
assemblePlayeriPolynomials(Ring, Tensor, ZZ) := (PR, Xi, i) -> (
   result := {};
   di := (format Xi)#i;
   for k from 0 to di-1 do (
      for l from 0 to di-1 do (
         poly := assemblePolynomial(PR, Xi, {i,k,l});
         result = append(result, poly);
      );
   );
   result
)

correlatedEquilibria = method()
correlatedEquilibria List := X -> (
   F := coefficientRing (X#0);
   FBi := indexset (X#0);
   p := getSymbol "p";
   PR := F[apply(FBi, fb->p_fb)];
   nplayers := length format X#0;
   L := flatten for i from 0 to nplayers-1 list assemblePlayeriPolynomials(PR, X#i, i);
   polyDim := length FBi;
   vectors := {};
   ineqs := for p in L list apply(generators PR, g -> coefficient(g, p));
   ineqs = (matrix ineqs) || (map identity (F^(#FBi)));
   ineqsrhs := transpose matrix {toList ((numRows ineqs):0_F)};
   eq := matrix {toList ((numColumns ineqs):1_F)};
   eqrhs := matrix {{1_F}};
   polyhedronFromHData(-ineqs, ineqsrhs,eq,eqrhs)
)

intersectCImodel = method()
intersectCImodel (Graph,Ideal,List) := (G,V,Di) -> (
markovR = markovRing (toSequence(Di));
R := ring (V);
Finv := map(R,markovR,R_*);
S := globalMarkov G;
I := Finv(conditionalIndependenceIdeal (markovR, S));
for k from 0 to length(R_*)-1 do (
I=saturate(I,R_k,Strategy=>Bayer);
print k;
V=saturate(V,R_k,Strategy=>Bayer);
print k;
);
I=saturate(I,sum(R_*),Strategy=>Bayer);
V=saturate(V,sum(R_*),Strategy=>Bayer);
J:=I+V;
for k from 0 to length(R_*)-1 do (
J=saturate(J,R_k,Strategy=>Bayer);
print k;
);
J=saturate(J,sum(R_*),Strategy=>Bayer);
result=J;
result
)

