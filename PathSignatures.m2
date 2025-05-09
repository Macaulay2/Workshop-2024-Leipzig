newPackage("PathSignatures",
         Version => "1.0",
         Authors => {{Name => "Felix Lotter", HomePage => "https://felixlotter.gitlab.io"}, {Name => "Oriol Reig"}, {Name => "Angelo El Saliby"}, {Name => "Carlos Amendola"}},
         Headline => "A package for working with signatures of algebraic paths",
         AuxiliaryFiles => true,
         PackageExports => {"NCAlgebra", "Permutations"}
);
export {
    --types
    "Path",
    --methods
    "sig",
    "polyPath",
    "linPath",
    "pwLinPath",
    "concatPath",
    "matrixAction",
    "CAxisTensor",
    "CMonTensor",
    "tensorParametrization",
    "wordAlgebra",
    "signedVolumeForm",
    "shuffle",
    "halfshuffle",
    "wordFormat",
    "wordString",
    "getDimension",
    "getPieces",
    "getCoefficientRing",
    "getNumberOfPieces",
    -- symbols
    "adjointWord",
    "tensorArray",
    "inner",
    "lyndonWords",
    "lie",
    "lieBasis",
    "tensorExp",
    "lyndonShuffle"
    -- "type",
    -- "pieces",
    -- "dimension",
    -- "numberOfPieces",
    -- "bR"
};

exportFrom("NCAlgebra",{"NCRingElement", "NCPolynomialRing"})

--------------------------------------------
--Include interface for NCAlgebra
load "./PathSignatures/interfaceNCAlgebra.m2"

--Include tensor algebra
load "./PathSignatures/algebra.m2"

--Include types
load "./PathSignatures/types.m2"

--Include signatures
load "./PathSignatures/signatures.m2"

--Include documentation
load "./PathSignatures/documentation.m2"
--------------------------------------------

----------------------------------------------------
--Landing page and case use documentation
----------------------------------------------------
beginDocumentation()
 doc ///
 Node
    Key
        PathSignatures
    Headline
        a package for working with signatures of algebraic paths
    Description
        Text
            {\em PathSignatures} is a package for studying the signature of piecewise polynomial paths.
        Text
            The package heavily simplifies the process of obtaining data related to signature varieties, e.g. as in @HREF("#ref1","[1]")@. See @TO "Computing Path Varieties"@.
        Text
            A polynomial path is a path $X: [0,1] \to \mathbb R^d$ whose coordinate functions are given by polynomials. A piecewise polynomial path is a path $X: [0,1] \to \mathbb R^d$ which is polynomial on each interval in a partition of $[0,1]$.
        Text
            Given such a path $X$, its signature is the linear form $\sigma: T((\mathbb{R}^d)^*)\rightarrow \mathbb{R}$ on the tensor algebra of the dual of 
            $\mathbb{R}^d$, whose image on a decomposable tensor $\alpha_1\otimes \dots\otimes \alpha_k$ is the iterated integral $$
            \alpha_1\otimes \dots\otimes \alpha_k\overset{\sigma}{\mapsto} \int_0^1\int_0^{t_k}\dots\int_0^{t_2}\partial(\alpha_1 X)\dots \partial (\alpha_k X) d t_1\dots dt_k.
            $$
            This form is invariant under translation, reparametrization and tree-like equivalence of $X$ and characterizes $X$ uniquely up to these relations.
        Text
            In this package, we identify $T((\mathbb{R}^d)^*)$ with the free associative algebra over the alphabet $\{\texttt{1},\dots,\texttt{d}\}$ via $\texttt{i} \mapsto e_i^*$ where $e_1^*, \dots, e_d^*$ is the dual of the canonical basis of $\mathbb{R}^d$. For example, the word $\texttt{12}$ corresponds to $e_1^* \otimes e_2^*$.
        Text
            It is easy to create a polynomial path:
        Example
            R = QQ[t];
            X = polyPath({t + t^2, t^3})
        Text
            A piecewise polynomial path is obtained by concatenating polynomial paths:
        Example
            Y = X ** X
        Text
            Any @TO2 {"NCAlgebra::NCPolynomialRing", "NCPolynomialRing"}@ can serve as a tensor algebra. Use @TO wordAlgebra@ to quickly create one in variables $\texttt{Lt}_i$. The package introduces a convenient notation for words in this algebra.
        Example
            A2 = wordAlgebra(2)
            [1,2]_A2 -- the word 12.
        Text
            To evaluate the signature of $\mathtt{X}$ at a tensor $\mathtt{w}$, use @TO sig@. The following computes the @ITALIC "signed volume"@ of the path; also see @TO signedVolumeForm@.
        Example
            sig(X,[1,2]_A2-[2,1]_A2)
        Text
            @TO sig@ can also be used to obtain the @ITALIC "$k$-th level signature tensor"@. Use @TO wordFormat@ or @TO tensorArray@ to display the tensor in a nicer way.
        Example
            T = sig(X,2)
            T // wordFormat
            T // tensorArray
        Text
            The package allows for the computation of signatures for parametrized families of paths.
        Example
            S = QQ[a,b,c]
            R = S[t]
            X = polyPath({a*t+b*t^2,c*t^3})
            Y = X ** X
            sig(X, signedVolumeForm(A2))
    References
        @LABEL("[1]","id" => "ref1")@ Carlos Améndola, Peter Friz and Bernd Sturmfels, {\em Varieties Of Signature Tensors}, Forum of Mathematics, Sigma. 2019;7:e10. doi:10.1017/fms.2019.3"
            
           
