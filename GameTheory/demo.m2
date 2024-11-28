restart
needsPackage "GameTheory"
load "DependencyEquilibria.m2"
load "NEideal.m2"
load "GameTheory - CI.m2"


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
R = coefficientRing X0

X = {X0,X1}
--getVariableToIndexset (R,X)

CX = correlatedEquilibria X
dim CX
vertices CX
facets CX

