# Quaternion

This module provides a `Quaternion` type generic over an underlying `RealType`:

```swift
1> import QuaternionModule
2> let q = Quaternion(real: 1, imaginary: 1, 1, 1) // q = 1 + i + j + k
```

The usual arithmetic operators are provided for Quaternions, many useful properties, plus conformances to the
obvious usual protocols: `Equatable`, `Hashable`, `Codable` (if the underlying `RealType` is), and `AlgebraicField`
(hence also `AdditiveArithmetic` and `SignedNumeric`).

### Dependencies:
- `RealModule`.

### The magnitude property
The `Numeric` protocol requires a `.magnitude` property, but (deliberately) does not fully specify the semantics.
The most obvious choice for `Quaternion` would be to use the Euclidean norm (aka the "2-norm", given by `sqrt(real*real + i*i + k*k + j*j)`).
However, in practice there are good reasons to use something else instead:

- The 2-norm requires special care to avoid spurious overflow/underflow, but the naive expressions for the 1-norm ("taxicab norm") or ∞-norm ("sup norm") are always correct.
- Even when care is used, near the overflow boundary the 2-norm and the 1-norm are not representable.
  As an example, consider `q = Quaternion(big, (big, big, big))`, where `big` is `Double.greatestFiniteMagnitude`. The 1-norm and 2-norm of `q` both overflow (the 1-norm would be `4*big`, and the 2-norm would be `sqrt(4)*big`, neither of which are representable as `Double`), but the ∞-norm is always equal to either `real`, `i`, `j` or `k`, so it is guaranteed to be representable.
Because of this, the ∞-norm is the obvious alternative; it gives the nicest API surface.
- If we consider the magnitude of more exotic types, like operators, the 1-norm and ∞-norm are significantly easier to compute than the 2-norm (O(n) vs. "no closed form expression, but O(n^3) iterative methods"), so it is nice to establish a precedent of `.magnitude` binding one of these cheaper-to-compute norms.
- The ∞-norm is heavily used in other computational libraries; for example, it is used by the `izamax` and `icamax` functions in BLAS.

The 2-norm still needs to be available, of course, because sometimes you need it.
This functionality is accessed via the `.length` and `.lengthSquared` properties.
