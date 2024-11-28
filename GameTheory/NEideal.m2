needsPackage "GameTheory"

--random integer valued tensors (instead of real valued) for testing purposes
randomTensorInteger = method()
randomTensorInteger List := dims -> (
   result := new Tensor;
   indexset := enumerateTensorIndices dims;
   for i in indexset do
      result#i = random 10;
   result#"format" = dims;
   result
)

randomTensorInteger (List, ZZ) := (dims,t) -> (
   result := new Tensor;
   indexset := enumerateTensorIndices dims;
   for i in indexset do
      result#i = random t;
   result#"format" = dims;
   result
)

--mixedprobabilityRing; 

mixedprobabilityRing = method()
mixedprobabilityRing List := L ->(
    probabilityRing := RR[flatten apply(#L, i -> apply(L#i, j->p_{i,j} ))];
    probabilityRing
)
mixedprobabilityRing Tensor := T ->(
    indexSet := format T;
    mixedprobabilityRing indexSet
)

-- expands the method enumerateTensorIndices to case when the list is empty; can be absored into the original function into main package
enumerateTensorIndices2 = method()
enumerateTensorIndices2 ZZ := z -> foobar Z
enumerateTensorIndices2 List := s -> (
   if length s == 0 then 
      return {}
   else
      result = enumerateTensorIndices s;
      result
)

--summing function, returnings the generating polynomials from the u-th player,

NEpolynomials = method()
NEpolynomials (Tensor, ZZ, Ring) := (T, u, R)->(
    -- u for the u-th player (0-based), R for the ambient polynomial ring;
    -- in general, R should be mixedprobabilityRing(T), but in this function we should not regenerate R in place to keep all polynomials in the same ring
    indexSet := format T;
    --return indexSet;
    indexLength := length indexSet;
    indFirst := take(indexSet, {0,u - 1});
    indLast := take(indexSet, {u + 1, indexLength -1 });
    allFirst := enumerateTensorIndices2 indFirst;
    allLast := enumerateTensorIndices2 indLast;
    loopIndices := enumerateTensorIndices indexSet;
    -- sumup for u-th player
    probabilityRing := R;
    d := indexSet#u;
    Xslice =
    if u == 0 then
         sum (allLast, j->apply( slice(T,{},j),apply(0..d - 1, k->product(apply(transpose({toList(0..indexLength - 1), join({k},j)  }), v->(p_v) ^(if first v == u then 0 else 1)))), (s,t) -> s * t))
    else if u == indexLength - 1 then
         sum (allFirst,i->apply( slice(T,i,{}),apply(0..d - 1, k->product(apply(transpose({toList(0.. (indexLength - 1)), join(i,{k})  }), v->(p_v) ^ (if first v == u then 0 else 1)))), (s,t)-> s * t))
    else
         sum (allFirst,i-> sum (allLast,j->apply( slice(T,i,j), apply(0..d - 1, k->product(apply(transpose({toList(0..indexLength -1), join(i,{k},j)  }), v-> p_v ^ (if first v == u then 0 else 1))) ), (s,t)-> s * t)));
    generatingpolynomials := apply(toList(1..(length Xslice - 1)), i -> (Xslice#i - Xslice#0));
    generatingpolynomials
)

--the main method to return the ideal for a totally mixed Nash totally mixed Nash equilibria question.
NEideal = method()
NEideal = List := L -> (
    -- L is a list consisting of n- tensors; requires them to be of the same dimension/shape
    indexSet := format first L;
    --return indexSet;
    polyring := mixedprobabilityRing indexSet;
    --wholepoly := for i to (indexLength - 1) list NEpolynomials(T,i);
    completeGeneratingSet := flatten(apply(pairs L, (i,T) -> NEpolynomials(T,i,polyring)));
    neIdeal:= ideal(completeGeneratingSet);
    neIdeal
)

--example for auxiliary methods
TestTensor1 = randomTensorInteger {3,2,4}
format TestTensor1
testRing = mixedprobabilityRing TestTensor1
gens testRing
NEpolynomials (TestTensor1, 0, testRing)

--test for NEideal

--2-player-game, and we put in our own payoff tensors
TestTensor2 = zeroTensor {2,2}
TestTensor3 = zeroTensor {2,2}
TestTensor2#{0,0} = 2
TestTensor2#{0,1} = 3
TestTensor2#{1,0} = 4
TestTensor2#{1,1} = 5
TestTensor3#{0,0} = 6
TestTensor3#{0,1} = 7
TestTensor3#{1,0} = 8
TestTensor3#{1,1} = 9

TotalTestTensors = {TestTensor2, TestTensor3}
NEideal TotalTestTensors

--example to generate a list of random tensors and compute the ideal from it
nofplayers = 4
dimGameTensor = {3,2,3,4}
randomTensorList = apply(nofplayers, i->randomTensor (QQ,dimGameTensor))
NEideal randomTensorList
--4-player-game, where players have {3,2,3,4} choices
