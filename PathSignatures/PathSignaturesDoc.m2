beginDocumentation()

doc ///
Node
    Key
        PathSignatures
    Headline
        A package for working with signatures of algebraic paths
    Description
        Text
            {\em PathSignatures} is a package for studying the signature of piecewise polynomial paths.

            An example for the use of the package is to reproduce the data in Table 3 of the paper: Carlos Améndola, Peter Friz and Bernd Sturmfels, 
            {\em Varieties of signatures tensors}, Forum of Mathematics, Sigma. 2019;7:e10. doi:10.1017/fms.2019.3

            We create the ...
Node
    Key
        Path
        (symbol _, Path, List)
        (symbol _, Path, ZZ)
        (symbol _, Path, Sequence)
        (getDimension, Path)
        getDimension
        (getNumberOfPieces, Path)
        getNumberOfPieces
        (getPieces, Path)
        getPieces
        (getBaseRing, Path)
        getBaseRing
    Headline
        The type of a piecewise polynomial path. 
    Description
        Text
            The type Path inherits from @TO2 {"Macaulay2Doc :: MutableHashTable", "MutableHashTable"} @. There are constructors for single piece paths, @TO linPath@ and @TO polyPath@ 
            and these can be concatenated with @TO (symbol **, Path, Path)@.
        Text
            A path can be constructed in different ways. For example a linear path starting at 0 can constructed by giving the incremenent:
        Example
            X = linPath({2,3})
        Text
            While a polynomial path can be given either in @TO2 {"Macaulay2Doc :: listForm", "listForm"}@ or as an actual polynomial
        Example
            R = QQ[t]
            Y1 = polyPath({t,2*t^2})
            Y2 = polyPath({{({1},1)},{({2},2)}})
        Text
            The coefficients of the polynomials can be any ring, but there must be only one top level variable
        Example
            R2 = QQ[a][t]; --QQ[a,t] will not work!
            Y3 = polyPath({a*t,2*a*t^2}) 
        Text
            Paths can be concatenated with @TO (symbol **, Path, Path)@:
        Example
            Z = Y1**Y3
        Text
            To extract only one piece of the path, for example the first, one can use @TO (symbol _, Path, ZZ)@
        Example
             Z_0
        Text
            While to exctract a subset of pieces, for example the first and last, one can use either @TO (symbol _, Path, List)@ or @TO (symbol _, Path, Sequence)@
        Example
            Z2 = Z**Z
            Z2_{0,-1}
        Text
            Finally, there are getters @TO (getDimension, Path)@, @TO (getPieces, Path)@, @TO (getBaseRing, Path)@ and @TO (getNumberOfPieces, Path)@ to read the attributes of a path
        Example
            getDimension(Z) --The ambient dimension of the path
            getPieces(Z) --The polynomial pieces of the path, in listForm
            getBaseRing(Z) -- The coefficients ring of the polynomial components of the path
            getNumberOfPieces(Z) -- The number of polynomial pieces of the path
        Text
            Remark that the polynomials are stored in their @TO2 {"Macaulay2Doc :: listForm", "listForm"}@ and that the concatenation @TO (symbol **, Path, Path)@ will automatically
            select a bigger base ring when an obvious choice is available.

    SeeAlso
        polyPath
        linPath

Node 
    Key
        (symbol **, Path, Path)
    Headline
        Concatenation of paths
    Usage 
        X**Y
    Description
        Text
            This allows for concatenation of paths of the same type attribute. 
        Example
            R = QQ[t];
            X = polyPath({t,t^2}) ** polyPath({t^3 + 3*t, t^2 - 1})
    SeeAlso
        polyPath
        linPath
