restart
needsPackage "GameTheoryinitial"
load "DependencyEquilibria.m2"
load "NEideal.m2"
load "GameTheory - CI.m2"

--CORRELATED EQUILIBRIA
--- Traffic lights game
Di = {2,2}
        
X0 = zeroTensor Di
X1 = zeroTensor Di
	
X0#{0,0} = -99
X0#{0,1} = 1
X0#{1,0} = 0
X0#{1,1} = 0

X1#{0,0} = -99
X1#{0,1} = 0
X1#{1,0} = 1
X1#{1,1} = 0

format X0
indexset X0

PRi = enumerateTensorIndices Di
probabilityRing = QQ[apply(PRi, pr -> p_pr)]
gens probabilityRing

X = {X0,X1}

CX = correlatedEquilibria X
dim CX
vertices CX
facets CX

--- Random 2x2x2 game
Di = {2,2,2}
X = {randomTensor Di, randomTensor Di, randomTensor Di}
CX = correlatedEquilibria X
dim CX
vertices CX
facets CX

---NASH EQUILIBRIA
--- Random 2x2x2 game
Di = {2,2,2}
X = {randomTensor Di, randomTensor Di, randomTensor Di}
R = NERing X
I = NEideal (R,X)
dim I
degree I

---Example to generate a list of random tensors and compute the Nash equilibrium ideal

nofplayers = 3
dimGameTensor = {3,2,3}
randomTensorList = apply(nofplayers, i->randomTensor dimGameTensor)
randomNEring = NERing (randomTensorList)
randomIdeal = NEideal(randomNEring, randomTensorList)
dim randomIdeal

---DEPENDENCY EQUILIBRIA
--- Traffic lights
Di = {2,2}
PR = probabilityRing Di
describe PR
pTensor = PR#"probabilityVariable"
peek pTensor
SpohnMatrices = spohnMatrices(PR, {X0, X1})
SpohnIdeal = spohnIdeal(PR, {X0, X1})
dim SpohnIdeal
degree SpohnIdeal
KonstanzMatrix = konstanzMatrix(PR, {X0, X1})

--- Random 2x3x2 game

Di = {2,3,2}
FF = ZZ/101
PR = probabilityRing(Di, CoefficientRing=>FF)
gens PR
X = randomGame(Di, CoefficientRing=>FF)
SpohnMatrices = spohnMatrices(PR, X)
SpohnIdeal = spohnIdeal(PR, X)
codim SpohnIdeal
degree SpohnIdeal
KonstanzMatrix = konstanzMatrix(PR, X)

--- Generic game
Di = {2,2}
PPR = payoffProbabilityRing(Di, CoefficientRing=>RR, ProbabilityVariableName=>"P", PayoffVariableName=>"x")
gens PPR
X = genericGame PPR
SpohnMatrices = spohnMatrices(PPR, X)
SpohnIdeal = spohnIdeal(PPR, X)
KonstanzMatrix = konstanzMatrix(PPR, X)



---CONDITIONAL EQUILIBRIA
--- 2x2 game
FF = ZZ/32003
d = {2,2}
X = randomGame(d, CoefficientRing => FF)
PR = probabilityRing(d, CoefficientRing => FF)
V = spohnIdeal(PR, X)

G1 = graph {{1,2}}
G2 = graph ({}, Singletons => {1,2})

I1 = intersectCImodel(G1, V, d)
I2 = intersectCImodel(G2, V, d)

--- 2x2x2 game
d = {2,2,2}
X = randomGame(d, CoefficientRing => FF)
PR = probabilityRing(d, CoefficientRing => FF)
V = spohnIdeal(PR, X)

G1 = graph ({}, Singletons => {1,2,3})
G2 = graph ({{1,2}}, Singletons => {3})
G3 = graph {{1,2},{2,3}}
G4 = graph {{1,2},{2,3},{3,1}}

I1 = intersectCImodel(G1, V, d)
I2 = intersectCImodel(G2, V, d)
I3 = intersectCImodel(G3, V, d)
I4 = intersectCImodel(G4, V, d)

--- 2x3x2 game
d = {2,3,2}
X = randomGame(d, CoefficientRing => FF)
PR = probabilityRing(d, CoefficientRing => FF)
V = spohnIdeal(PR, X)

I1 = intersectCImodel(G1, V, d)
I2 = intersectCImodel(G2, V, d)
I4 = intersectCImodel(G4, V, d)
I3 = intersectCImodel(G3, V, d)