Node
    Key
        "Computing Path Varieties"
    Description
        Text
            @TO PathSignatures@ simplifies the computation of varieties coming from signature tensors. We showcase this in a number of examples:
    Subnodes
        "Polynomial paths of degree d"
        "A family of paths on a cone"

Node
    Key
        "Polynomial paths of degree d"
    Description
        Text
            We reproduce a computation from @HREF("#ref1","[1]")@.
            We briefly recall the setting for this computation. We are interested in paths $X:[0,1]\rightarrow \mathbb{R}^\mathtt{d}$ whose coordinates are polynomials of degree $\mathtt{m}$. These can be 
            represented by a $\mathtt{d}\times \mathtt{m}$ matrix with real entries whose coordinates are determined by the expressions 
            $$ X_i(t) = x_{i,1}t+x_{i,2}t^2+\dots+ x_{i,m}t^m$$
            When we restrict to the $\mathtt{k}$-th level signature of $X$, $\sigma:= \sigma^{(\mathtt{k})}(X)$, each of its coordinates $\sigma_{i_1, \dots, i_{\mathtt{k}}}$ is a homogeneous 
            polynomial of degree $\mathtt{k}$ in the $\mathtt{d}\cdot \mathtt{m}$ unknowns $x_{i,j}$ corresponding to the matrix representation of the path $X$. Let $\mathtt{CMon}$ be the canonical monomial path
            in $\mathbb{R}^{\mathtt{m}}$ introduced in @TO CMonTensor@. Then $\sigma$ can be computed through the @TO matrixAction@ of $X$ on $\sigma^{(k)}(\mathtt{CMon})$.
            Moreover, we can view the entries of $X$ as coordinates in the projective space $\mathbb{P}^{\mathtt{d}\cdot \mathtt{m}-1}$ over some algebraically closed field $\mathbb{K}$ containing 
            $\mathbb{R}$. Then the matrix action just described gives rise to a rational map $$
            \sigma^{(\mathtt{k})}:\mathbb{P}^{\mathtt{d}\cdot \mathtt{m}-1}\rightarrow \mathbb{P}^{\mathtt{d}^{\mathtt{k}}-1}$$
            determined by $X\mapsto \sigma^{(\mathtt{k})}(X)$, of degree $\mathtt{k}$. The {\em polynomial signature variety}, denoted $\mathcal{P}_{\mathtt{d},\mathtt{k},\mathtt{m}}$, is then defined to be 
            the Zariski closure of the image of this map (informally, the closure of the space of all tensors of order $\mathtt{k}$ that arise as signatures of paths of the specified type), while its homogeneous prime ideal is called 
            {\em polynomial signature ideal} and denoted $P_{{\mathtt{d},\mathtt{k},\mathtt{m}}}$.
        Text
            We set up the procedure to compute the ideal $P_{\mathtt{d},\mathtt{k},\mathtt{m}}$.
        Example
            d = 2; k = 3; m = 2;
        Text
            We create a ring $\mathtt{R}$ with $\mathtt{d}\cdot\mathtt{m}$ variables, corresponding to the entries of a path. Then we create the free algebra $\mathtt{A}$ over $\mathtt{R}$ with $\mathtt{m}$ generators, where we can compute the $\mathtt{k}$-th level signature of the canonical monomial path in $\mathbb{R}^{\mathtt{m}}$.
        Example
            R = CC[x_1..x_(d*m)]; --x_1, ..., x_(d*m) are the entries of the degree m paths in d-dimensinal space, seen as matrices
            A = wordAlgebra(m, CoefficientRing => R); --Signatures in m-dimesnional space, where the signature of CMon lives.
            sigmaCMon = CMonTensor(k, A); sigmaCMon // wordFormat -- The 2nd level signature of CMon
        Text
            Next we create the @TO genericMatrix@ with $\mathtt{d}\times \mathtt{m}$ variables.
        Example
            M = genericMatrix (R, d, m)
        Text
            Finally we compute the matrix action on $\sigma^{(k)}(\mathtt{CMon})$ with @TO (symbol *, Matrix, NCRingElement)@, and then compute the corresponding map on rings using @TO tensorParametrization@.
        Example 
            f = M * sigmaCMon; 
            sigVarietyParam = tensorParametrization(f, CoefficientRing => CC);
        Text
            Now that we have the map, any tool for implicitization can be used. We compute its dimension and degree with @TO2 {"NumericalImplicitization::NumericalImplicitization", "NumericalImplicitization"}@.
        Example
            needsPackage "NumericalImplicitization";
            numericalImageDim(sigVarietyParam,ideal 0_R) 
            numericalImageDegree(sigVarietyParam,ideal 0_R, Verbose => false) 
        Text
            This agrees with the result in Table 3 of @HREF("#ref1","[1]")@, where dimension and degree of the corresponding projective variety is computed.
    References
        @LABEL("[1]","id" => "ref1")@ Carlos Améndola, Peter Friz and Bernd Sturmfels, {\em Varieties Of Signature Tensors}, Forum of Mathematics, Sigma. 2019;7:e10. doi:10.1017/fms.2019.3"

