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
            An example for the use of the package is to obtain data such as the one in Table 3 of the paper: Carlos Améndola, Peter Friz and Bernd Sturmfels, 
            {\em Varieties of signatures tensors}, Forum of Mathematics, Sigma. 2019;7:e10. doi:10.1017/fms.2019.3
        Text
            We briefly recall the setting for those computations. We are interested in paths $X:[0,1]\rightarrow \mathbb{R}^\mathtt{d}$ whose coordinates are polynomials of degree $\mathtt{m}$. These can be 
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
            Now that we have the map, any tool for implicitization can be used. We compute its dimension with @HREF {"https://macaulay2.com/doc/Macaulay2/share/doc/Macaulay2/NumericalImplicitization/html/index.html", "NumericalImplicitization"}@.
        Example
            needsPackage "NumericalImplicitization";
            numericalImageDim(sigVarietyParam,ideal 0_R) 
        Text
            In the table the projective dimension is indicated, so the results coincide.
Node
    Key
        Path
        (symbol _, Path, List)
        (symbol _, Path, ZZ)
        (symbol _, Path, Sequence)
        (symbol ^, Path, ZZ)
        (getDimension, Path)
        getDimension
        (dim, Path)
        (getNumberOfPieces, Path)
        getNumberOfPieces
        (getPieces, Path)
        getPieces
        (getCoefficientRing, Path)
        getCoefficientRing
        (coefficientRing, Path)
        (net, Path)
    Description
        Text
            A polynomial path is a map $[0,1] \to \mathbb R^d$ whose coordinate functions are given by polynomials. A piecewise polynomial path is a concatenation of polynomial paths.
        Text
            To create a polynomial path, use @TO polyPath@, which takes a list of polynomials as input. These can be given as elements of a commutative polynomial ring with one generator or directly in @TO2 {"Macaulay2Doc :: listForm", "listForm"}@.
        Example
            R = QQ[t];
            X = polyPath({t,2*t^2,3*t^3})
            Y = polyPath({{({1},1)},{({2},2)},{({3},3)}})
        Text
            While the polynomials must be chosen from a polynomial ring with one generator, the coefficient ring of the polynomials can be chosen arbitrarily.
        Example
            R = QQ[a][t]; --QQ[a,t] will not work!
            X = polyPath({t,2*a*t^2,3*a^2*t^3})
        Text
            An important special case of polynomial paths are linear paths. These can be constructed directly from their increment using @TO linPath@.
        Example
            Y = linPath({2,3,4})
        Text
            Paths can be concatenated using @TO (symbol **, Path, Path)@. This concatenation is formal: the new Path object encodes the polynomial pieces and their order, but no parametrization is chosen. The concatenation @TO (symbol **, Path, Path)@ will automatically select a bigger coefficient ring for all polynomial pieces if an obvious choice is available.
        Example
            Z = X ** Y
        Text
            A piecewise linear path can be constructed directly from the increments of its segments using @TO pwLinPath@.
        Example
            A = matrix {{1,2,3},{2,3,4},{4,5,6}};
            W = pwLinPath(A)
        Text
            To read out the ambient dimension of a path, use @TO (getDimension, Path)@ or @TO (dim, Path)@. To get the pieces of the path in @TO2 {"Macaulay2Doc :: listForm", "listForm"}@ use @TO (getPieces, Path)@. To get the coefficient ring of the coordinate polynomials, use @TO (getCoefficientRing, Path)@ or @TO (coefficientRing, Path)@. Finally, @TO (getNumberOfPieces, Path)@ returns the number of pieces of the path.
        Example
            getDimension(Z) --The ambient dimension of the path
            getPieces(Z) --The polynomial pieces of the path, in listForm
            getCoefficientRing(Z) -- The coefficient ring of the polynomial components of the path
            getNumberOfPieces(Z) -- The number of polynomial pieces of the path
        Text
            To extract the pieces of a concatenated path one can use @TO (symbol _, Path, ZZ)@, @TO (symbol _, Path, List)@ and @TO (symbol _, Path, Sequence)@.
        Example
            Z_0
            Z2 = Z^2
            Z2_{0,-1}
        Text
            When considering the set of paths modulo tree-like equivalence, concatenation turns it into a groupoid. Use @TO (symbol ^, Path, ZZ)@ to compute powers and the inverse of a path in this groupoid. Note that the inverse of a path is just given by reversing its parametrization.
        Example
            X^4
            X^(-1)

    SeeAlso
        polyPath
        linPath

