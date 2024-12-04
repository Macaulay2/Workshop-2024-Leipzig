needsPackage "Tropical"
needsPackage "Matroids"
needsPackage "Polyhedra"

-- Ollie's first attempt at coding Rincon's algorithm
-- for constructing the Bergman fan of a matroid

-- Design notes:
-- pref procedure uses backtracking 
-- partial function p: E-B -> B is stored as a mutable hashtable p(i) === p#i
-- total order L on Im(p) is stored as a hashtable i <_L j <==> L#i < L#j
-- updating the order L does not need to be fully backtracked since we
--   will insert 'b' in all positions of the order
-- there is also an additional mutable hashtable LLookup, which is the inverse
--   hash table of L, which (maybe) speeds up the L-update

-- Fixed Rincon's algorithm: (line 18)
-- We must also reject this ordering if there exists
-- l in [n]-B with l < k
-- p(l) in F_k
-- p(l) <=_L b
-- [for code readability, we use j instead of l in the code]

cyclicBergmanFan = method(
    Options => {
	Verbose => false,
	ReturnListOfCones => false -- returns a list of cones instead of a 'fan' object
	}
    )

cyclicBergmanFan Matroid := opts -> M -> (
    if #loops M != 0 then error("M must be loopless");
    
    n := #groundSet M;
    E := set(0 .. n-1);
    p := new MutableHashTable from for i from 0 to n-1 list i => null;
    -- p represents a function from [n]-B to B
    -- the ground set is {0 .. n-1}
    -- p(i) is represented as p#i
    
    L := new MutableHashTable from for i from 0 to n-1 list i => null;
    -- represents a total order on Im(p)
    -- if i and j are in Im(p), then i <_L j iff L#i < L#j

    LLookup := new MutableHashTable from for i from -1 to n-1 list i => null;
    -- 'inverse' table to L
    -- so if j is in the image of p
    -- then j == LLookup#(L#j)
    
    myPl := pl(p, L, LLookup);
    
    k := 0; --

    if opts.Verbose then (
	print("-- making cones");
	);
    
    coneList := flatten for B in bases M list (
	-- reset p, L, k
	for i from 0 to n-1 do (
	    p#i = null;
	    L#i = null;
	    LLookup#i = null;
	    );
	EMinusB := E - B;
	k = min keys EMinusB;
	F := fundamentalCircuits(M, B);
	-- print F;
	PLList := pref(k, myPl, F, EMinusB);
	--print(B);
	--print(netList PLList);
	cones := apply(PLList, x -> makeCone(x_0, x_1, B, EMinusB));
	--print(netList(rays \ cones));
	cones
	);

    if opts.Verbose then (
        print("-- constructed "| toString (#coneList) | " cones");
	);
    
    -- print(#coneList, coneList);
    if opts.ReturnListOfCones then (
	coneList
	)
    else (
	makeFan coneList
	)
    )

fundamentalCircuits = method()
fundamentalCircuits(Matroid, Set) := (M, B) -> (
    local result;
    EMinusB := (groundSet M) - B;
    new HashTable from for k in keys(EMinusB) list (
	for C in circuits M do (
	    C' := C-set {k};
	    if isSubset(C', B) then (
		result = C';
		break;
		);
	    );
	k => result
	)
    )

PL = new Type of HashTable 

pl = method()
pl(MutableHashTable, MutableHashTable, MutableHashTable) := (p, L, LLookup) -> (
    new PL from hashTable {"p" => p, "L" => L, "LLookup" => LLookup}
    )

-- k = end is symbolised by infinity
pref = method()
pref(Thing, PL, HashTable, Set) := (k, myPl, F, EMinusB) -> ( -- 4-argument work-around
    p := myPl#"p";
    L := myPl#"L";
    LLookup := myPl#"LLookup";
    n := #p;
    --print("enter", k, pairs p, pairs L);
    if k === infinity then (
	-- print("-- obtained pair");
	{
	    (
		for i from 0 to n-1 list p#i,
		for i from 0 to n-1 list L#i
		)
	    }
	)
    else (
	-- if Im(p) \cap F_k non-empty ...
	result := {};
	imageOfP := set values p - set {null};
	imageOfPIntersectFk := imageOfP * F#k;
	sizeImageOfP := #imageOfP;
	if #imageOfPIntersectFk != 0 then (
	    LSmallestElement := first sort(keys imageOfPIntersectFk, i -> L#i);
	    --print("keys: ", keys imageOfPIntersectFk, "L:", pairs L, "min:", LSmallestElement);
	    p#k = LSmallestElement;
	    k' := infinity;
	    for newKVal from k+1 to n-1 do (
		if EMinusB#?newKVal then (
		    k' = newKVal;
		    break;
		    );
		);

	    result = pref(k', myPl, F, EMinusB);

	    -- backtrack
	    p#k = null;
	    );
	for b in keys (F#k - imageOfP) do (
	    if b < k then (

		-- insert b into the ordering as the smallest element
		-- start by bumping everything in L up one position
		for j in keys imageOfP do (LLookup#(L#j + 1) = j;  L#j = L#j + 1;);
		L#b = 0;
		LLookup#0 = b;
		
		-- run over all possible positions for b in the order
		for i from 0 to sizeImageOfP do (
		    --print("for loop", k, pairs p, pairs L, b, i);
		    
		    -- if there exists no j in [n]-B satisfying all of:
		    -- j < k
		    -- b in F_j
		    -- b <_L p(j) 
		    -- we require p#j not null but this follows from the algorithm
		    
		    -- We must also reject this ordering if there exists
		    -- j in [n]-B with j < k
		    -- p(j) in F_k
		    -- p(j) <=_L b
		    
		    existsJ := false;
		    for j in keys EMinusB do (
			if (
			    j < k and member(b, F#j) and L#b < L#(p#j)
			    ) or (
			    j < k and member(p#j, F#k) and L#(p#j) < L#b
			    ) then ( 
			    existsJ = true;
			    break;
			    );
			);
		    

		    if not existsJ then (
			-- update p
			p#k = b;
			
			-- k' := min keys (EMinusB - set(0 .. k));
			k' := infinity;
			for newKVal from k+1 to n-1 do (
			    if EMinusB#?newKVal then (
				k' = newKVal;
				break;
				);
			    );
			--print("updated:", k, pairs p, pairs L, b, i);
			
			result = result | pref(k', myPl, F, EMinusB);
			-- backtrack p
			p#k = null;
			);

		    -- update L for the next part of the loop
		    if i+1 > sizeImageOfP then break;
			
		    L#(LLookup#(i+1)) = i; -- move the element in position i+1 down one place
		    LLookup#i = LLookup#(i+1);

		    L#b = i+1; -- move b up one place
		    LLookup#(i+1) = b;
		    );
		-- backtrack L
		L#b = null;
		LLookup#sizeImageOfP = null;
		);
	    );
	result
	)
    )

makeCone = method()
makeCone(List, List, Set, Set) := (p, L, B, EMinusB) -> (
    -- B a basis as a set
    -- p is a list {p(0), p(1), ..., p(n-1)}
    -- L is a list {}
    n := #p;
    -- given L#b for some b in Im(p), make a lookup table for b  
    LLookup := new HashTable from for b in keys B list (
	if L#b =!= null then L#b => b
	);
    
    -- make partition
    Q := new HashTable from for b in keys B list (
	b => {b} | for i from 0 to n-1 list (
	    if p#i =!= null and p#i == b then i else continue
	    )
	);

    -- directed edges i -> j are strored as pairs (i, j)
    graphEdges := new MutableList;
    
    -- add the spine of the caterpillar
    for i from 1 to #LLookup-1 do (
	graphEdges##graphEdges = (LLookup#(i-1), LLookup#i)
	);

    -- add legs of caterpillar
    for c in keys B do if L#c === null then (
	-- elements of B - Im(p)
	foundB := false;
	for bIndex in reverse(0 .. #LLookup-1) do (
	    b := LLookup#bIndex;
	    for k in keys EMinusB do (
		if p#k == b then (
		    graphEdges##graphEdges = (b, c);
		    foundB = true;
		    break;
		    );
		);
	    if foundB then break;
	    );
	);

    -- use Tree to construct cone
    -- use halfspace description
    -- A.x >= 0
    -- E.x = 0
    A := matrix for e in graphEdges list (
	for i from 0 to n-1 list (
	    -- edge is e_0 -> e_1
	    -- pick representatives for e_0 and e_1 from Q
	    b := Q#(e_0)#0;
	    c := Q#(e_1)#0;
	    if i == b then (
		-1
		)
	    else if i == c then (
		1
		)
	    else 0
	    )	
	);
    E := matrix flatten for b in keys B list (
	if #Q#b == 1 then continue
	else for i from 1 to #Q#b -1 list (
	    for j from 0 to n-1 list (
		if j == Q#b#i then (
		    -1
		    )
		else if j == b then (
		    1
		    )
		else 0
		)
	    )
	);
    coneFromHData(A, E)
    )


-- given a list of cones of Bergman fan, make a fan
makeFan = method()
makeFan List := coneList -> (
    if #coneList == 0 then error("expected non-empty list of cones");
    L := linealitySpace (coneList_0);
    RayTable := new MutableHashTable;
    RayList := new MutableList;
    numberOfRays := 0;
    maxConeList = for C in coneList list (
	for i from 0 to numColumns rays C -1 list (
	    ray := (rays C)_{i};
	    if not RayTable#?ray then (
		RayTable#ray = numberOfRays;
		RayList#numberOfRays = ray;
		numberOfRays = numberOfRays + 1;
		);
	    RayTable#ray
	    )
	);
    rayMatrix := fold((a,b) -> a|b, toList RayList);
    fan(rayMatrix, L, maxConeList)
    )

