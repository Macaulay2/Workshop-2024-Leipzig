needsPackage "Resultants"

f = veronese(1,3)
V = kernel f

c = dualize chowForm(V)
R = ring c

d = det matrix {{x_(0,1),x_(0,2),x_(0,3)},{x_(0,2),x_(0,3)+x_(1,2),x_(1,3)},{x_(0,3),x_(1,3),x_(2,3)}}

c == d

--------------------------------------------------------------------------
restart
needsPackage "BGG"

S = QQ[x_0..x_3];
E = QQ[e_0..e_3, SkewCommutative => true];

m = matrix {{x_1,x_2,x_3,0,0,0},{-x_0,-x_1,-x_2,x_1,x_2,x_3},{0,0,0,-x_0,-x_1,-x_2}}

T = tateResolution(m,E,-2,4)
T.dd_5


