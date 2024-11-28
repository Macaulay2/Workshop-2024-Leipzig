treks = method()
treks(Digraph, Thing, Thing) := (G, i, j) -> (
    Parents1 = forefathers(G, i);
    Parents2 = forefathers(G, j);
    commonParents = intersect(Parents1, Parents2);	    -- middle points of tracks
    pathset1 = pathsEndingInSet(G, i, commonParents);
    pathset2 = pathsEndingInSet(G, j, commonParents);
    if #pathset1 == 0 then return pathset2;		    -- trivial cases
    if #pathset2 == 0 then return pathset1;
    if isMember(i, commonParents) then pathset1##pathset1 = {i};
    if isMember(j, commonParents) then pathset1##pathset2 = {j};    
    hashingPaths = new MutableHashTable;		    -- hash paths i<-CP according to CP-point
    for p in pathset1 do (
	endpoint = p#-1;
	if not hashingPaths#?endpoint then(
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
pathsEndingInSet(Digraph, Thing, Set) := (G, i, commonParents) -> (
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
		if isMember(endpoint, commonParents) == true then (
		    listOfPaths##listOfPaths = queue#-1;
		    );
		);
	    );
	);
    return listOfPaths;
)

-- could be faster with two hashes and table(#i,#i) for each i
G = digraph {{1, {2,3}}, {2, {3,4}}, {3,{4,5}}}


treks2 = method()
treks2 (Digraph, Thing, Thing) := (G, i, j) -> (
    parents1 = forefathers(G, i);
    parents2 = forefathers(G, j);
    commonParents = intersect(parents1, parents2);
    pathset1 = pathsEndingInSet(G, i, commonParents);
    pathset2 = pathsEndingInSet(G, j, commonParents);
    -- trivial cases
    if #pathset1 == 0 then return pathset2;		   
    if #pathset2 == 0 then return pathset1;
    -- nontrivial case
    if isMember(i, commonParents) then pathset1##pathset1 = {i};
    if isMember(j, commonParents) then pathset1##pathset2 = {j};    
    ListingParents = toList(commonParents);
    hashingPaths = new MutableHashTable from apply(#ListingParents, i -> (ListingParents#(i), new MutableList));
    for p in pathset1 do (
	endpoint = p#-1;
	(hashingPaths#endpoint)##(hashingPaths#endpoint) = p;
	);
    -- can be faster with second hash table and table for each key
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


TEST ///
G = digraph{{1, 3}, {2, 3}};
tr = toList treks2(G, 1, 2);
assert(tr == {})
///

TEST ///
G = digraph{{3, {1, 2}}};
tr = toList treks2(G, 1, 2);
assert(tr == {{{1, 3}, {3, 2}}})
///

TEST ///
G = digraph{{1, {2}}, {2, {3}}};
tr = toList treks(G, 1, 3);
assert(tr == {{{3, 2, 1}}});
///

TEST///
G = digraph{{2, {4, 6}}, {3, {6}}, {5, {3, 4}}, {6, {1}}};
tr = toList treks2(G, 6, 4);
assert(tr == {{{6, 3, 5}, {5, 4}}, {{6, 2}, {2, 4}}})
///

