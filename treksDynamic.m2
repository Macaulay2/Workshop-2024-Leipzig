needsPackage "GraphicalModels"


-- idea of the code: compute all directed paths in G; combine them pairwise to compute all Treks
-- use matrix multiplication for the adjacency matrix, where multilplication corresponds to enlarging the path and addition corresponds to finding another path

sparseStructure = (G, direction) -> (
    E = edges(G);
    if direction == +1 then (
	-- structure for computations, stores start-vertex, end-vertex and edge betreen them -> later all paths of length k between them 
	return new HashTable from apply(E, i -> i#0 => new HashTable from apply(E, j -> if (i#0 == j#0) then (j#1 => j)))
	)
    else (
	-- has vertex any edge ending in it 
	return new HashTable from apply(E, i -> i#1 =>  true)
	);   
    )

-- multiply k-th power of the adjacency matrix (paths) with adjacency matrix to get paths of length k+1
pathMult = (edgs, paths, rev) -> (
    ext = new MutableHashTable from {};
    for start in keys(paths) do (
	for endpoint in keys(rev) do (
	    -- compute (start, endpoint) in outputmatrix
	    extpaths = new MutableList from {};
	    for mid in keys(paths#start) do (
		if edgs#?mid and edgs#mid#?endpoint then (
		    -- there exist at least one path (start --- mid - endpoint) of lenght n+1
		    if class(paths#start#mid#0) === List then (
			-- resolve case of multiple paths of the form start -- mid
			for extpath in paths#start#mid do (extpaths##extpaths = flatten({extpath, endpoint}))
			)
		    else (extpaths##extpaths = flatten({paths#start#mid, endpoint}))
		    );
		);
	    extpaths = new List from extpaths;
	    -- resolve case of just one vertex mid connecting start and end
	    if not(extpaths#?1) then extpaths = flatten(extpaths);
	    -- write outputmatrix
	    if #extpaths > 0 then(
		if not ext#?start then (ext#start = new MutableHashTable from {endpoint => extpaths})
		else (ext#start#endpoint = extpaths);
		);
    	    );
	);
    return ext
   )   


-- first variant for computing all paths: computes  powers of sparse version of adjacency matrix
pathGen  = (G, V) -> (
    rev = sparseStructure(G, -1);
    -- i-th entry of paths has all paths of leghth i in G
    paths = new MutableList from {new HashTable from apply(V, v-> v => new HashTable from {v => {v}}), sparseStructure(G, +1)};
    -- basic infinite loop prevention
    pathlen = 1;
    while #keys(paths#(#paths-1)) > 0 do (
	paths##paths = pathMult(paths#1, paths#(#paths-1), rev);
	pathlen = pathlen +1;
	);
    if #keys(paths#(#paths-1)) > 0 then error "the graph is not acyclic";
    -- combine all of the hashtables into one (startpoint => endpoint => {all paths between them})
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


-- second variant for computing all paths: computes reverse version of bfs which only apends elements to queue if all paths starting from it are found
BfsPathGen = (G, V) -> (
    -- input digraph G, output all paths in G
    E = edges(G);
    exitdegrees = new MutableHashTable from apply(V, v -> v => degreeOut(G, v));
    pathtable = new MutableHashTable from apply(V, v -> v => new MutableHashTable from apply(V, w -> w => new MutableList from {}));
    endingEdges = new MutableHashTable from apply(V, v -> v => new MutableHashTable from {});
    for edge in E do (
	endingEdges#(edge#1)#(edge#0) = edge;
	);
    queue = new MutableList from select(apply(V, v-> if exitdegrees#v == 0 then v), x-> not(x === null));
    current = 0;
    while current < #V do(
	if #queue == current then error "the graph is not acyclic";
	topVert = queue#current;
	for found in keys(endingEdges#topVert) do (
	    exitdegrees#found = exitdegrees#found -1;
	    if exitdegrees#found == 0 then queue##queue = found;
	    (pathtable#found#topVert)##(pathtable#found#topVert) = {found,topVert};
	    for keyext in keys(pathtable#topVert) do (
		if #(pathtable#topVert#keyext) > 0 then (
		    for pathext in pathtable#topVert#keyext do (
			(pathtable#found#keyext)##(pathtable#found#keyext) = flatten({found, pathext});
			);
		    );
		);
	    );
	current = current +1;
	);
    apply(V, v -> (pathtable#v#v)##(pathtable#v#v) = {v});
    return pathtable
    )

---
-- G = digraph {{1, {2,3,4,5,6,7,8,9}}, {2, {3,4,5,6,7,8,9}}, {3, {4,5,6,7,8,9}}, {4,{5,6,7,8,9}}, {5, {6,7,8,9}}, {6, {7,8,9}}, {7, {8,9}}, {8, {9}}}

-- sum(apply(1000, x -> (elapsedTiming(pathGen(G)))#0))
-- sum(apply(1000, x -> (elapsedTiming(BfsPathGen(G)))#0))

-- from my testting Bfs is better in non-sparse situations while normal is faster in sparse graphs
-- none of them have propper loop protection (for cyclic graphs) at the moment 
---



-- for application need (top, path1, path2) where top is source of both paths -> tensor endpoint1 => endpont2 => top => all treks connecting them
allTreks = (G) -> (
    V = vertices (G);
    paths = pathGen(G, V);
    --paths = BfsPathGen(G, V);
    treks = new MutableHashTable from apply(V, e1 -> e1 => new MutableHashTable from apply(V, e2 -> e2 => new MutableHashTable from apply(V, t -> t => new MutableList from {})));
    for topvertex in keys(paths) do(
	endpoints = keys(paths#topvertex);
	if #endpoints > 1 then(
	    for index1 from 0 to #endpoints-2 do(
		for index2 from index1+1 to #endpoints-1 do(
		    end1 = endpoints#index1;
		    end2 = endpoints#index2;
		    for trek1 in paths#topvertex#end1 do (
			for trek2 in paths#topvertex#end2 do(
			    (treks#end1#end2#topvertex)##(treks#end1#end2#topvertex) = (reverse(trek1), trek2);
			    (treks#end2#end1#topvertex)##(treks#end2#end1#topvertex) = (reverse(trek2), trek1);
			    );
			);
		    );
		);
	    );
	-- im not sure how to save the other case (treks of the length one) for application afterwards- needs to be done here
	);
    return treks
    )

-- G = digraph {{1, {2,3,4,5,6,7,8,9}}, {2, {3,4,5,6,7,8,9}}, {3, {4,5,6,7,8,9}}, {4,{5,6,7,8,9}}, {5, {6,7,8,9}}, {6, {7,8,9}}, {7, {8,9}}, {8, {9}}}
-- (elapsedTiming(allTreks(G)))#0
-- sum(apply(10, x -> (elapsedTiming(allTreks(G)))#0))
