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


----------------------------------------


tianDecomposition = method()
tianDecomposition (MixedGraph) := List => (G) -> (    

Gb = underlyingGraph bigraph G;
Gb = addVertices(Gb, vertices G);
Gd = digraph G;
Gd = addVertices(Gd, vertices G);
connComp = connectedComponents Gb;
GGb = bigraph G;
    	    	    	     

  
for comp in connComp list (
    gd = inducedSubgraph(Gd, comp);
    ggb = inducedSubgraph(GGb, comp);
    for v in comp list (
    	gd = addVertices(gd, toList parents(Gd, v));
	findedg = findPaths(digraphTranspose Gd, v, 1);
	findedg = apply(findedg, e -> reverse e);
	if #findedg > 0 then gd = addEdges'(gd, findedg);
	ggb = addVertices(ggb, toList parents(Gd, v));
	);
    mixedGraph(gd, bigraph edges ggb)
    )
)

-------------------------------------

writeColoredDotFile = method()
writeColoredDotFile (String, Graph, HashTable) := (filename, G, C) ->
    writeColoredDotFileHelper(filename, G, C, "graph", "--")
writeColoredDotFile (String, Digraph, HashTable) := (filename, G, C) ->
    writeColoredDotFileHelper(filename, G, C, "digraph", "->")

writeColoredDotFileHelper = (filename, G, C, type, op) -> (
    fil := openOut filename;
    fil << type << " G {" << endl;
    V := vertexSet G;
    I := hashTable apply(#V, i -> V_i => i);    
    scan(V, v -> fil << "\t" << I#v << " [label= \"" << toString v << "\"" << (if C#?v then concatenate(", color= \"",C#v,"\"];") else "];")  << endl);
    E := toList \ edges G;
    scan(E, e -> fil << "\t" << I#(e_0) << " " << op << " " << I#(e_1) << (if C#?e then concatenate(" [", "color= \"",C#e,"\"];") else ";") << endl);
    fil << "}" << endl << close;
    )


graphs'DotBinary = if instance((options Graphs).Configuration#"DotBinary", String) then (options Graphs).Configuration#"DotBinary" else "dot";


runcmd := cmd -> (
     stderr << "-- running: " << cmd << endl;
     r := run cmd;
     if r != 0 then error("-- command failed, error return code ", r);
     )

displayColoredGraph = method()
displayColoredGraph (String, String, Digraph, HashTable) := (dotfilename, jpgfilename, G, C) -> (
     writeColoredDotFile(dotfilename, G, C);
     runcmd(graphs'DotBinary  | " -Tjpg " | dotfilename | " -o " | jpgfilename);
     show URL("file://" | toAbsolutePath jpgfilename);
     )
displayColoredGraph (String, Digraph, HashTable) := (dotfilename, G, C) -> (
     jpgfilename := temporaryFileName() | ".jpg";
     displayColoredGraph(dotfilename, jpgfilename, G, C);
     )
displayColoredGraph (Digraph, HashTable) := (G, C) -> (
     dotfilename := temporaryFileName() | ".dot";
     displayColoredGraph(dotfilename, G, C);
     )

 
