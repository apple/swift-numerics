# Approximate equality

Compare floating-point values up to a tolerance.

## Overview

Floating-point arithmetic is not exact, so two values that are mathematically
equal may differ slightly once they have been computed. Comparing such values
with `==` is usually a mistake: the test will fail for inputs that are equal
in every way that matters to your program.

`RealModule` provides a family of `isApproximatelyEqual` methods that test
whether two values are within a tolerance of one another. They are available
on any `Numeric` type whose `Magnitude` is a `FloatingPoint` type (including
`Float`, `Double`, and `Complex`), and a more general form is available on any
`AdditiveArithmetic` type for which you can supply a norm.

```swift
import Numerics

let x = 0.1 + 0.2
x == 0.3                        // false
x.isApproximatelyEqual(to: 0.3) // true
```

### Choosing a tolerance

The simplest method uses a *relative* tolerance:

```swift
public func isApproximatelyEqual(
  to other: Self,
  relativeTolerance: Magnitude = Magnitude.ulpOfOne.squareRoot()
) -> Bool
```

Two finite values compare equal when

```
(self - other).magnitude <= relativeTolerance * scale
```

where `scale` is `max(self.magnitude, other.magnitude, .leastNormalMagnitude)`.
Because the bound grows with the size of the operands, a single relative
tolerance works across a wide range of magnitudes.

The default tolerance is `.ulpOfOne.squareRoot()`, which corresponds to
expecting about half of the available digits in the result to be correct. This
is the usual rule of thumb in numerical analysis when you have no other
information about the computation, but it is not appropriate for every use
case, so you should pass an explicit value when you can estimate how much error
your computation introduces.

A relative tolerance does not work well when comparing against zero, because
the scale of zero is zero. To handle values near zero, use the overload that
also takes an *absolute* tolerance:

```swift
public func isApproximatelyEqual(
  to other: Self,
  absoluteTolerance: Magnitude,
  relativeTolerance: Magnitude = 0
) -> Bool
```

Two finite values compare equal when *either* the absolute or the relative
bound is satisfied:

```
(self - other).magnitude <= absoluteTolerance
```
or
```
(self - other).magnitude <= relativeTolerance * scale
```

where `scale` is `max(self.magnitude, other.magnitude)`. The relative tolerance
defaults to zero here, so by passing only an absolute tolerance you get a plain
absolute comparison. A common pattern is to supply both, using the absolute
tolerance to bound the comparison near zero and the relative tolerance
elsewhere:

```swift
let error = 1e-8
result.isApproximatelyEqual(
  to: expected,
  absoluteTolerance: error,
  relativeTolerance: error
)
```

### Special values

The comparison follows the same conventions as `FloatingPoint`:

```swift
Double.nan.isApproximatelyEqual(to: .nan)           // false
Double.infinity.isApproximatelyEqual(to: .infinity) // true
(0.0).isApproximatelyEqual(to: -0.0)                // true
```

A NaN is never approximately equal to anything, including itself, and a finite
value is never approximately equal to an infinity. Equal values always compare
approximately equal regardless of the tolerance, so infinities compare equal to
themselves and `+0` compares equal to `-0`.

### Comparing other types with a custom norm

The methods above measure the difference between two values using the
`.magnitude` property. Sometimes you want to use a different
[norm][norm]. The most general overload, defined on `AdditiveArithmetic`,
lets you supply one:

```swift
public func isApproximatelyEqual<Magnitude>(
  to other: Self,
  absoluteTolerance: Magnitude,
  relativeTolerance: Magnitude = 0,
  norm: (Self) -> Magnitude
) -> Bool
where Magnitude: FloatingPoint
```

For a complex value, the default norm `\.magnitude` measures the difference
inside a square region. To test instead whether a value lies inside a circle of
radius `0.001` centered at `1 + 0i`, pass the Euclidean length as the norm:

```swift
import ComplexModule

z.isApproximatelyEqual(
  to: 1,
  absoluteTolerance: 0.001,
  norm: \.length
)
```

## Mathematical properties

For any fixed tolerance, approximate equality is *reflexive* on
non-exceptional values and *symmetric*: if `a` is approximately equal to `b`,
then `b` is approximately equal to `a`.

It is **not transitive**. `a` can be approximately equal to `b`, and `b` to
`c`, while `a` and `c` differ by more than the tolerance. Approximate equality
is therefore **not** an equivalence relation, even when restricted to
non-exceptional values. For this reason you must not use it to implement a
conformance to `Equatable`: doing so would violate the invariants that generic
code written against `Equatable` relies on.

[norm]: https://en.wikipedia.org/wiki/Norm_(mathematics)
