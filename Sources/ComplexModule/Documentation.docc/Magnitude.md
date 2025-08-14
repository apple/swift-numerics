# Magnitude and norms

Introduction to the concept of norm and discussion of the `Complex` type's
`.magnitude` property.

## Overview

In mathematics, a *norm* is a function that gives each element of a vector
space a non-negative length.¹

Many different norms can be defined on the complex numbers, viewed as a
vector space over the reals. All of these norms have some basic
properties. If we use *‖z‖* to represent any norm of *z*, it must:
- be *subadditive* (a.k.a. satisfy the triangle inequalty):
  ‖z + w‖ ≤ ‖z‖ + ‖w‖ for any two complex numbers z and w.
- be *homogeneous*
  ‖az‖ = |a|‖z‖ for any real number a and complex number z.
- and be *positive definite*
  ‖z‖ is zero if and only if z is zero.

The three most commonly-used norms are:
- 1-norm ("taxicab norm"):
  ‖x + iy‖₁ = |x| + |y|
- 2-norm ("Euclidean norm"):
  ‖x + iy‖₂ = √(x² + y²)
- ∞-norm ("maximum norm" or "Чебышёв [Chebyshev] norm")²:
  ‖x + iy‖ = max(|x|,|y|)

> Exercise:
> 1. Check that these properties hold for one of the three norms
     that we just defined. (Hint: write z = a+bi and w = c+di,
     and use the fact that the absolute value is a norm on the
     real numbers, and therefore has the same property).

The `Complex` type gives special names to two of these norms; `length`
for the 2-norm, and `magnitude` for the ∞-norm.

### Magnitude:

The `Numeric` protocol requires us to choose a norm to call `magnitude`,
but does not give guidance as to which one we should pick. The easiest choice
might have been the Euclidean norm; it's the one with which people are most
likely to be familiar.

However, there are good reasons to make a different choice:
- Computing the Euclidean norm requires special care to avoid spurious
  overflow/underflow (see implementation notes for `length` below). The
  naive expressions for the taxicab and maximum norm always give the best
  answer possible.
- Even when special care is used, the Euclidean and taxicab norms are
  not necessarily representable. Both can be infinite even for finite
  numbers.
  
  ```swift
  let big = Double.greatestFiniteMagnitude
  let z = Complex(big, big)
  ```
  
  The taxicab norm of `z` would be `big + big`, which overflows; the
  Euclidean norm would be `sqrt(2) * big`, which also overflows.
  But the maximum norm is always equal to the magnitude of either `real`
  or `imaginary`, so it is necessarily representable.
- The ∞-norm is the choice of established computational libraries, like
  BLAS and LAPACK.

For these reasons, the `magnitude` property of `Complex` binds the
maximum norm:

```swift
Complex(2, 3).magnitude    // 3
Complex(-1, 0.5).magnitude // 1
```

### Length:

The `length` property of a `Complex` value is its Euclidean norm.

```swift
Complex(2, 3).length    // 3.605551275463989
Complex(-1, 0.5).length // 1.118033988749895
```

Aside from familiarity, the Euclidean norm has one important property
that the maximum norm lacks:
- it is *multiplicative*:
  ‖zw‖₂ = ‖z‖₂‖w‖₂ for any two complex numbers z and w.

> Exercises:
> 1. Find z and w that show that the maximum norm is not multiplicative.
  (i.e. exhibit z and w such that ‖zw‖ ≠ ‖z‖‖w‖.)
> 2. Is the 1-norm multiplicative?

### Implementation notes:

The `length` property takes special care to produce an accurate answer,
even when the value is poorly-scaled. The naive expression for `length`
would be `sqrt(x*x + y*y)`, but this can overflow or underflow even when
the final result should be a finite number.

```swift
// Suppose that length were implemented like this:
extension Complex {
  var naiveLength: RealType {
    .sqrt(real*real + imaginary*imaginary)
  }
}

// Then taking the length of even a modestly large number:
let z = Complex<Float>(1e20, 1e20)
// or small number:
let w = Complex<Float>(1e-24, 1e-24)
// would overflow:
z.naiveLength // Inf
// or underflow:
w.naiveLength // 0
```

Instead, `length` is implemented using a two-step algorithm. First we
compute `lengthSquared`, which is `x*x + y*y`. If this is a normal
number (meaning that no overflow or underflow has occured), we can safely
return its square root. Otherwise, we redo the computation with a more
careful computation, which avoids spurious under- or overflow:

```swift
let z = Complex<Float>(1e20, 1e20)
let w = Complex<Float>(1e-24, 1e-24)
z.length // 1.41421358E+20
w.length // 1.41421362E-24
```

### Footnotes:

¹ Throughout this documentation, "norm" refers to a
  [vector norm](https://en.wikipedia.org/wiki/Norm_(mathematics)).
  To confuse the matter, there are several similar things also called
  "norm" in mathematics. The other one you are most likely to run into
  is the [field norm](https://en.wikipedia.org/wiki/Field_norm).
  
  Field norms are much less common than vector norms, but the C++
  `std::norm` operation implements a field norm. To get the (Euclidean)
  vector norm in C++, use `std::abs`.

² There's no subscript-∞ in unicode, so I write the infinity norm
  without the usual subscript.