Node 
    Key
        (symbol **, Path, Path)
    Headline
        concatenation of paths
    Usage 
        X**Y
    Description
        Text
            This allows for concatenation of paths. The concatenation is formal, no parametrization is chosen.
        Example
            R = QQ[t];
            X = polyPath({t,t^2}) ** polyPath({t^3 + 3*t, t^2 - 1})
    SeeAlso
        polyPath
        linPath
Node
    Key
        (substitute,Path, Ring)
    Headline
        changes the coefficient ring of a path
    Usage
        Y = substitute(X,R)
    Inputs
        X: Path
        R: Ring -- an algebra over the coefficient ring of the polynomials defining X
    Outputs
        Y: Path -- a path with the same pieces as X but whose coordinate functions are now polynomials with coefficients in R
    Description
        Text
            Tries to substitute the coefficients of the polynomials defining the given path into the given ring, producing a new path.
        Example
            R = QQ[t];
            X = polyPath({t,t^2})
            coefficientRing X
            A = QQ[a];
            Y = substitute(X,A)
            coefficientRing Y
Node
    Key
        polyPath
        (polyPath,List)
    Headline
        constructor of single piece polynomial path
    Usage
        polyPath(polyPathList)
    Inputs
        polyPathList: List --A list of elements of the same ring, the components of the polynomial path.
    Outputs
        X: Path
    Description
        Text
            Takes as input a list of polynomials in the same ring. Constructs a @TO Path@ object with one piece equal to the list of normalForm 
            of the polynomial components of the path given in input. Automatically sets the dimension attribute of the
            object to the lenght of the list given as input.
        Example
            R = QQ[t];
            X = polyPath({t,t^2})
            X // getDimension 
    SeeAlso
        Path
        linPath
        (symbol **, Path, Path)

Node 
    Key
        linPath
        (linPath, List)
    Headline
        constructor of single piece polynomial path
    Usage
        linPath(v)
    Inputs
        v: List -- A list of elements of a ring, the endpoints of the linear path.
    Outputs
        X: Path
    Description
        Text
            Takes as input a list of elements in the same ring. Constructs a @TO Path@ object with one piece equal to the list given in input. Automatically sets the dimension attribute of the
            object to the lenght of the list given as input.
        Example
            R = QQ[x_1..x_5];
            X = linPath({x_1, x_2, x_3, x_4, x_5^2})
            X // getDimension
    SeeAlso
        Path
        polyPath
        (symbol **, Path, Path)
