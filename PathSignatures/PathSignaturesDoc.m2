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
            a list of lists, each one being the components of polynomial path normalForm. "type" is a string, either "PPolynomial" or "PLinear", standing 
            for "piecewise polynomial" and "piecewise linear" respectively. There are constructors for single piece paths, @TO linPath@ and @TO polyPath@ 
            and these can be concatenated with @TO (symbol **, Path, Path)@
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
    SeeAlso
        polyPath
        linPath
///
