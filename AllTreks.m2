allTreks = (G, i, j) -> {
    fG= digraphTranspose(G);
    k=#vertices(G);
    pathsi = flatten for n from 0 to k list findPaths(fG, i, n);
    pathsj = flatten for n from 0 to k list findPaths(fG, j, n);
    treks = flatten for p1 in pathsi list for p2 in pathsj list(
	q = if last p1==last p2 then {reverse p1, reverse p2} else continue
	)
}