Node
    Key
        sig
        (sig, Path, List)
        (sig, Path, NCRingElement)
        (sig, Path, ZZ)
        (sig, Path, ZZ, NCRing)
    Headline
        compute the signature of a piecewise polynomial path.
    Description
        Text
            Given a path $X(t):[0,1]\rightarrow \mathbb{R}^d$, its signature is the linear form $\sigma: T((\mathbb{R}^d)^*)\rightarrow \mathbb{R}$ on the tensor algebra of the dual of 
            $\mathbb{R}^d$, whose image on a decomposable tensor $\alpha_1\otimes \dots\otimes \alpha_k$ is the iterated integral $$
            \alpha_1\otimes \dots\otimes \alpha_k\overset{\sigma}{\mapsto} \int_0^1\int_0^{t_k}\dots\int_0^{t_2}\partial(\alpha_1 X)\dots \partial (\alpha_k X) d t_1\dots dt_k
            $$
            In this package the easiest way to represent an element of $T((\mathbb{R}^d)^*)$ is by constructing a non commutative algebra over $d$ symbols
        Example
            d = 4;
            R = QQ[t];
            X = polyPath(for i from 1 to d list t^i) -- the moment path in dimension d
            A = wordAlgebra(d) -- create the free associative algebra over d letters
            w = (new Array from (1..d))_A -- the word 1..d
        Text
            The word $w$ corresponds to the decomposable tensor $e_1^*\otimes\dots  \otimes e_d^*$, where $e_1^*, \dots, e_d^*$ is the dual of the canonical basis of $\mathbb{R}^d$. 
            The signature of $X$ on this word can be computed using @TO (sig, Path, NCRingElement)@.
        Example 
            sig(X, w)
            sig(X,[1]_A)
            sig(X,[2,3]_A)
        Text
            One can also compute the {\em k-th level} signature tensor for $k\in \mathbb{N}$ by using @TO (sig, Path, ZZ)@. This returns the tensor as a non-commutative polynomial in symbols Lt_1, ..., Lt_d.
        Example
            T = sig(X, 2)
            T // wordFormat
        Text
            Note however that neither the symbols nor the ring of this polynomial are made available to the user, in particular they can not be added or multiplied. To obtain the tensor as a NCPolynomial in a given NCRing, use @TO (sig, Path, ZZ,  NCRing)@ instead. The following example demonstrates Chen's identity:
        Example
            T = 1 + sig(X, 1, A) + sig(X, 2, A);
            S = T * T;
            Ma = matrix (S@2) -- the second component of S as a matrix
            Y = X ** X -- X concatenated with itself
            Mb = matrix (sig(Y, 2, A)@2) -- the signature matrix of Y
            (Ma == Mb)

Node 
    Key
        pwLinPath
        (pwLinPath,Matrix)
    Headline
        constructor of a piecewise linear path from a matrix
    Inputs
        pwlMatrix: Matrix -- A matrix containing on its columns the articulation points (or increments) of the path
    Outputs
        X: Path --A piecewise linear path of dimension the number of rows of the input and with the same number of pieces as the columns of the input
    Usage
        pwLinPath(pwlMatrix)
    Description
        Text
            Creates a piecewise lienar @TO Path@ whose increments are the columns of the given matrix.
        Example
            M = id_(QQ^3)
            pwLinPath(M)
    SeeAlso
        Path

Node
    Key
        adjointWord
        (adjointWord, NCRingElement, NCPolynomialRing, List)
    Headline
        image of a word through the shuffle algebras homomorphism induced by a polynomial map 
    Inputs 
        g : NCRingElement --The word to compute the image of
        T : NCPolynomialRing --The shuffle algebra of the image
        L : List -- The components of the polynomial map. Each entry should be a polynomial
    Usage
        adjointWord (g, T, L)
    Description
        Text
            This computes the image of g through the map $M_p$ described in Theorem 1 and Theorem 7 of the paper: Laura Colmenarejo and Rosa Preiß, {\em Signatures of
             paths transformed by polynomial maps}, Beitr Algebra Geom 61, 695–717 (2020). https://doi.org/10.1007/s13366-020-00493-9. Its importance is evidenced by
            Theorem 2 of the same paper: 
        Text
            Let $X:[0,1]\rightarrow \mathbb{R}^d$ be a piecewise continuously differentiable path
            with $X(0) = 0$ and let $p : \mathbb{R}^n \rightarrow \mathbb{R}^m$ be a polynomial map with $p(0) = 0$. Then, for
            all $w ∈ T(\mathbb{R}^m)$ one has $$  \sigma(p(X)) = M_p^*(\sigma(X))$$
            (where $\sigma(X)$ is the signature of $X$ and $M_p^*$ is the dual map of $M_p$).
        Text 
            As a use example, we verify this in a particular case. First we define a transformation of affine spaces and create the word algebra
            where our tensors live
        Example
            S = QQ[x,y]; 
            p = {x^2,x*y,y^2} -- A map of affine spaces, the degree 2 Veronese morphism R^2 -> R^3

            wA2 = wordAlgebra(2); -- signatures of paths in dimension 2 
            wA3 = wordAlgebra(3); -- signatures of paths in dimension 3
        Text
            Then we define a path in the domain space and explicitely compute it's image through the above polynomial map
        Example
            R = QQ[t];
            X = polyPath({t,t^2}) -- A path in 2 dimensional space
            PP = apply(p, q -> sub(q, {x=>t, y=>t^2})); 
            Y = polyPath(PP) -- the transformed path in 3 dimensional space
        Text
            Finally we compute the signature of the transformed path along the @TO signedVolume@ tensor of $\mathbb{R}^3$ and verify the formula in Theorem 2 above
        Example
            vol = signedVolume(wA3); vol // wordFormat -- consider the signed volume in R^3 and display it in word format
            adw = adjointWord(vol, wA2, p); adw // wordFormat -- we compute its image through the induced homomorphism on algebras
            sig(Y, vol)  -- the signed volume of the transformed path
            sig(X, adw)  -- is given by evaluating at adw for the original path.

    References
        @HREF {"https://doi.org/10.1007/s13366-020-00493-9","Signatures of paths transformed by polynomial maps (doi.org/10.1007/s13366-020-00493-9)"} @
