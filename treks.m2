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



