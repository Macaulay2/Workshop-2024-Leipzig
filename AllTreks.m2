loadPackage "GraphicalModels";

findallPaths = method()
findallPaths (Digraph, Thing) := List => (G,v) -> (
    nbors := toList children (G,v);
    l = #nbors;
    if l == 0 then {{v}}
    else(
        nPaths := apply(nbors, n -> findallPaths(G,n));
        {{v}} | flatten apply(nPaths, P -> apply(P, p -> {v} | p))
    )
)

allTreks = method()
allTreks (Digraph, Thing, Thing):= List => (G, u, v) -> (
    fG= digraphTranspose(G);
    k = #vertices(G);
    pathsu = findallPaths(fG, u);
    pathsv = findallPaths(fG, v);
    treks = flatten for p1 in pathsu list for p2 in pathsv list(
	q = if last p1==last p2 then {reverse p1, reverse p2} else continue
	)
)

TEST ///
G = digraph{{1, 3}, {2, 3}};
tr = allTreks(G, 1, 2);
assert(tr == {})
///

TEST ///
G = digraph{{3, {1, 2}}};
tr = allTreks(G, 1, 2);
assert(tr == {{{3, 1}, {3, 2}}})
///

TEST ///
G = digraph{{1, {2}}, {2, {3}}};
tr = allTreks(G, 1, 3);
assert(tr == {{{1}, {1, 2, 3}}}
///

TEST///
G = digraph{{2, {4, 6}}, {3, {6}}, {5, {3, 4}}, {6, {1}}};
tr = allTreks(G, 6, 4);
assert(tr == {{{2, 6}, {2, 4}}, {{5, 3, 6}, {5, 4}}})
///