Node
    Key
        polyPath
    Headline
        Constructor of single piece polynomial path
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
        Constructor of single piece polynomial path
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
        Compute the signature of a picewise polynomial path.
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
            Note however that neither the symbols nor the ring of this polynomial are made available to the user, in particular they can not be added or multiplied. To obtain the tensor as a NCPolynomial in a given NCRing, use @TO (sig, Path, ZZ,  NCRing)@ instead:
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
    Headline
        Constructor of a piecewise linear path from a matrix
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
        Image of a word through the shuffle algebras homomorphism induced by a polynomial map 
    Inputs 
        g : NCRingElement --The word to compute the image of
        T : NCPolynomialRing --The shuffle algebra of the image
        L : List -- The components of the polynomial map. Each entry should be a polynomial
    Usage
        adjointWord (g, T, L)
    Description
        Text
            This computes the image of g through the map $M_p$ described in Theorem 1 and Theorem 7 of the paper: Laura Colmenarejo and Rosa Preiß, {\em Signatures of
             paths transformed by polynomial maps}, Beitr Algebra Geom 61, 695–717 (2020). https://doi.org/10.1007/s13366-020-00493-9. It's importance is evidenced by
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
        Shuffle product of two words
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
Node 
    Key
        (wordAlgebra, ZZ)
    Inputs
        z: ZZ -- The number of variables in the algebra, usually the ambient dimension of the path
        BaseRing => Ring -- The coefficients ring, by default the rationals.
    Outputs
        A: NCRing --The associative free polynomial algebra on the letters LT_1, ..., Lt_z
    Headline
        Create a free associative algebra on a given number of generators
    Usage
        wordAlgebra(z)
    Description
        Text
            Creates the free associative polynomial algebra on the letters Lt_1,$ \dots$, Lt_z.
        Example
            z = 5;
            A = wordAlgebra(z)
            gens A
    SeeAlso
        wordAlgebra
Node
    Key
        wordAlgebra
        NCRingElement
        NCPolynomialRing
    Headline
        Create a free algebra representing a tensor
    Description
        Text
            In this package tensors are represented as elements of free associative algebras, 
            using the package @TO2 {"NCAlgebra :: NCAlgebra", "NCAlgebra"}@. The easiest way to create 
            such an algebra is through @TO wordAlgebra@. For example, by using @TO (wordAlgebra, ZZ)@ we 
            can create the free algebra on $d$ letters:
        Example
            d = 5;
            A = wordAlgebra(d)
            gens A
        Text
            An element of the algebra can be either generated by using the symbols Lt_1, $\dots$ , Lt_d or by @TO (symbol _, Array, NCPolynomialRing)@
        Example
            d = 5;
            R = wordAlgebra(d); -- create a free associative algebra over two letters Lt_1, Lt_2
            f = [1,d]_R + [2,d]_R  -- [i_1,...,i_k]_R defines a word.
            f === Lt_1*Lt_d+Lt_2*Lt_d 
        Text
            To display a tensor in square braket notation above one can use @TO wordFormat@
        Example
            f // wordFormat
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
        Create a word from an array
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
        Display a tensor in word notation
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
        (symbol <<, NCRingElement, NCRingElement)
    Headline
        Compute the halfshaffle of an ordered pair of words
    Inputs
        f : NCRingElement 
        g : NCRingElement 
    Outputs
        h : NCRingElement -- The half-shuffle f<<g of the two words
    Usage
        h = f << g
    Description
        Text
            We start on the mathematical definition, based on the reference, where the operation is called {\em right half-shuffle}. Let 
            $T^{\geq 1}(\mathbb{R}^d)$ be the vector space spanned by the non empty words on $d$ letters. Then the half shuffle $<<$ is defined 
            recursively to be $$ w << i := wi$$ for $w$ a word and $i$ a letter and $$ w << vi := (w << v + v << w)\bullet i$$ for $w, v$ words 
            and $i$ a letter, where $\bullet$ is the contatenation product on words. 
        Text
            As stated in the reference, the @TO shuffle@ on non empty words can be seen as a symmetrization of the half-shuffle. As a usage example, we verify this in a particular instance.
        Example
            R = wordAlgebra(3);
            w = [1]_R
            v = [1,2,3]_R
            s = w ** v --shuffle product of w, v
            hsSymm = (w << v) + (v << w)--half-shuffle product symmetrization of w, v
            s == hsSymm


    References
        @HREF {"https://doi.org/10.1007/s13366-020-00493-9","Signatures of paths transformed by polynomial maps (doi.org/10.1007/s13366-020-00493-9)"} @
    SeeAlso
        shuffle
        (symbol _, Array, NCPolynomialRing)
///


