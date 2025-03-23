needsPackage "GraphicalModels"


-- idea of the code: compute all directed paths in G afterwards combine them to compute all Treks

sparseStructure = (G, direction) -> (
    -- structure for computations, stores start-vertex, end-vertex and edge betreen them -> later all paths of length k between them 
    E = edges(G);
    if direction == +1 then (
	return new HashTable from apply(E, i -> i#0 => new HashTable from apply(E, j -> if (i#0 == j#0) then (j#1 => j)))
	)
    else (
	return new HashTable from apply(E, i -> i#1 =>  true)
	);   
    )

-- "multiply" current k-th power of the adjacency matrix (paths) with adjacency matrix to get paths of length k+1
pathMult = (edgs, paths, rev) -> (
    ext = new MutableHashTable from {};
    for start in keys(paths) do (
	for endpoint in keys(rev) do (
	    extpaths = new MutableList from {};
	    for mid in keys(paths#start) do (
		if edgs#?mid and edgs#mid#?endpoint then (
		    if class(paths#start#mid#0) === List then (
			for extpath in paths#start#mid do (extpaths##extpaths = flatten({extpath, endpoint}))
			)
		    else (extpaths##extpaths = flatten({paths#start#mid, endpoint}))
		    );
		);
	    extpaths = new List from extpaths;
	    if not(extpaths#?1) then (
		extpaths = flatten(extpaths);
		);  
	    if #extpaths > 0 then(
		if not ext#?start then (ext#start = new MutableHashTable from {endpoint => extpaths})
		else (ext#start#endpoint = extpaths);
		);
    	    );
	);
    return ext
   )   


-- first code computes all powers of sparse version of adjacency matrix
pathGen  = (G) -> (
    V = vertices(G);
    rev = sparseStructure(G, -1);
    -- i-th entry of paths has all paths of leghth i in G
    paths = new MutableList from {new HashTable from apply(V, v-> v => new HashTable from {v => {v}}), sparseStructure(G, +1)};
    while #keys(paths#(#paths-1)) > 0 do (paths##paths = pathMult(paths#1, paths#(#paths-1), rev));  
    -- combine all of the hashtables into one
    combpaths = new MutableHashTable from apply(V, v -> v => new MutableHashTable from apply(V, w -> w => new MutableList from {}));
    for pathlength in apply((#paths-1), v->paths#v) do (
	for startp in keys(pathlength) do (
	    for endp in keys(pathlength#startp) do (
		if class((pathlength#startp#endp)#0) === List then (
		    for starttoend in pathlength#startp#endp do (
			(combpaths#startp#endp)##(combpaths#startp#endp) = starttoend;
			);
		    )
		else (
		    (combpaths#startp#endp)##(combpaths#startp#endp) = pathlength#startp#endp;
		    ); 
		);
	    );
	);
    return combpaths
    )


-- second code computes reverse version of bfs which only apends elements to queue if all paths starting from it are found
BfsPathGen = (G) -> (
    -- input digraph G, output all paths in G
    V = vertices (G);
    E = edges(G);
    exitdegrees = new MutableHashTable from apply(V, v -> v => degreeOut(G, v));
    pathsStartingInVertex = new MutableHashTable from apply(V, v -> v => new MutableHashTable from apply(V, w -> w => new MutableList from {}));
    endingEdges = new MutableHashTable from apply(V, v -> v => new MutableHashTable from {});
    for edge in E do (
	endingEdges#(edge#1)#(edge#0) = edge;
	);
    queue = new MutableList from select(apply(V, v-> if exitdegrees#v == 0 then v), x-> not(x === null));
    current = 0;
    while current < #V do(
	topVert = queue#current;
	for found in keys(endingEdges#topVert) do (
	    exitdegrees#found = exitdegrees#found -1;
	    if exitdegrees#found == 0 then queue##queue = found;
	    (pathsStartingInVertex#found#topVert)##(pathsStartingInVertex#found#topVert) = {found,topVert};
	    for keyext in keys(pathsStartingInVertex#topVert) do (
		if #(pathsStartingInVertex#topVert#keyext) > 0 then (
		    for pathext in pathsStartingInVertex#topVert#keyext do (
			(pathsStartingInVertex#found#keyext)##(pathsStartingInVertex#found#keyext) = flatten({found, pathext});
			);
		    );
		);
	    );
	current = current +1;
	);
    apply(V, v -> (pathsStartingInVertex#v#v)##(pathsStartingInVertex#v#v) = {v});
    return pathsStartingInVertex
    )

---
--G = digraph {{1, {2,3,4,5,6,7,8,9}}, {2, {3,4,5,6,7,8,9}}, {3, {4,5,6,7,8,9}}, {4,{5,6,7,8,9}}, {5, {6,7,8,9}}, {6, {7,8,9}}, {7, {8,9}}, {8, {9}}}

--sum(apply(1000, x -> (elapsedTiming(pathGen(G)))#0))
--sum(apply(1000, x -> (elapsedTiming(BfsPathGen(G)))#0))

-- from my testting Bfs is better in non-sparse situations while normal is faster in sparse graphs
-- none of them have propper loop protection (for cyclic graphs) at the moment 
---



allTreks = (G) -> (
    -- this computation takes up almost all of the running time
    -- can be improved by propperly choosing just the necessary midpoints for each pair
    -- can be improved by just computing for end2>end1 and use symmetry
    V = vertices (G);
    paths = pathGen(G);
    --paths = BfsPathGen(G);
    treks = new MutableHashTable from apply(V, v -> v => new MutableHashTable from apply(V, w -> w => new MutableList from {}));
    for end1 in V do (
	for end2 in V do(
	    for mid in V do (
		if #(paths#mid#end1)>0 and #(paths#mid#end2)>0 then (
		    for trek1 in paths#mid#end1 do (
			for trek2 in paths#mid#end2 do(
			    (treks#end1#end2)##(treks#end1#end2) = (reverse(trek1), trek2);
			    );
			);
		    );
		);
	    );
	);
    return treks
    )

--G = digraph {{1, {2,3,4,5,6,7,8,9}}, {2, {3,4,5,6,7,8,9}}, {3, {4,5,6,7,8,9}}, {4,{5,6,7,8,9}}, {5, {6,7,8,9}}, {6, {7,8,9}}, {7, {8,9}}, {8, {9}}}
--(elapsedTiming(allTreks(G)))#0
--sum(apply(10, x -> (elapsedTiming(allTreks(G)))#0))
