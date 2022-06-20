# Complex Numbers

This module provides a `Complex` number type generic over an underlying `RealType`:
```swift
import Numerics
let z = Complex(1,1) // z = 1 + i
```
This module provides approximate feature parity and memory layout compatibility with C, Fortran, and C++ complex types (although the importer does not map the types for you, buffers may be reinterpreted to shim API defined in other languages).

The usual arithmetic operators are provided for complex numbers, as well as conversion to and from polar coordinates and many useful properties, plus conformances to the obvious usual protocols: `Equatable`, `Hashable`, `Codable` (if the underlying `RealType` is), and `AlgebraicField` (hence also `AdditiveArithmetic` and `SignedNumeric`).

The `Complex` type conforms to `ElementaryFunctions`, which makes common transcendental functions like `log`, `pow`, and `sin` available (consult the documentation for `ElementaryFunctions` in the `RealModule` for a full list and more information.

### Dependencies:
- `RealModule`.

## Design notes

### Mixed real-complex arithmetic.
It is tempting to define real-complex arithmetic operators, because we use them as shorthand all the time in mathematics: `z + x` or `2w`.
They are not provided by the Complex module for two reasons:
- Swift generally avoids heterogenous arithmetic operators
- They lead to counter-intuitive behavior of type inference.
  For a concrete example of the second point, suppose that heterogeneous arithmetic operators existed, and consider the following snippet:
  ```swift
  let a: RealType = 1
  let b = 2*a
  ```
  what is the type of `b`?

  If there is no type context, `b` is ambiguous; `2*a` could be interpreted as `Complex(2)*a` or as `RealType(2)*a`.
  That's annoying on its own. However, suppose that we're in a `Complex` type context:
  ```swift
  extension Complex {
    static func doSomething() {
      let a: RealType = 1
      let b = 2*a // type is inferred as Complex 🤪
    }
  }
  ```
  This makes heterogeneous arithmetic operators a non-option in the short term.

### Infinity and nan
C and C++ attempt to define semantics that interpret the signs of infinity and zero.
This is occasionally useful, but it also results in a lot of extra work.
The Swift Numerics `Complex` type does not assign any semantic meaning to the sign of zero and infinity; `(±0,±0)`, are all considered to be encodings of the value zero.
Similarly, `(±inf, y)`, `(x, ±inf)`, `(nan, y)` and `(x, nan)` are all considered to be encodings of a single exceptional value with infinite magnitude and undefined phase.

Because the phase is undefined, the `real` and `imaginary` properties return `.nan` for non-finite values.
This decision might be revisited once users gain some experience working with the type to make sure that it's a tradeoff that we're happy with, but early experiments show that it greatly simplifies the implementation of some operations without significant tradeoffs in usability.

### The magnitude property
The `Numeric` protocol requires a `.magnitude` property, but (deliberately) does not fully specify the semantics.
The most obvious choice for `Complex` would be to use the Euclidean norm (aka the "2-norm", given by `sqrt(real*real + imaginary*imaginary)`).
However, in practice there are good reasons to use something else instead:

- The 2-norm requires special care to avoid spurious overflow/underflow, but the naive expressions for the 1-norm ("taxicab norm") or ∞-norm ("sup norm") are always correct.
- Even when care is used, near the overflow boundary the 2-norm and the 1-norm are not representable.
  As an example, consider `z = Complex(big, big)`, where `big` is `Double.greatestFiniteMagnitude`.
  The 1-norm and 2-norm of `z` both overflow (the 1-norm would be `2*big`, and the 2-norm would be `sqrt(2)*big`, neither of which are representable as `Double`), but the ∞-norm is always equal to either `real` or `imaginary`, so it is guaranteed to be representable.
Because of this, the ∞-norm is the obvious alternative; it gives the nicest API surface.
- If we consider the magnitude of more exotic types, like operators, the 1-norm and ∞-norm are significantly easier to compute than the 2-norm (O(n) vs. "no closed form expression, but O(n^3) iterative methods"), so it is nice to establish a precedent of `.magnitude` binding one of these cheaper-to-compute norms.
- The ∞-norm is heavily used in other computational libraries; for example, it is used by the `izamax` and `icamax` functions in BLAS.

The 2-norm still needs to be available, of course, because sometimes you need it.
This functionality is accessed via the `.length` and `.lengthSquared` properties.

### Accuracy of division and multiplication
This library attempts to provide robust division and multiplication operations, with small relative error in a complex norm. It is a non-goal to deliver small componentwise errors.
See `testBaudinSmith` in `ComplexTests.swift` for examples of cases where we have tiny relative error but large error in one of the result components considered in isolation.
This is the right tradeoff for a general-purpose library because it allows us to use the naive formulas for multiplication and division (which are fast), and do a simple check to see if we need to re-do the computation more carefully to avoid spurious overflow or underflow.
It's also about as accurate as multiplication.

Implementing the method of Baudin and Smith (or any other method that delivers similarly small componentwise error) would unduly slow down the common case for relatively little benefit--componentwise error bounds are rarely necessary when working over the complex numbers.

That said, a PR that implements multiplication and division *functions* with tight componentwise error bounds would be a welcome addition to the library.
