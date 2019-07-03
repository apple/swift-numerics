# Complex Numbers

This module provides a `Complex` number type generic over an underlying `RealType`:
```swift
1> import Complex
2> let z = Complex(1,1) // z = 1 + i
```
This module provides approximate feature parity and memory layout compatibility with C,
Fortran, and C++ complex types (although the importer cannot map the types for you,
buffers may be reinterpreted to shim API defined in other languages).

The usual arithmetic operators are provided for Complex numbers, as well as
conversion to and from polar coordinates and many useful properties, plus
conformances to the obvious usual protocols: `Equatable`, `Hashable`, `Codable`
(if the underlying `RealType` is), and `Numeric` (hence `AdditiveArithmetic`).

### Dependencies:
- The `ElementaryFunctions` module.

## Design notes

### Mixed real-complex arithmetic.
It is tempting to define real-complex arithmetic operators, because we use them as
shorthand all the time in mathematics: `z + x` or `2w`. They are not provided by the
Complex  module for two reasons:
- Swift generally avoids heterogenous arithmetic operators
- They lead to counter-intuitive behavior of type inference.
For a concrete example of the second point, suppose that heterogeneous arithmetic
operators existed, and consider the following snippet:
```swift
let a: RealType = 1
let b = 2*a
```
what is the type of `b`?

If there is no type context, `b` is ambiguous; `2*a` could be interpreted as
`Complex(2)*a` or as `RealType(2)*a`. That's fairly annoying on its own. However,
suppose that we're in a `Complex` type context:
```swift
extension Complex {
  static func doSomething() {
    let a: RealType = 1
    let b = 2*a // type is inferred as Complex 🤪
  }
}
```
This is a show-stopper for heterogeneous arithmetic operators in the short term.

### Infinity and nan
C and C++ attempt to define precise semantics that interpret the sign of infinity and zero.
This is occasionally useful, but it also results in a lot of extra work. The swift-numerics
`Complex` type does not assign any semantic meaning to the sign of zero and infinity;
`(±0,±0)`, are all considered to be encodings of the value zero. Similarly, `(±inf, y)`,
`(x, ±inf)`, `(nan, y)` and `(x, nan)` are all considered to be encodings of a single
exceptional value with infinite magnitude and undefined phase.

Because the phase is undefined, the `.real` and `.imag` properties return `.nan` 

This decision may be revisited once users gain some experience working with the type
to make sure that it's a tradeoff that we're happy with, but early experiments show that
it greatly simplifies the implementation of some operations without significant tradeoffs
in usability.
