# Approximate Equality

Test whether two values agree within a specified tolerance.

## Overview

In numerical computing, mathematical equality often diverges from computed
equality. Rounding in floating-point arithmetic is one common cause, but many
nontrivial numerical algorithms also have inherent truncation or discretization
errors, and empirical measurements carry uncertainty to begin with. In these
scenarios, exact equality (`==`) may be too strict or inappropriate, and an
approximate equality comparison is needed instead. Conversely, exact equality
remains entirely appropriate when checking for identical values, sentinel states,
or integers.

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

### Comparing non-Numeric types with a custom norm

The approximate equality API is not limited to scalar numbers or `Numeric`
types. Any type conforming to `AdditiveArithmetic` can be compared once you
supply a suitable norm function mapping differences to a `FloatingPoint`
magnitude.

For example, consider a 2D geometric vector or point type representing spatial
displacements:

```swift
struct Vector2D: AdditiveArithmetic, Equatable {
  var x: Double
  var y: Double

  static var zero: Vector2D {
    Vector2D(x: 0, y: 0)
  }

  static func + (lhs: Vector2D, rhs: Vector2D) -> Vector2D {
    Vector2D(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
  }

  static func - (lhs: Vector2D, rhs: Vector2D) -> Vector2D {
    Vector2D(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
  }
}

// Compare vectors using the Euclidean distance (L2 norm):
let v1 = Vector2D(x: 1.0, y: 2.0)
let v2 = Vector2D(x: 1.000000001, y: 1.999999999)

let areClose = v1.isApproximatelyEqual(
  to: v2,
  absoluteTolerance: 1e-6,
  norm: { v in (v.x * v.x + v.y * v.y).squareRoot() }
)
// areClose == true
```

Because `Vector2D` is not `Numeric` (it does not define multiplication of
vectors to produce a vector), it cannot use the standard `Numeric.isApproximatelyEqual`
overload. However, because vector subtraction forms a difference vector in an
additive space, the general `AdditiveArithmetic` overload evaluates the custom
norm directly.

### Choosing a tolerance

The simplest method uses a _relative_ tolerance:

```swift
public func isApproximatelyEqual(
  to other: Self,
  relativeTolerance: Magnitude = Magnitude.ulpOfOne.squareRoot(),
  norm: (Self) -> Magnitude = \.magnitude
) -> Bool
```

Two finite values compare equal when

```
norm(self - other) <= relativeTolerance * scale
```

where `scale` is `max(norm(self), norm(other), .leastNormalMagnitude)`.
Because the bound grows with the size of the operands, a single relative
tolerance works across a wide range of magnitudes.

The default tolerance is `.ulpOfOne.squareRoot()`, which corresponds to
expecting about half of the available digits in the result to be correct. This
is the usual rule of thumb in numerical analysis when you have no other
information about the computation, but it is not appropriate for every use
case, so you should pass an explicit value when you can estimate how much error
your computation introduces.

#### Absolute versus relative tolerance

A relative tolerance scales with the magnitude of the operands, making it
effective across numbers of very small or very large scale. However, a pure
relative tolerance fails when comparing against zero or numbers much smaller
than the surrounding computation, because `scale` approaches zero and shrinks
the allowable difference to near zero.

To handle values near zero, use the overload that also accepts an _absolute_
tolerance:

```swift
public func isApproximatelyEqual(
  to other: Self,
  absoluteTolerance: Magnitude,
  relativeTolerance: Magnitude = 0
) -> Bool
```

Two finite values compare equal when _either_ the absolute or the relative
bound is satisfied:

```
(self - other).magnitude <= absoluteTolerance
```

or

```
(self - other).magnitude <= relativeTolerance * scale
```

where `scale` is `max(self.magnitude, other.magnitude)`.

When choosing values:
- Use **relative tolerance** when the allowed error is proportional to the
  magnitude of the values being computed (e.g. general floating-point arithmetic).
- Use **absolute tolerance** when values can be near zero, or when the error
  is independent of the scale of the inputs (e.g. fixed measurement resolution).
- Supplying both allows the absolute tolerance to govern comparisons near
  zero, while the relative tolerance takes over once values grow beyond
  `absoluteTolerance / relativeTolerance`.

Setting `absoluteTolerance == relativeTolerance` is typically appropriate only
when values are expected to lie on an integral or unit-spaced grid due to
algorithmic considerations (where `1.0` represents the base unit scale). For
general computations, the two tolerances should be chosen independently based on
the scale of the problem and the expected precision.

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
[norm](https://en.wikipedia.org/wiki/Norm_(mathematics)). The most general
overload, defined on `AdditiveArithmetic`, lets you supply one:

```swift
public func isApproximatelyEqual<Magnitude>(
  to other: Self,
  absoluteTolerance: Magnitude,
  relativeTolerance: Magnitude = 0,
  norm: (Self) -> Magnitude
) -> Bool
where Magnitude: FloatingPoint
```

#### Complex magnitude vs other norms

For complex numbers, the default norm is `\.magnitude`, which computes the
infinity-norm (`max(abs(real), abs(imaginary))`).

A major numerical advantage of `\.magnitude` for complex values is that it is
finite and non-zero for any finite non-zero value:
- Unlike Euclidean length (`\.length`, $\sqrt{x^2 + y^2}$), which can overflow
  to infinity if $x^2 + y^2$ exceeds the maximum representable finite value or
  underflow if both components are tiny, `\.magnitude` never overflows or underflows
  for finite numbers.
- It avoids intermediate squaring, square roots, or the complex scaling logic of
  `hypot`, making it robust even when handling very poorly scaled values.

If you specifically need to test whether a complex number lies inside a circular
disk of radius `0.001` centered at `1 + 0i` rather than a square box, you can
pass the Euclidean length as the norm:

```swift
import ComplexModule

z.isApproximatelyEqual(
  to: 1,
  absoluteTolerance: 0.001,
  norm: \.length
)
```

## Mathematical properties

For any fixed tolerance, approximate equality is _reflexive_ on
non-exceptional values and _symmetric_: if `a` is approximately equal to `b`,
then `b` is approximately equal to `a`.

It is **not transitive**. `a` can be approximately equal to `b`, and `b` to
`c`, while `a` and `c` differ by more than the tolerance. Approximate equality
is therefore **not** an equivalence relation, even when restricted to
non-exceptional values. For this reason you must not use it to implement a
conformance to `Equatable`: doing so would violate the invariants that generic
code written against `Equatable` relies on.

For any point `a`, the set of values that compare approximately equal to `a`
is _convex_ (under the assumption that `norm` implements a valid norm).
