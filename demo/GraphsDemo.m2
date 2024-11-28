load("SignaturesDemo.m2")


G =  mixedGraph (digraph {{1,{2}},{2,{3,4}}, {4, {5}}},bigraph {{2,3}, {4,5}})
H = digraph(G)

treks(H, 3, 5)


tianDecomposition(G)



G = digraph {{2,{3}},{3,{4}}}
C = new HashTable from {2 => "red", 4 => "red", {2,3} => "blue"}
