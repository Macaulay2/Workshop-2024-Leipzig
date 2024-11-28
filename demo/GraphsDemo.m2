load("../graphFunctions.m2")


G =  mixedGraph (digraph {{1,{2}},{2,{3,4}}, {4, {5}}},bigraph {{2,3}, {4,5}})
H = digraph(G)
displayGraph(H)						    -- see "Graphs" needs Graphviz

-------

treks(H, 4, 5)

------

tianDecomposition(G)

------

G = digraph {{1,{2}},{2,{3}}}
C = new HashTable from {1 => "red", 3 => "red", {2,3} => "blue"}
displayColoredGraph(G, C)


------

G = digraph({1,2,3},{{1,2},{2,3}})
C = new HashTable from {{1,2} => "red", {2,3} => "red"}
displayColoredGraph(G, C)
coloredGaussianVanishingIdeal(G, {l_(2,3)=>l_(1,2)})
