==================================
Connection Matrices in *Macaulay2*
==================================

| This page contains the code and preliminary documentation for our new *Macaulay2* package  :math:`{\tt ConnectionMatrices}`.

| Paul Görlach, Joris Koefler, Anna-Laura Sattelberger, Mahrud Sayrafi, Hendrik Schroeder, Nicolas Weiss, and Francesca Zaffalon: "Connection Matrices in *Macaulay2*"

| ARXIV: https://arxiv.org/abs/2504.01362 CODE: https://mathrepo.mis.mpg.de/ConnectionMatrices/


1. Introduction
---------

Systems of homogeneous, linear partial differential equations (PDEs) with polynomial coefficients 
are encoded by left ideals in the Weyl algebra, denoted 

.. math::
  D_n=\mathbb{C}[x_1,\ldots,x_n]\langle \partial_1,\ldots,\partial_n \rangle.

Such systems can be systematically written as a first-order matrix system, i.e., 
in "connection form" :math:`\operatorname{d} - A\wedge \,`, by utilizing Gröbner bases in the
Weyl algebra. In the case of a single ordinary differential equation (ODE), 
the respective matrix is known under the name of "companion matrix".

The systematic computation of connection matrices in software requires Gröbner bases 
in the rational Weyl algebra

.. math:: 
  R_n=\mathbb{C}(x_1,\ldots,x_n)\langle \partial_1,\ldots,\partial_n \rangle. 
  
These, however, are by now not available in the :math:`D`-module packages in standard 
open-source computer algebra software. Our new *Macaulay2* package :math:`{\tt ConnectionMatrices}` 
is intended to fill this gap. 

An accompanying 
article which provides the theoretical background will be available on the arxiv. The implemented 
functionalities include the computation of :math:`{\tt pfaffianSystem}` of :math:`D`-ideals for elimination 
term orders on the Weyl algebra with respect to positive weight vectors. In particular, this 
required the implementation of the :math:`{\tt normalForm}` algorithm over the rational Weyl algebra. 
We also implemented the :math:`{\tt gaugeTransformation}` for carrying out changes of basis over the field of 
rational functions. We also allow for the dependence on parameters, such as a "small parameter" 
:math:`\varepsilon`, as is commonly used for the dimensional regularization of Feynman integrals in particle physics.

2. Installation
--------------

Once the package has been added to the *Macaulay2* repository, the most recent version of our package will be available there.
Until then, a snapshot of our package can be downloaded here:

****
    | 
    | 
    | :download:`ConnectionMatrices.zip <ConnectionMatrices.zip>`

In order to install the package, start an M2 session in the folder containing :math:`{\tt ConnectionMatrices.m2}` and
execute

.. code-block:: macaulay2

    i1 : installPackage "ConnectionMatrices"

You should see M2 building the examples in the documentation which should look something like

.. code-block:: macaulay2

     -- making example results for "normalForm"            -- .557581s elapsed
     -- making example results for "pfaffianSystem"        -- .573788s elapsed
     -- making example results for "gaugeTransform"        -- .578373s elapsed

    o1 = ConnectionMatrices

    o1 : Package

Now you should be able to use the :math:`{\tt ConnectionMatrices}` package to compute connection matrices for 
your favorite :math:`{D}`-ideals.

.. code-block:: macaulay2

    i2 : needsPackage "ConnectionMatrices";

    i3 : D = makeWA(QQ[x]);
    
    i4 : I = ideal (dx + x*dx*dx);
    
    o4 : Ideal of D

    i5 : (pfaffianSystem I) # 0

    o5 = | 0 1      |
         | 0 (-1)/x |

                              2                  2
    o5 : Matrix (frac(QQ[x]))  <-- (frac(QQ[x]))

For more interesting examples and details on *all* implemented functionalities please refer to the documentation section below.

3. Documentation
---------------

