needsPackage "Resultants"

S = QQ[x_0..x_3]

Hankel = matrix{{x_0,x_1,x_2},{x_1,x_2,x_3}}
I = minors(2,Hankel)

C = dualize chowForm I

use ring C

E = matrix{{x_(0,1),x_(0,2),        x_(0,3)},
           {x_(0,2),x_(0,3)+x_(1,2),x_(1,3)},
           {x_(0,3),x_(1,3),        x_(2,3)}}

C' = det E

ideal C == ideal C'