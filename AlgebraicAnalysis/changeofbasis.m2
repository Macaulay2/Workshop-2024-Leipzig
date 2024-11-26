diffW=method();
diffW(RingElement,RingElement) :=(P,f)->(
DR := ring P;
R := ring f;
createDpairs DR;
partials := ideal( DR.dpairVars_1);
sub((P*sub(f,DR)) % partials,R)
)