unitCube = method()
unitCube(ZZ) := d -> (
  if d <= 0 then error("expected dimension at least 1");
  if d == 1 then matrix {{0, 1}}
  else (
    C := unitCube(d-1);
    (matrix {toList(2^(d-1) : 0)} || C) | (matrix {toList(2^(d-1) : 1)} || C)
  )
)



end --

load "fastBergmanFan.m2"

M = uniformMatroid(3, 10)

-- U_{3,10} takes around 0.98s 
CBF = elapsedTime cyclicBergmanFan(M, Verbose => true, ReturnListOfCones => false);
--rays \ CBF
--(c -> (rays CBF)_c) \ maxCones CBF

-- U_{3,10} takes around 125.4s
BF = elapsedTime BergmanFan M;
#maxCones BF
(c -> (rays BF)_c) \ maxCones BF

n = 3
M = matroid (matrix {toList(2^n : 1)} || unitCube n)

CBF = elapsedTime cyclicBergmanFan(M, ReturnListOfCones => true);
#CBF
rays CBF

BF = BergmanFan M;


n = 4
M = matroid (matrix {toList(2^n : 1)} || unitCube n)

CBF = elapsedTime cyclicBergmanFan(M, ReturnListOfCones => true);
#CBF
rays CBF

BF = BergmanFan M;




A = matrix {
    {1, 1, 0, 0, 1, 0},
    {0, 0, 1, 1, 0, 1},
    {0, 0, 0, 0, -1, -1}
    }
M = matroid A

CBF = elapsedTime cyclicBergmanFan(M, ReturnListOfCones => false, Verbose => true);
rays CBF

maxCones CBF


-- Testing how long it takes to construct fans from cones:
-- rough answer: it double the time 

elapsedTime cyclicBergmanFan(uniformMatroid(5, 10), ReturnListOfCones => true);
-- about 1.7s

F = elapsedTime cyclicBergmanFan(uniformMatroid(5, 10), ReturnListOfCones => false);
-- about 3.5s

elapsedTime cyclicBergmanFan(uniformMatroid(5, 11), ReturnListOfCones => true);
-- about 5.3s

F = elapsedTime cyclicBergmanFan(uniformMatroid(5, 11), ReturnListOfCones => false);
-- about 9.4s

elapsedTime cyclicBergmanFan(uniformMatroid(6, 12), ReturnListOfCones => true);
-- about 21s 

F = elapsedTime cyclicBergmanFan(uniformMatroid(6, 12), ReturnListOfCones => false);
-- about 28s


