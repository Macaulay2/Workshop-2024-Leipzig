loadPackage "GraphicalModels";

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


TEST\\\
G = mixedGraph(digraph {{1, {2}}, {2, {3}}});
tian = tianDecomposition(G);
tianTrue = {mixedGraph(digraph {{1, {}}}), mixedGraph(digraph {{1, {2}}}), mixedGraph(digraph {{2, {3}}})};
assert(#tian == #tianTrue)
\\\


G = mixedGraph(digraph {{1,{2,3}},{2,{3}},{3,{4}}},bigraph {{1, 2}, {2,4}})
tianDecomposition(G)

G = mixedGraph(digraph {{0, {1}}, {1, {2, 3}}, {2, {4}}, {3, {4}}, {6, {1, 3}}},
    bigraph {{2, {1, 5}}, {3, {4}}})
tG = tianDecomposition(G);