Node
    Key
        shuffle
        (symbol **, NCRingElement, NCRingElement)
        (shuffle, NCRingElement, NCRingElement)
    Headline
        shuffle product of two words
    Inputs
        w1: NCRingElement 
        w2: NCRingElement
        R: NCPolynomialRing --The non-commutative polynomial where the operation ought to be carried out
    Outputs
        v: NCRingElement --The shuffle product of w1 and w2
    Usage
        v = shuffle(w1, w2, R)
    Description
        Text
            We start with the mathematical definition of this operation, based on the reference. 
            Consider $T(\mathbb{R}^d)$, the free algebra on the symbols $1,\dots, d$. Denote 
            by $\bullet$ its concatenation product and by $e$ the neutral element with respect to the concatenation (the empty word). The shuffle product of two words is defined 
            recursively as follows. Let $w, w_1, w_2$ be three words and $a, b$ bet two letters, i.e.
            $w, w_1, w_2\in T(\mathbb{R}^d)$ and $a,b\in \{1,\dots, d\}$. Then the shuffle product $\char"29E2$ is defined to be
            $$ e \char"29E2 w := w =: w\char"29E2 e$$
            and 
            $$(w_1\bullet a) \char"29E2 (w_2\bullet b) = (w_1 \char"29E2 (w_2\bullet b))\bullet a + ((w_1\bullet a)\char"29E2 w_2)\bullet b$$
        Text
            The easiest way to compute a shuffle product is through @TO (symbol **, NCRingElement, NCRingElement)@ which is equivalent to @TO (shuffle, NCRingElement, NCRingElement)@:
        Example
            R = wordAlgebra(2); -- create a free associative algebra over two letters Lt_1, Lt_2
            f = [1,2]_R; -- [i_1,...,i_k]_R defines a word
            wordFormat f -- display the polynomial in word notation
            f = ([1,2]_R ** [1,2]_R); -- compute the shuffle product
            f // wordFormat --display the result in word notation
    References
        @HREF {"https://doi.org/10.1007/s13366-020-00493-9","Signatures of paths transformed by polynomial maps (doi.org/10.1007/s13366-020-00493-9)"} @
    SeeAlso
        wordAlgebra
        wordFormat
        (symbol _, Array, NCPolynomialRing)
-- Node 
--     Key
--     Inputs
--         z: ZZ -- The number of variables in the algebra, usually the ambient dimension of the path
--         CoefficientRing => Ring -- The coefficients ring, by default the rationals.
--     Outputs
--         A: NCRing --The associative free polynomial algebra on the letters LT_1, ..., Lt_z
--     Headline
--         create a free associative algebra on a given number of generators
--     Usage
--         wordAlgebra(z)
--     Description
--         Text
--             Creates the free associative polynomial algebra on the letters Lt_1,$ \dots$, Lt_z.
--         Example
--             z = 5;
--             A = wordAlgebra(z)
--             gens A
--     SeeAlso
--         wordAlgebra
Node
    Key
        wordAlgebra
        (wordAlgebra, ZZ)
        (wordAlgebra, List)
        NCRingElement
        NCPolynomialRing
    Headline
        create a free algebra over a given alphabet
    Description
        Text
            In this package, tensors are represented as elements of free associative algebras, using the package @TO2 {"NCAlgebra :: NCAlgebra", "NCAlgebra"}@.
            More precisely, the free associative algebra on the alphabet $\{\texttt 1,...,\texttt d\}$ is isomorphic to the tensor algebra $T(\mathbb R^d)$ via the algebra homomorphism induced by $\texttt i \mapsto e_i$. This allows us to interpret tensors as non-commutative polynomials, or equivalently, linear combinations of words.
            Given an alphabet $l$, the free assocative algebra over it can be obtained by using @TO wordAlgebra@, where the letter corresponding to $x \in l$ is represented by $\texttt{Lt}_x$.
        Example
            d = 5;
            l1 = {getSymbol "a", getSymbol "b", getSymbol "c"};
            A = wordAlgebra(l1)
            gens A

            l2 = toList(1..d);
            B = wordAlgebra(l2)
            gens B
        Text
            The algebra B in the example can also be directly obtained for a given d using @TO (wordAlgebra, ZZ)@:
        Example
            B = wordAlgebra(d);
            gens B
        Text
            By default, @TO wordAlgebra@ creates a non-commutative algebra over @TO2{"Macaulay2Doc :: QQ", "QQ"}@. The coefficient ring can be changed via the CoefficientRing option:
        Example
            coefficientRing B
            C = wordAlgebra(d, CoefficientRing => CC)
            coefficientRing C
        Text
            An element of the algebra can be obtained by using the generator symbols, or (more conveniently) by using word notation, see @TO (symbol _, Array, NCPolynomialRing)@:
        Example
            d = 5;
            R = wordAlgebra(d); -- create a free associative algebra over two letters Lt_1, Lt_2
            f = 2 * [1,d]_R - [2,d]_R  -- [i_1,...,i_k]_R defines a word.
            f === 2 * Lt_1 * Lt_d - Lt_2 * Lt_d
        Text
            Note that for two words (equivalently, monomials) $\texttt{w}$ and $\texttt{v}$, $\texttt{w} * \texttt{v}$ is the concatenation.
        Text
            To display a non-commutative polynomial in word notation, one can use @TO wordFormat@ or @TO wordString@:
        Example
            f^3 // wordFormat
            f^3 // wordString
        Text
            There are more interesting algebraic structures on non-associative algebras; of particular importance in the context of path signatures is the shuffle product and the half-shuffle product:
        Example
            a = [1]_R ** [2]_R; wordFormat a -- the shuffle product
            b = [1,2]_R ** [3,4]_R; wordFormat b
            c = [1]_R >> [2,3]_R; wordFormat c -- the half-shuffle product
        Text
            See @TO (symbol **, NCRingElement, NCRingElement)@ and @TO (symbol >>, NCRingElement, NCRingElement)@ for more information on the shuffle and half-shuffle product.
    SeeAlso
        (symbol _, Array, NCPolynomialRing)

Node
    Key
        (symbol _, Array, NCPolynomialRing)
    Inputs
        a : Array -- In the form [i_1,...i_k] where 0 < i_j< d+1, where d is the number of generators of R
        R : NCPolynomialRing 
    Outputs
        w: NCRingElement -- The element of R corresponding to R_(i_1)*...R_(i_k)
    Headline
        create a word from an array
    Usage
        w = a_R
    Description
        Text
            This method allows to create a monomial in a free associative algebra $R$. It follows the same 
            convention of @TO wordFormat@. Let $Lt_1,\dots, Lt_d$ be the generators of $R$, then an array of 
            integers $[i_1,\dots, i_k]$ such that $0<i_l<d+1, \forall 1\leq l\leq k$ yields the element 
            $$Lt_{i_1} Lt_{i_2}\cdot\dots\cdot Lt_{i_{k-1}} Lt_{i_k}$$
            of $R$.
        Example
            d = 5;
            R = wordAlgebra(d); -- create a free associative algebra over Lt_1,..., Lt_d
            a = new Array from for i from 1 to 5 list i; -- The array [1,...,d]
            f = a_R  -- The word associated to a
            g = product gens R -- The word Lt_1*...Lt_d
            f === product gens R
    SeeAlso
        wordAlgebra
        wordFormat
Node 
    Key 
        wordFormat
        (wordFormat, NCRingElement)
    Headline
        display a tensor in word notation
    Description
        Text
            A more readable display of tensors can be obtained through the following convention. Let $Lt_1,\dots, Lt_d$ be the generators of $R$, then an array of 
            integers $[i_1,\dots, i_k]$ such that $0<i_l<d+1, \forall 1\leq l\leq k$ yields the decomposable tensor
            $$Lt_{i_1} Lt_{i_2}\cdot\dots\cdot Lt_{i_{k-1}} Lt_{i_k}$$
            of $R$. This notation can then be extended linearly to any tensor.
        Example
            R = wordAlgebra(2);
            f = ([1,2]_R ** [1,2]_R) -- shuffle product of Lt_1*Lt_1 with itself displayed as a non commutative polynomial
            f // wordFormat -- f displayed in the above notation
    SeeAlso
        wordAlgebra
        (symbol _, Array, NCPolynomialRing)

Node
    Key
        halfshuffle
        (halfshuffle, NCRingElement, NCRingElement)
        (symbol >>, NCRingElement, NCRingElement)
    Headline
        compute the half-shuffle of an ordered pair of words
    Inputs
        f : NCRingElement 
        g : NCRingElement 
    Outputs
        h : NCRingElement -- the half-shuffle f>>g of the two words
    Usage
        h = f >> g
    Description
        Text
            We start on the mathematical definition, based on the reference, where the operation is called {\em right half-shuffle}. Let 
            $T^{\geq 1}(\mathbb{R}^d)$ be the vector space spanned by the non empty words on $d$ letters. Then the half shuffle $>>$ is defined 
            recursively to be $$ w >> i := wi$$ for $w$ a word and $i$ a letter and $$ w >> vi := (w >> v + v >> w)\bullet i$$ for $w, v$ words 
            and $i$ a letter, where $\bullet$ is the contatenation product on words. 
        Text
            As stated in the reference, the @TO shuffle@ on non empty words can be seen as a symmetrization of the half-shuffle. As a usage example, we verify this in a particular instance.
        Example
            R = wordAlgebra(3);
            w = [1]_R
            v = [1,2,3]_R
            s = w ** v --shuffle product of w, v
            hsSymm = (w >> v) + (v >> w)--half-shuffle product symmetrization of w, v
            s == hsSymm


    References
        @HREF {"https://doi.org/10.1007/s13366-020-00493-9","Signatures of paths transformed by polynomial maps (doi.org/10.1007/s13366-020-00493-9)"} @ 
    SeeAlso
        shuffle
        (symbol _, Array, NCPolynomialRing)

Node
    Key
        CAxisTensor
        (CAxisTensor, ZZ, NCPolynomialRing)
    Headline
        the signature tensor of the canonical axis path at a given level
    Inputs
        k : ZZ -- the level of the signature tensor to compute
        R : NCPolynomialRing -- the output tensor space
    Outputs
        s : NCRingElement -- an element of R; the k-th level signature of the canonical axis path in $\mathbb R^d$, where $d$ is the number of generators of R
    Usage
        s = CAxisTensor(k, R)
    Description
        Text
            The {\em canonical axis path} in $\mathbb{R}^d$ is the path from $(0, \dots, 0)$ to $(1, \dots, 1)$ given by $d$ linear steps 
            in the unit directions $e_1, \dots, e_d$, in this order. The $k$-th level signature tensor of such a path has a combinatorial closed-form description (see the reference below) and can be obtained as follows:
        Example
            d = 2;
            k = 3;
            R = wordAlgebra(d);
            Cd = CAxisTensor(k, R); Cd // wordFormat -- k-th level signature of the canonical axis path in R^d
        Text
            To expand on the example, we verify that the result agrees with the one obtained from @TO sig@.
            Notice that the matrix of increments for the canonical axis path in dimension $d$ is 
            the $d \times d$ identity matrix.
        Example
            M = id_(QQ^d); -- identity matrix
            CAxisPath = pwLinPath(M) -- the canonical axis path in dimension d
            Cd2 = sig(CAxisPath, k); Cd2 // wordFormat -- the k-th level signature
    References
        @HREF {"https://doi.org/10.1017/fms.2019.3", "Varieties Of Signature Tensors (doi.org/10.1017/fms.2019.3)"}@

Node
    Key
        CMonTensor
        (CMonTensor, ZZ, NCPolynomialRing)
    Headline
        the signature tensor of the canonical monomial path at a given level
    Inputs
        k : ZZ -- the level of the signature tensor to compute
        R : NCPolynomialRing -- the output tensor space
    Outputs
        s : NCRingElement -- an element of R; the k-th level signature of the canonical monomial path in $\mathbb R^d$, where $d$ is the number of generators of R
    Usage
        s = CAxisTensor(k, R)
    Description
        Text
            The {\em canonical monomial path} in $\mathbb{R}^d$ is the path from $(0, \dots, 0)$ to $(1, \dots, 1)$ given by $t\mapsto (t, t^2, \dots, t^d)$. Its $k$-th level signature has a closed-form description (see the reference below) and can be obtained as follows:
        Example
            d = 2;
            k = 3;
            R = wordAlgebra(d);
            Cd = CMonTensor(k, R); Cd // wordFormat --k-th level signature of the canonical monomial path in R^d
        Text
            To expand on the example, we verify that the result agrees with the one obtained from @TO sig@.
        Example
            R=QQ[t];
            CMonPath = polyPath(for i from 1 to d list t^i) -- The canonical axis path in dimension d
            Cd2 = sig(CMonPath, k); Cd2 // wordFormat --The k-th level signature
    References
        @HREF {"https://doi.org/10.1017/fms.2019.3", "Varieties Of Signature Tensors (doi.org/10.1017/fms.2019.3)"}@

Node 
    Key
        wordString
        (wordString, NCRingElement)
    Headline
        a string representing a word in wordFormat
    Inputs
        w : NCRingElement
    Outputs
        s : String -- A string representing the word 2 in word format
    Usage
        w // wordString
    Description
        Text
            Returns a string representing the word as described in @TO wordFormat@.
        Example
            R = wordAlgebra(3);
            w = [1,2,3]_R + 2 * [3,2,1]_R; w // wordFormat
            w // wordString
    SeeAlso
        wordAlgebra
        wordFormat
        (symbol _, Array, NCPolynomialRing)

Node
    Key
        lie
    Headline
        lie bracket of two elements
    Inputs
        a : NCRingElement
        b : NCRingElement
    Outputs
        c : NCRingElement --The commutator of a, b
    Usage 
        c = lie(a, b)
    Description
        Text
            A non-commutative algebra $(R, +, \cdot)$ is naturally a Lie algebra with the commutator $a\cdot b - b\cdot a$ as the Lie bracket. The commutator of two non-commutative polynomials can be computed as follows:
        Example
            R = wordAlgebra (3);
            a = [1]_R
            b = [2]_R
            lie(a,b)
Node 
    Key
        lieBasis
        (lieBasis, Array, NCPolynomialRing)
        (lieBasis, List, NCPolynomialRing)
    Headline
        basis element corresponding to a Lyndon word in a Lie algebra
    Inputs
        l : Array -- A Lyndon word in @TO wordFormat@ notation
        R : NCPolynomialRing -- The algebra where the output lives
    Outputs
        b : NCRingElement --An element of R
    Usage
        b = lieBasis(l, R)
    Description
        Text
            A word $l$ on the alphabet $\{1,\dots, d\}$ is a {\em Lyndon word} if it is striclty smaller, in lexicographic order, than all of its rotations.
            To any Lyndon word we can associate an iteretaed Lie braketing $b(l)\in T(\mathbb{R}^d)$ defined iteratively as follows. If $l$ is a letter $i\in \{1,\dots, d\}$
            we simply define $$ b(i) := e_i$$
            where as ever $e_i$ is the $i-th$ vector in the canonical basis of $\mathbb{R}^d$. For the lenght of $l$ greater than 1 we define $$
            b(I) := [b(I_1), b(I_2)]$$
            where $I_1, I_2$ are such that their concatenation $I_1 I_2$ is $I$ and $I_2$ is the longest Lyndon word appering as a proper right factor 
            of $I$. 
        Text
            This method computes $b(l)$ for a given Lyndon word. To illustrate its usage, we replicate Example 4.9 of the reference paper.
        Example
            R = wordAlgebra(2);
            lieBasis([1,1,1,2], R) == [1,1,1,2]_R - 3 * [1,1,2,1]_R + 3 * [1,2,1,1]_R - [2,1,1,1]_R
            lieBasis([1,1,2,2], R) == [1,1,2,2]_R - 2 * [1,2,1,2]_R + 2 * [2,1,2,1]_R - [2,2,1,1]_R
            lieBasis([1,2,2,2], R) == [1,2,2,2]_R - 3 * [2,1,2,2]_R + 3 * [2,2,1,2]_R - [2,2,2,1]_R
        Text
            The word can also be given as a @TO List@.
        Example
            lieBasis({1,1,1,2}, R) // wordFormat

    References
        @HREF {"https://doi.org/10.1017/fms.2019.3", "VARIETIES OF SIGNATURE TENSORS (doi.org/10.1017/fms.2019.3)"}@
Node
    Key
        lyndonWords
        (lyndonWords, ZZ, ZZ)
    Headline
        compute all Lyndon words of at most a given lenght on a given number of letters
    Inputs
        d : ZZ --The number of letters
        k : ZZ --The maximum lenght 
    Outputs
        L : List -- of all Lyndon words of length at most k in d letters
    Usage
        L = lyndonWords(d, k)
    Description
        Text
            A word $l$ on the alphabet $\{1,\dots, d\}$ is a {\em Lyndon word} if it is striclty smaller, in lexicographic order, than all of its rotations.
        Text
            This method generates a list containing all Lyndon words of lenght at most $k$ on $d$ letters. The Lyndon words are given as @TO List@ in the same convention
            of @TO wordFormat@. 
        Example
            lyndonWords (2,3)

Node
    Key 
        (symbol @, NCRingElement, ZZ)
        (tensorArray, NCRingElement)
    Headline
        k-th level component of a tensor.
    Inputs
        s : NCRingElement 
        k : ZZ --The level to extract
    Outputs
        sk : List -- The k-th level of s, as a multi-dimensional array
    Usage
        sk = s@k
    Description
        Text
            Returns the $k$-level component of a tensor as multi-dimensioal array, represented by a nested @TO List@.
        Example
            R = QQ[t];
            X = polyPath({t,t^2});
            sig(X,2)@2 -- signature matrix at depth 2
            A = sig(X,3)@3 -- third level signature as multi-dimensional array
            i = 0; j = 0; k = 0;
            A#i#j#k == (Lt_(i+1)*Lt_(j+1)*Lt_(k+1))@(sig(X, 3)) --The coefficient of (Lt_1)^3 in sig(X, 3)
    SeeAlso
        (symbol @, NCRingElement, NCRingElement)

Node
    Key
        (symbol @, NCRingElement, NCRingElement)
        (inner, NCRingElement, NCRingElement)
        inner
    Headline
        Compute the inner product of two tensors.
    Description
        Text
            Let $\mathtt{s}, \mathtt{t}$ be elements of a free associative algebra on the letters $\mathtt{1}, \dots, \mathtt{d}$. Then the inner product of $\mathtt{s}$ and $\mathtt{t}$ is defined on the words $\mathtt{i_1}\cdot \dots\cdot \mathtt{i_k}$ as 
            $$ \mathtt{i_1}\cdot \dots\cdot \mathtt{i_k} \char"40 \mathtt{t} := t_{i_1\cdot\dots\cdot i_k}$$
            and then extended by lienarity over the whole associative algebra. Here $t_{i_1\cdot\dots\cdot i_k}$ is the coefficient of $\mathtt{i_1}\cdot \dots\cdot \mathtt{i_k}$ in $\mathtt{t}$.
        Text
            The inner product can be used to access the coefficient of a tensor over a single word.
        Example
            R = wordAlgebra(3);
            t = 2*[1,2,3]_R + [2,3,1]_R + 4*[3,3,3,3]_R; t //wordFormat
            [1,2,3]_R @ t == 2
            [3,3,3,3]_R @ t == 4


///


