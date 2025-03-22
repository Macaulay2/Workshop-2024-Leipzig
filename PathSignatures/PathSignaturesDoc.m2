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
    Headline
        The type of a piecewise polynomial path. 
    Description
        Text
            The type Path inherites from MutableHashTable. It has 4 attributes "dimension", "numberOfPieces", "pieces" and "type". "pieces" contains 
            a list of lists, each one being the components of polynomial path in normalForm. "type" is a string, either "PPolynomial" or "PLinear", standing 
            for "piecewise polynomial" and "piecewise linear" respectively. There are constructors for single piece paths, @TO linPath@ and @TO polyPath@ 
            and these can be concatenated with @TO (symbol **, Path, Path)@.
        Example
            R=QQ[t]
            X = polyPath({t,t^2}) ** polyPath({t^3 + 3*t, t^2 - 1})
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
        polyPath({t,t^2,t^3})
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
    Headline
        Constructor of single piece polynomial path
    Usage
        linPath({0,0,0,1})
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


///


