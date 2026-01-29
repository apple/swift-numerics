# Notes on Complex Division

A discussion of the algorithms used to implement complex division

## Overview

How does compute the quotient of two complex numbers z/w? The naïve schoolbook
answer is to turn it into complex multiplication by scaling both numerator and
denominator by the conjugate of w: z/w = (zw̅)/(ww̅) = (zw̅)/|w|². Translated
directly into swift, this expression would become:

```swift
extension Complex {
  func naïveDivision(_ z: Complex, _ w: Complex) -> Complex {
    (z * w.conjugate).divded(by: w.lengthSquared)
  }
}
```

If both z and w are both "well-scaled" (i.e. their exponents are neither very
large nor very small), then this expression works reasonably well when 
evaluated in floating-point. Cancellation may occur in the computation of
either the real or the imaginary part of the zw̅ term, but not in both 
simultaneously, so the relative error in any vector norm is bounded by a 
small multiple of machine epsilon.

However, if z or w is not well-scaled, then either zw̅ or |w|² or both may
underflow or overflow, even when the actual quotient may be perfectly
representable. For example, if we have

```swift
let a: Float = 1.84467441E+19 // large, but not outrageously large
let z = Complex(a, a)
let w = z
```

then both `(z * w.conjugate)` and `w.lengthSquared` overflow, and the result
of `naïveDivision` is `(NaN, NaN)` even though the actual mathematical quotient
is 1.

At least `(NaN, NaN)` is obviously wrong; when intermediate results underflow
instead of overflow, we can instead get bogus results that are not obvious at
all. For example:

```swift 
let z = Complex<Float>(imaginary: 6.6174449e-24)
let w = Complex<Float>(5.29395592e-23, 3.97046694e-23)
let q = naïveDivision(z, w)
```

`q` is computed as `(0.666666686, 0.666666686)`, which looks like a reasonable
result, but the exact `z/w` would be `(0.6, 0.8)`; both the phase and magnitude
of the computed result have large errors, and there is no indication that
anything went wrong.

## Complex division in Swift Numerics

### Goals

Programming languages and libraries have developed a variety of approaches to 
handle this problem. Swift Numerics' approach is somewhat novel, so I will
first lay out the considerations that lead us to it.

1. Division should be reasonably fast, and permit compiler optimizations that 
   make it faster. So long as all inputs are well-scaled, it should not be
   much slower than multiplication.

2. Division should have the same error characteristics as multiplication;
   componentwise error bounds and correct rounding are non-goals. Good error
   bounds in a complex norm are what matters.

3. Division should not be any more sensitive to undue overflow or underflow
   than multiplication is (i.e. it is OK for results very near the boundaries
   to overflow or underflow even though the exact result would be
   representable, but results that are far from those boundaries should always
   be computed with good accuracy).

### Fast path

These considerations lead us to a first draft of our implementation; since we
want division to be roughly like multiplication, we will "simply" turn it into
a multiplication via the naïve formula:

```swift
public static func /(z: Complex, w: Complex) -> Complex {
  let lenSq = w.lengthSquared
  guard lenSq.isNormal else { /* naive formula will not work */ }
  return z * w.conjugate.divided(by: lenSq)
}
```

if `lenSq` can be computed without overflow or underflow, then
`w.conjugate.divided(by: lenSq)` is a (rounded) reciprocal `1/w`, and so
multiplying that by `z` satisfies the goals that we laid out above. Note
in particular that if we are dividing multiple values by a single divisor,
the reciprocal is a constant, and this check only has to happen once.

That leaves us just needing to figure out what to do when the reciprocal
is not well-scaled.

### Slow path

When an approximate reciprocal for the divisor is not representable, we use
a scaling algorithm adapted from Doug Priest's "Efficient Scaling for
Complex Division". In hand-wavy form, Priest's idea is:

1. choose a scale factor s ~ |w|^(-¾)
2. let wʹ ← sw
2. let zʹ ← sz

Note that we _can_ compute a reciprocal for wʹ without overflow or underflow,
because |wʹ| ~ |w|^(¼), so |wʹ²| ~ |w|^(½) and so |w̅ʹ/wʹ²| ~ |w|^(-¼).¹
To compute z/w, we compute zʹ/wʹ. sz might overflow or underflow, but only
if the final computation would overflow or underflow anyway. This is because
division by w is a dilation combined with a rotation; because |w| is bounded
away from 1, the multiplication by s is a dilation if and only if division 
by w is also dilation (this is where we diverge from Priest; because he
doesn't have a fast-path for well-scaled w, he has to handle this case 
carefully).

Like Priest, we arrange for s to be a power of the radix with the desired
scale, which makes the computation of wʹ and zʹ exact (unless zʹ over- or
underflows). This achieves one more desirable property: barring underflow,
rescaling both w and z by the radix does not change results when we move
between the fast and slow algorithms.

Instead of `zʹ/wʹ = zʹ(w̅ʹ/|wʹ|²)`, Priest uses `(zw″)/|wʹ|²`. There isn't
a strong reason to favor one or the other numerically, but our formulation
lets us preserve `z/w = z * w.reciprocal` under scaling by powers of the
radix (up to the underflow boundary), which is somewhat nice to have, and
allows us to extract a little bit more ILP in some cases.

----
### Notes

¹ This analysis fails for types like Float16 where the number of
significand bits is on the order of the greatest exponent because the desired
s may not be representable if w is subnormal. Note that the problem is _only_
in the representation of s, so we can handle this case by rescaling in two
steps.
