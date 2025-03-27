# Future work on the ConnectionMatrices.m2 package

## General

- Employ other kind of elimination orders (not just refinements of (0,v) )
- For methods taking a *D*-ideal, we should ensure that the Weyl algebra actually has been provided with an elimination order.

## Method Specific

### gaugeMatrix

- Do we really need an implementation *gaugeMatrix(List,List)* which takes the first list and generates its ideal?

### holonomicRank

- Instead of calling *holonomicRank(w,I)*, we should be just carrying over the (and ensure that it is) elmination order from *ring(D)*.