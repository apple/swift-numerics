# ``RealModule``

Extensions on the Swift standard library that provide functionality for
floating-point types.

## Overview

``RealModule`` provides four protocols that extend the standard library's
numeric protocol hierarchy: AlgebraicField, ElementaryFunctions,
RealFunctions, and Real.

Types conforming to AlgebraicField represent
[fields](https://en.wikipedia.org/wiki/Field_(mathematics)). These are the
mathematical structures that typically form the elements of vectors and
matrices, so this protocol is appropriate for writing generic code to do
linear-algebra-type operations.

ElementaryFunctions provides bindings for the "math functions": the logarithm
and exponential functions, sine, cosine and tangent as well as their inverses,
and other functions that you may be familiar with from trigonometry and
calculus. RealFunctions refines ElementaryFunctions and provides functions that
are primarily used with the real numbers, such as atan2, erf and gamma, and
the base-2 and -10 logarithm and exponential funtions.

The Real protocol is a convenient name for the intersection of `FloatingPoint`,
`RealFunctions`, and `AlgebraicField`; this is the protocol that you are most
likely to want to constrain to when writing generic "math" code that works
with floating-point types.
