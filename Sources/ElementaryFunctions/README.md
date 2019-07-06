# Elementary Functions

This module implements [SE-0246]. It is being implemented here first to work around a
few difficulties that blocked adding these operations to the standard library for 5.1:

- Swift does not yet have a way to back-deploy protocol conformances; this prevents
making this useful feature available on older Apple OS targets.

- The lack of means to back-deploy prevents obsoleting the existing concrete
math functions defined in the Darwin (Apple platforms), Glibc (Linux), and MSVCRT
(Windows) modules.

- There is an outstanding bug with name resolution, which causes the new static functions
(`Float.sin`) to shadow the existing free functions (`sin(_ x: Float) -> Float`) even
in contexts where static functions are not allowed, leading to a number of spurious errors.
See https://github.com/apple/swift/pull/25316 for discussion of how to fix this.

- There are some typechecker performance regressions (partially resulting from the issues
described above).

Placing this module in swift-numerics first gives the community a chance to address
some of the compiler limitations that this feature ran into *before* it lands in the standard
library (avoiding unnecessary source churn for projects that use these features), while also
making it available *now*, including back-deployment to older Apple OS targets.

Further details can be found in the [SE-0246 proposal document][SE-0246].

[SE-0246]: https://github.com/apple/swift-evolution/blob/master/proposals/0246-mathable.md

### Dependencies:
- The C standard math library (`libm`) via the `NumericShims` target.
