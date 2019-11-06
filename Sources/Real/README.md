# Real

This module implements [SE-0246].
It is implemented in Swift Numerics to work around difficulties that blocked adding these operations to the standard library for 5.1:

- Swift does not yet have a way to back-deploy protocol conformances; this prevents making this useful feature available on older Apple OS targets.
- The lack of means to back-deploy prevents obsoleting the existing concrete math functions defined in the Darwin (Apple platforms), Glibc (Linux), and MSVCRT (Windows) modules.
- There is an outstanding bug with name resolution, which causes the new static functions (`Float.sin`) to shadow the existing free functions (`sin(_ x: Float) -> Float`) even in contexts where static functions are not allowed, leading to a number of spurious errors.
  See https://github.com/apple/swift/pull/25316 for discussion of how this might be addressed in the future
- There are some typechecker performance regressions (partially resulting from the issues described above).

Placing this module in Swift Numerics first gives the community a chance to address some of the compiler limitations that this feature ran into *before* it lands in the standard library (avoiding unnecessary source churn for projects that use these features), while also making it available *now*, including back-deployment to older Apple OS targets.

## Using Real

First, either import `Real` directly or import the `Numerics` umbrella module.
This makes all the elementary  functions available on `Float`, `Double`, and--on platforms that support it--`Float80`:
```
import Numerics

func sigmoid(_ x: Double) -> Double {
  1 / (1 + Double.exp(-x))
}
```
As always, in many contexts we can elide the explicit type on the static method, which yields a more fluent alternative style:
```
func sigmoid(_ x: Double) -> Double {
  1 / (1 + .exp(-x))
}
```
When writing generic code, you will most often want to use the `Real` protocol, which implies conformance to `ElementaryFunctions`, `RealFunctions`, and `FloatingPoint`:
```
func sigmoid<T: Real>(_ x: T) -> T {
  1 / (1 + .exp(-x))
}
```
## Protocols and Methods

Types conforming to `ElementaryFunctions`  provide the following static methods:

- Exponential functions: `exp`, `expMinusOne`
- Logarithmic functions: `log`, `log(onePlus:)`
- Trigonometric functions: `cos`, `sin`, `tan`
- Inverse trigonometric functions: `acos`, `asin`, `atan`
- Hyperbolic functions: `cosh`, `sinh`, `tanh`
- Inverse hyperbolic functions: `acosh`, `asinh`, `atanh`
- Power and root functions: `pow`, `sqrt`, `root`

The protocol `RealFunctions` refines `ElementaryFunctions`, and adds the following static methods, which either only make sense for real types, or are unusually difficult to implement well for arbitrary types:

- `atan2(y:x:)`, which computes `atan(y/x)` with sign chosen by the quadrant of the point `(x,y)` in the Cartesian plane.
- `hypot`, which computes `sqrt(x*x + y*y)` without intermediate overflow or underflow.
- `erf` and `erfc`, the [error function][ErrorFunction] and its complement.
- Exponential functions: `exp2` and `exp10`
- Logarithmetic functions: `log2` and `log10`
- Gamma functions: `gamma`, `logGamma`, and `signGamma`, which evaluate the [gamma function][GammaFunction], its logarithm, and its sign.
  Note that the Windows runtime does not implement the  `lgamma_r` or `lgamma` C functions, so `logGamma` and `signGamma` are not available when targeting Windows.

The protocol `Real` further refines `RealFunctions`, adding conformance to `FloatingPoint` and no additional operations.
This is the protocol that you will want to use most often while writing generic code; it provides a good set of useful operations without being overly restrictive.
In particular, algorithms written against `Real` will work with `Float`, `Double` and `Float80`.

Further details can be found in the [SE-0246 proposal document][SE-0246].

### Dependencies:
- The C standard math library (`libm`) via the `NumericShims` target.

[ErrorFunction]: https://en.wikipedia.org/wiki/Error_function
[GammaFunction]: https://en.wikipedia.org/wiki/Gamma_function
[SE-0246]: https://github.com/apple/swift-evolution/blob/master/proposals/0246-mathable.md
