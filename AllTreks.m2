loadPackage "GraphicalModels";

G = digraph{{1, {2}}, {2, {3, 4}}, {3, {4, 6}}, {5, {6}}};
G = digraph{{1, {2}}, {2, {3, 4}}, {3, {4}}}; 


allTreks = (G, i, j) -> {
    fG= digraphTranspose(G);
    k=#vertices(G);
    pathsi = flatten for n from 0 to k list findPaths(fG, i, n);
    pathsj = flatten for n from 0 to k list findPaths(fG, j, n);
    treks = flatten for p1 in pathsi list for p2 in pathsj list(
	q = if last p1==last p2 then {reverse p1, reverse p2} else continue
	)
}

allTreks = (G, i, j) -> {
    fG= digraphTranspose(G);
    k=#vertices(G);
    pathsi = findallPaths(fG, i);
    pathsj = findallPaths(fG, j);
    treks = flatten for p1 in pathsi list for p2 in pathsj list(
	q = if last p1==last p2 then {reverse p1, reverse p2} else continue
	)
}



findallPaths = (G,v) -> (
    nbors := toList children (G,v);
    l = #nbors;
    if l == 0 then {{v}}
    else(
        nPaths := apply(nbors, n -> findallPaths(G,n));
        {{v}} | flatten apply(nPaths, P -> apply(P, p -> {v} | p))
    )
)

ed = toList apply(1..5, i -> {i, {6, 7}})
G = digraph{ed};

findallPaths(G, 1)
allTreks(G, 4, 5)