Once the package has been added to the *Macaulay2* repository, an updated documentation will be available there.
Until then, a snapshot of the documentation is available `here <https://mahrud.github.io/LearnM2/packages/#ConnectionMatrices>`_.

After installation, it is also possible to view the documentation locally:

.. code-block:: macaulay2

    viewHelp "ConnectionMatrices"

3.1 Implemented Methods
_______________________

The below links will send you to the documentation snapshot linked above.

Working with the rational Weyl algebra
######################################

* `normalForm <https://mahrud.github.io/LearnM2/packages/#ConnectionMatrices::normalForm>`_ -- computes the normal form within the rational Weyl algebra
* `standardMonomials <https://mahrud.github.io/LearnM2/packages/#ConnectionMatrices::standardMonomials>`_ -- computes the standard monomials for a :math:`D_n`-ideal
* `baseFractionField <https://mahrud.github.io/LearnM2/packages/#ConnectionMatrices::baseFractionField>`_ -- extracts the fraction field of the base polynomial ring of a Weyl algebra

Computing and displaying :math:`D`-ideals in connection form
######################################################

* `pfaffianSystem <https://mahrud.github.io/LearnM2/packages/#ConnectionMatrices::pfaffianSystem>`_ -- computes the connection matrices of a :math:`D_n`-ideal :math:`I` for a chosen basis
* `connectionForm <https://mahrud.github.io/LearnM2/packages/#ConnectionMatrices::connectionForm>`_ -- computes the connection matrix

Changing basis of a system of connection matrices
#################################################

* `gaugeMatrix <https://mahrud.github.io/LearnM2/packages/#ConnectionMatrices::gaugeMatrix>`_ -- computes the base change over the field of rational functions
* `gaugeTransform <https://mahrud.github.io/LearnM2/packages/#ConnectionMatrices::gaugeTransform>`_ -- computes the gauge transform of a system of connection matrices
* `isEpsilonFactorized <https://mahrud.github.io/LearnM2/packages/#ConnectionMatrices::isEpsilonFactorized>`_ -- checks whether a system of connection matrices is in :math:`\epsilon`-factorized form

Testing integrability of a list of matrices
###########################################
* `isIntegrable <https://mahrud.github.io/LearnM2/packages/#ConnectionMatrices::isIntegrable>`_ -- checks whether a list of matrices fulfills the integrability conditions

Examples
########
* `Cosmological correlator for the 2-site chain <https://mahrud.github.io/LearnM2/packages/#ConnectionMatrices::Cosmological%20correlator%20for%20the%202-site%20chain>`_
* `Massless one-loop triangle Feynman diagram <https://mahrud.github.io/LearnM2/packages/#ConnectionMatrices::Massless%20one-loop%20triangle%20Feynman%20diagram>`_
* `Gauss' hypergeometric function <https://mahrud.github.io/LearnM2/packages/#ConnectionMatrices::Gauss%27%20hypergeometric%20function>`_







-------------------------------------------------------------------------

Project page created: 05/04/2025

Project contributors: Paul Görlach (paul.goerlach@ovgu.de), Joris Koefler (joris.koefler@mis.mpg.de), Anna-Laura Sattelberger (anna-laura.sattelberger@mis.mpg.de), Mahrud Sayrafi (mahrud@fields.utoronto.ca), Hendrik Schroeder (h.schroeder@tu-berlin.de), Nicolas Weiss (nicolas.weiss@mis.mpg.de), and Francesca Zaffalon (francesca.zaffalon@mis.mpg.de)

Corresponding author of this page: Nicolas Weiss, nicolas.weiss@mis.mpg.de

Software used: Macaulay2 (Version 1.24.11)

System setup used: MacBook Air with macOS 15.3.2, Processor Apple M3, Memory 24 GB

License for code of this project page: MIT License (https://spdx.org/licenses/MIT.html)

License for all other content of this project page: CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/)

Last updated 05/04/2025.





