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
        type
        dimension
        numberOfPieces
        pieces

    Headline
        The type of a piecewise polynomial path. 
    Description
        Text
            The type Path inherits from MutableHashTable. It has 4 attributes @TO dimension@, @TO numberOfPieces@, @TO pieces@ and @TO type@. "pieces" contains 
            a list of lists, each one being the components of polynomial path in normalForm. "type" is a string, either "PPolynomial" or "PLinear", standing 
            for "piecewise polynomial" and "piecewise linear" respectively. There are constructors for single piece paths, @TO linPath@ and @TO polyPath@ 
            and these can be concatenated with @TO (symbol **, Path, Path)@.
        Text
            A path can be constructed in different ways. For example a linear path  starting at 0 can constructed by giving the incremenent:
        Example
            X = linPath({2,3})
        Text
            While a polynomial path can be given either in listForm or as an actual polynomial
        Example
            R = QQ[t]
            Y1 = polyPath({t,2*t^2})
            Y2 = polyPath({{({1},1)},{({2},2)}})
        Text
            Path can be concatenated with @TO (symbol **, Path, Path)@:
        Example
            Z=Y1**Y2
        Text
            To extract only one piece of the path, for example the first, one can use
        Example
             Z_0
        Text
            While to exctract a subset of pieces, for example the first and last, one can use
        
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
            R=QQ[t]
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
            R=QQ[t];
            X = polyPath({t,t^2})
            X.dimension 
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
            R=QQ[x_1..x_5];
            X=linPath({x_1, x_2, x_3, x_4, x_5^2})
            X.dimension
    SeeAlso
        Path
        polyPath
        (symbol **, Path, Path)
Node
    Key
        sig
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
            d=4;
            R = QQ[t];
            X=polyPath(for i from 1 to d list t^i)
            A= QQ{s_1..s_d }
            w= product(for i from 1 to d list s_i)
        Text
            The word $w$ corresponds to the decomposable tensor $e_1^*\otimes\dots  \otimes e_d^*$, where $e_1^*, \dots, e_d^*$ is the dual of the canonical basis of $\mathbb{R}^d$. 
            The signature of $X$ on this word can be computed using @TO (sig, Path, NCRingElement)@.
        Example 
            sigma = sig(X, w)

Node
    Key
        (sig, Path, List)

Node
    Key 
        (sig, Path, NCRingElement)
    Headline
        Compute the specified component of the signature of a @TO Path@ 

    SeeAlso
        sig


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
            Creates a @TO Path@ of @TO type@ "PLinear".
        Example
            M:=id_(QQ^3)
            pwLinPath(M)
            oo.type
    SeeAlso
        Path

Node
    Key
        adjointWord
    Headline
        Image of a word thorugh the shuffle algebras homomorphism induced by a polynomial map 
    Inputs 
        g : NCRingElement --The word to compute the image of
        T : NCPolynomialRing --The shuffle algebra of the image
        L : List -- The compoenents of the polynomial map. Each entry should be a polynomial
    Usage
        adjointWord (g, T, L)
    Description
        Text
            Based on 
    References
        Signatures of paths transformed by polynomial maps (see https://arxiv.org/abs/1812.05962 )
///


