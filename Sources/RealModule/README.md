# Real Module

[SE-0246] proposed an API for "basic math functions" that would make operations like sine and logarithm available in generic contexts.
It was accepted, but because of limitations in the compiler, the API could not be added to the standard library in a source-stable manner.
`RealModule` provides that API as a separate module so that you can use it right away to get access to the improved API for these operations in your projects.

## Protocols and Methods

The module defines four protocols. The most general is `ElementaryFunctions`, which makes the following functions available:
- Exponential functions: `exp`, `expMinusOne`
- Logarithmic functions: `log`, `log(onePlus:)`
- Trigonometric functions: `cos`, `sin`, `tan`
- Inverse trigonometric functions: `acos`, `asin`, `atan`
- Hyperbolic functions: `cosh`, `sinh`, `tanh`
- Inverse hyperbolic functions: `acosh`, `asinh`, `atanh`
- Power and root functions: `pow`, `sqrt`, `root`

`ElementaryFunctions` refines `AdditiveArithmetic`, and so also provides addition, subtraction, and the `.zero` property.

The `RealFunctions` protocol refines `ElementaryFunctions`, and adds operations that are difficult to define or implement over fields more general than the real numbers:
- `atan2(y:x:)`, which computes `atan(y/x)` with sign chosen by the quadrant of the point `(x,y)` in the Cartesian plane.
- `hypot`, which computes `sqrt(x*x + y*y)` without intermediate overflow or underflow.
- `erf` and `erfc`, the [error function][ErrorFunction] and its complement.
- Exponential functions: `exp2` and `exp10`
- Logarithmetic functions: `log2` and `log10`
- Gamma functions: `gamma`, `logGamma`, and `signGamma`, which evaluate the [gamma function][GammaFunction], its logarithm, and its sign.

The protocol that you will use most often is `Real`, which describes a floating-point type equipped with the full set of basic math functions.
This is a great protocol to use in writing generic code, because it has all the basics that you need to implement most numeric functions.

The fourth protocol is `AlgebraicField`, which `Real` also refines.
This protocol is a very small refinement of `SignedNumeric`, adding the `/` and `/=` operators and a `reciprocal` property.
The primary use of this protocol is for writing code that is generic over real and complex types.

## Using Real

First, either import `RealModule` directly or import the `Numerics` umbrella module.

Suppose we were experimenting with some basic machine learning, and needed a generic [sigmoid function][Sigmoid] activation function:

```swift
import Numerics

func sigmoid<T: Real>(_ x: T) -> T {
  1 / (1 + .exp(-x))
}
```

Or suppose we were implementing a DFT, and wanted to precompute weights for the transform; DFT weights are roots of unity:

```swift
import Numerics

extension Real {
  // The real and imaginary parts of e^{-2πik/n}
  static func dftWeight(k: Int, n: Int) -> (r: Self, i: Self) {
    precondition(0 <= k && k < n, "k is out of range")
    guard let N = Self(exactly: n) else {
      preconditionFailure("n cannot be represented exactly.")
    }
    let theta = -2 * .pi * (Self(k) / N)
    return (r: .cos(theta), i: .sin(theta))
  }
}
```

This gives us an implementation that works for `Float`, `Double`, and `Float80` if the target supports it.
When new basic floating-point types are added to Swift, like `Float16` or `Float128`, it will work for them as well.
Not having this protocol is a significant missing feature for numerical computing in Swift, and I'm really looking forward to seeing what people do with it.

### Dependencies:
- The C standard math library (`libm`) via the `_NumericsShims` target.

[ErrorFunction]: https://en.wikipedia.org/wiki/Error_function
[GammaFunction]: https://en.wikipedia.org/wiki/Gamma_function
[SE-0246]: https://github.com/apple/swift-evolution/blob/master/proposals/0246-mathable.md
[Sigmoid]: https://en.wikipedia.org/wiki/Sigmoid_function
