restart
load "contraction.m2"

kk = ZZ/101
n = 3
E = kk[e_0..e_n, SkewCommutative=>true]
contractionMatrix(3,random(2,E))

St = kk[a_0..a_3,b_0..b_3]
Univ = St^{2:-1}
WW = St^(n+1)


a = random(1,E)
UtildeSingleElement = (i,j,a) -> (
    contMat := contractionMatrix(i,j,a);
    return map(exteriorPower(j,WW),exteriorPower(i,WW), sub(contMat,St));
)
Utilde = A -> (
    UAlist := for col to numcols A - 1 list (
        i := (degrees source A)#col#0; -- Justify the +1 :D
        for row to numrows A - 1 list (
            a := A_(row,col);
            j := (degrees target A)#row#0;
            print(i, j, degree a);
            UtildeSingleElement(i,j,a)
        )
    );
    return matrix transpose UAlist;
)
Utilde A

needsPackage "BGG"

S = QQ[x_0..x_3];
E = QQ[e_0..e_3, SkewCommutative => true];

m = matrix {{x_1,x_2,x_3,0,0,0},{-x_0,-x_1,-x_2,x_1,x_2,x_3},{0,0,0,-x_0,-x_1,-x_2}}

T = tateResolution(m,E,-1,2)
A = T.dd_3
Utilde A