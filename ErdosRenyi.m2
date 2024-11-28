needsPackage "Probability"
needsPackage "GraphicalModels"


erdosRenyiGraph = (n, p) -> (

    P := bernoulliDistribution(p);
    E := for e in subsets(1..n, 2) list if random(P) == 1 then e else continue;

    return digraph(toList(1..n), E)
);


n = 50
p = .2
G = erdosRenyiGraph(n, p)