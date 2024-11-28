needsPackage "GraphicalModels"

TianDecomposition = method()
TianDecomposition (MixedGraph) := (G) -> (
    C = underlyingGraph(bigraph(G));
    C = addVertices(C, vertices(G));
    C = connectedComponents(C);
    Tian = new MutableList;				    -- for all Tian components
    for comp in C do(
	TianComponent = TianSubgraph(G, comp)
	Tian##Tian = TianComponent;
	);
    return Tian						    -- output Tian decomposition
    )



TianSubgraph = method()
TianSubgraph (MixedGraph, List) := (G, comp) -> (	    --  G mixgraph, C con.comp. of subgraph
    graphcomp = inducedSubgraph(bigraph(G), comp);
    D = digraph(G);
    directedcomp = digraph{};				    -- directed subgraph of Tian component
    for vertex in comp do (
	directedcomp = addVertices(directedcomp, {vertex});
	if isMember(vertex,vertices(D)) == true then(
	    pa = toList(parents(D, vertex));		    -- joining parents
	    for par in pa do(
		if isMember(par, vertices(directedcomp)) != true then (
		    directedcomp = addVertices(directedcomp, {par});
		    );	
		directedcomp = addEdges'(directedcomp, {{par,vertex}});
		);
	    ); 
	);
    TianSub = mixedGraph (directedcomp, bigraph(edges(graphcomp)));
    return TianSub
    )


G =  mixedGraph (digraph {{1,{2}},{2,{3,4}}, {4, {5}}},bigraph {{2,3}, {4,5}})

