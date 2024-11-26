treks = method()
treks(Digraph, Thing, Thing) := (G, i, j) -> (
    Parents1 = forefathers(G, i);
    Parents2 = forefathers(G, j);
    CommonParents = intersect(Parents1, Parents2);	    -- middle points of tracks
    pathset1 = pathsEndingInSet(G, i, CommonParents);
    pathset2 = pathsEndingInSet(G, j, CommonParents);
    if #pathset1 == 0 then return pathset2;		    -- trivial cases
    if #pathset2 == 0 then return pathset1;
    hashingPaths = new MutableHashTable;		    -- hash paths i<-CP according to CP-point 
    for p in pathset1 do (
	endpoint = p#-1;
	if hashingPaths#?endpoint == false then(
	    hashingPaths#endpoint = new MutableList from {p};
	    ) else (hashingPaths#endpoint)##(hashingPaths#endpoint) = p;
        );
    listofresults = new MutableList;		    -- extend paths to tracks to j
    for p in pathset2 do (
	endpoint = p#-1;
	for x in hashingPaths#endpoint do (
	    Y = new List from {x, reverse(p)};
	    listofresults##listofresults = Y;
	    );
	);
    return listofresults; 				    -- Mutablelist of treks
 )
    
pathsEndingInSet = method()
pathsEndingInSet(Digraph, Thing, Set) := (G, i, CommonParents) -> (
    listOfPaths = new MutableList;
    queue = new MutableList from {{i}};
    while #queue != 0 do(				    -- kind of bfs for all paths CP->i 
	p = remove(queue, 0);
	extensions = parents(G, p#-1);
	if #extensions != 0 then (
	    for endpoint in toList(extensions) do(
		extPath = new MutableList from p;
		extPath##extPath = endpoint;
		queue##queue = toList(extPath);
		if isMember(endpoint, CommonParents) == true then (
		    listOfPaths##listOfPaths = queue#-1;
		    );
		);
	    );
	);
    return listOfPaths;
 )

-- could be faster with two hashes and table(#i,#i) for each i