Node
    Key
        "A family of paths on a cone"
    Description
        Text
            We consider the following family of polynomial paths of degree 4:
        Example
            S = QQ[a_1..a_6]
            R = S[t]
            u = a_1*t + a_2*t^2 + a_3*t^3;
            v = a_4*t + a_5*t^2 + a_6*t^3;
            X = polyPath({u^2 - v^2, 2*u*v, u^2 + v^2});
        Text
            Let us take a look at its signature matrix variety. We obtain its parametrization as follows:
        Example
            sigMatrix = sig(X,2);
            m = tensorParametrization(sigMatrix);
        Text
            Let us use numericalImplicitization to obtain information about the dimension of the image.
        Example
            needsPackage "NumericalImplicitization";
            Snum = CC[a_1..a_6];
            Rnum = Snum[t];
            unum = sub(u, Rnum);
            vnum = sub(v, Rnum);
            Xnum = polyPath({unum^2 - vnum^2, 2*unum*vnum, unum^2 + vnum^2});
            sigMatrixnum = sig(Xnum,2);
            mnum = tensorParametrization(sigMatrixnum,CoefficientRing => CC);
            numericalImageDim(mnum,ideal 0_Snum)
        Text
            The universal variety has dimension 6, so we expect at least one additional relation. We use MultigradedImplicitization:
        Example
            needsPackage "MultigradedImplicitization";
            I = ideal flatten values componentsOfKernel(2, m, Grading => matrix {toList(9:1)});
            dim I
            isPrime I
            betti mingens I
            degree I
        Text
            We conclude that our variety is cut out by one linear relation and 6 quadrics. Let us take a look at the linear relation:
        Example
            lin = select(flatten entries gens I, i-> (degree i == {1}))
        Text
            We recognize it as a shuffle polynomial in the letters $\mathtt{1},\mathtt{2},\mathtt{3}$. It corresponds to the constraint $X(1) - X(0) \in V(x^2 + y^2 - z^2)$ for paths in our family.
        Text
            Recall that the universal variety is cut out by the 2-minors of the symmetric part of the matrix. We check if the linear relation is the only additional one on our path family:
        Example
            Q = ring I;
            A = matrix {{Q_7, Q_8, Q_6}, {Q_4, Q_1, Q_0}, {Q_3,Q_2, Q_5}}
            univI = minors(2, A + transpose(A));
            I == univI + ideal lin

        
///


endPackage;












