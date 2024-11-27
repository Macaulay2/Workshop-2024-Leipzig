TianDecomposition = method()
TianDecomposition (MixedGraph) := (G) -> (
    C = connectedComponents(undirectedGraph(G));
    Tian = new MutableList;				    -- for all Tian components
    for comp in C do(
	TianComponent = TianSubgraph(G, comp);
	Tian##Tian = TianComponent;
	);
    return Tian						    -- output Tian decomposition
    )

TianSubgraph = method()
TianSubgraph (MixedGraph, List) := (G, comp) -> (	    --  G mixgraph, C con.comp. of subgraph
    graphcomp = inducedSubgraph(undirectedGraph(G), comp);
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
    TianSub = mixedGraph(graphcomp, directedcomp);
    return TianSub
    )

