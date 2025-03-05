-- -*- coding: utf-8 -*-
newPackage(
    "FirstPackage",
    Version => "1.4.1.1",
    Date => "March 2025",
    Authors => {
        {Name => "Paul Goerlach", Email => "paul.goerlach@ovgu.de", HomePage => ""}
	    {Name => "Joris Koefler", Email => "joris.koefler@mis.mpg.de", HomePage => ""},
        {Name => "Mahrud Sayrafi", Email => "mahrud@fields.utoronto.ca", HomePage => ""},
        {Name => "Anna-Laura Sattelberger", Email => "anna-laura.sattelberger@mis.mpg.de", HomePage => ""},
        {Name => "Carlos Rodriguez", Email => "carlos.rodriguez@mis.mpg.de", HomePage => ""},
        {Name => "Hendrik Schroeder", Email => "h.schroeder@tu-berlin.de", HomePage => ""},
        {Name => "Nicolas Weiss", Email => "nicolas.weiss@mis.mpg.de", HomePage => ""},
        {Name => "Franzesca Zaffalon", Email => "francesca.zaffalon@mis.mpg.de", HomePage => ""},
    },
    Headline => "an example Macaulay2 package",
    Keywords => {"Documentation"},
    DebuggingMode => false
    )

--------------------------------------------------------------------------------
-- Dmodules
--------------------------------------------------------------------------------

-- Pfaffians basic files
load "./AlgebraicAnalysis/reduce.m2"
export {
    "makeWeylAlgebra",
    "fractionField",
    "rationalWeylAlgebra",
    "reduceOneStep",
    "normalForm"
}

--------------------------------------------------------------------------------
-- Tests
--------------------------------------------------------------------------------

load "./AlgebraicAnalysis/tests/example.m2"

--------------------------------------------------------------------------------
-- Documentation
--------------------------------------------------------------------------------

beginDocumentation()

load "./AlgebraicAnalysis/DOC/general.m2"

end--

restart
uninstallPackage "Dmodules"
installPackage "Dmodules"

restart
needsPackage "Dmodules"
check Dmodules