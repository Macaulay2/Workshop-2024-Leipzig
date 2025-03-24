-- -*- coding: utf-8 -*-
newPackage(
    "ourDmodules",
    Version => "1.4.1.1",
    Date => "March 2025",
    Authors => {
        {Name => "Paul Goerlach", Email => "paul.goerlach@ovgu.de", HomePage => ""},
	    {Name => "Joris Koefler", Email => "joris.koefler@mis.mpg.de", HomePage => ""},
        {Name => "Mahrud Sayrafi", Email => "mahrud@fields.utoronto.ca", HomePage => ""},
        {Name => "Anna-Laura Sattelberger", Email => "anna-laura.sattelberger@mis.mpg.de", HomePage => ""},
        {Name => "Hendrik Schroeder", Email => "h.schroeder@tu-berlin.de", HomePage => ""},
        {Name => "Nicolas Weiss", Email => "nicolas.weiss@mis.mpg.de", HomePage => ""},
        {Name => "Franzesca Zaffalon", Email => "francesca.zaffalon@mis.mpg.de", HomePage => ""}
    },
    Headline => "Additions to Dmodules",
    Keywords => {"Documentation"},
    DebuggingMode => false,
    PackageExports => {
	 "Dmodules"
	 }
    )

--------------------------------------------------------------------------------
-- Dmodules
--------------------------------------------------------------------------------

-- ConnectionMatrices basic files
load "./AlgebraicAnalysis/reduce.m2"
export {
    --"makeWeylAlgebra",
    "fractionField",
    "rationalWeylAlgebra",
    "reduceOneStep",
    "normalForm"
}

--------------------------------------------------------------------------------
-- Tests
--------------------------------------------------------------------------------

--load "./tests/example.m2"

--------------------------------------------------------------------------------
-- Documentation
--------------------------------------------------------------------------------

beginDocumentation()

load "./DOC/general.m2"

end--

restart
uninstallPackage "ourDmodules"
installPackage "ourDmodules"

restart
needsPackage "ourDmodules"
check ourDmodules