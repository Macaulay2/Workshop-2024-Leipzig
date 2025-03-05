doc ///
Key
    makeWeylAlgebra
    (makeWeylAlgebra, PolynomialRing, List)
    (makeWeylAlgebra, PolynomialRing)
Headline
    initialize WeylAlgebra with one differentials for each variable in the polynomial ring with weights
Usage
    makeWeylAlgebra(R,w)
    makeWeylAlgebra(R)
Inputs
    R:PolynomialRing
        over the rationals
    w:List
        of weights
Outputs
    makeWeylAlgebra:PolynomialRing
        with formal non-commuting variables as differentials
Description
  Text
    This routine initializes the WeylAlgebra with respect to the weight vector w.
    If no weight is given it supposes the standard elimination order corresponding to weight {0..0,1..1}.
  Example
    makeWA(QQ[x,y],{0,0,2,1})
Caveat

SeeAlso

///

doc ///
Key
    rationalWeylAlgebra
    (rationalWeylAlgebra, PolynomialRing)
Headline
    initialize the rational WeylAlgebra from a given WeylAlgebra
Usage
    rationalWeylAlgebra(R)
Inputs
    R:PolynomialRing
        over the rationals
Outputs
    rationalWeylAlgebra:PolynomialRing
        over the fraction field of the variables of the WeylAlgebra
Description
  Text
    This routine initializes the rational WeylAlgebra with respect to the weight vector w.
  Example
    D = makeWeylAlgebra(QQ[x,y],{0,0,2,1})
    rationalWeylAlgebra(D)
Caveat

SeeAlso

///

doc ///
Key
    normalForm
    (normalForm, RingElement, RingElement)
    (normalForm, RingElement, List)
Headline
    computes normal form of an element wrt to a Groebner basis
Usage
    normalForm(f,g)
    normalForm(f,G)
Inputs
    f:RingElement
        in the Weyl algebra
    g:RingElement
        in the Weyl algebra
    G:List
        of elements in the Weyl algbra
Outputs
    normalForm:RingElement
        reduced form with respect to a list of elements in the Weyl algebra
Description
  Text
    This method computes the normal form of an elment f in the Weyl algebra D with repsect to another element in the Weyl algebra or a whole list of such elements.
    Usually this list is a Groebner basis for an left D-ideal.
  Example
    w = {0,0,1,1}
    D = makeWA(QQ[x,y],w)
    f = dx^2
    g = x*dx+1
    normalForm(f, g)   
Caveat

SeeAlso

///