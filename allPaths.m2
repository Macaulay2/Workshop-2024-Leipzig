allPaths = (G, currentPath, endpoints) -> (
    lastNode = currentPath_-1;
    adjacentNodes = findPaths(G, lastNode, 1);

    if isMember(lastNode, endpoints) then return currentPath;
    if #adjacentNodes == 0 then return null;

    results = new mutableList from {};
    
    for n in adjacentNodes do (
	newPath = new mutableList from currentPath;
	newPath##newPath = n;
	for p in allPaths(G, newPath, endpoints) do (
	    if p != null then results##results = p;
	);    
	);
    return results;
)	   
