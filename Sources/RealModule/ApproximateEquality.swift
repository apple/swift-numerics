//===--- ApproximateEquality.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Numeric where Magnitude: FloatingPoint {
  /// Compares `self` and `other` for approximate equality with default
  /// tolerances.
  ///
  /// `a.isApproximatelyEqual(to: b)` is `true` if `a` and `b`
  /// are equal, or if both are finite and `|a - b| ≤ √u * max(|a|,|b|,n)`,
  /// where `||` is the norm computed by the `.magnitude` property,
  /// `u` is `.ulpOfOne`, and `n` is `.leastNormalMagnitude`.
  ///
  /// Due to rounding of intermediate results, "the same" value computed using
  /// two different techniques frequently has slightly different results in
  /// floating-point arithmetic. This comparison method may be helpful in
  /// these situations.
  ///
  /// ```
  /// a.isApproximatelyEqual(to: b)
  /// ```
  /// is true if `a ` and `b` agree to about half the representable
  /// significant digits, which is the usual naive guidance in numerical
  /// analysis ("if you don't have a careful analysis, half your bits
  /// are probably bad").
  ///
  /// More precisely, the call shown above is exactly equivalent to:
  /// ```
  /// let rtol = Magnitude.ulpOfOne.squareRoot()
  /// a.isApproximatelyEqual(to: b, relativeTolerance: rtol)
  /// ```
  /// or:
  /// ```
  /// let rtol = Magnitude.ulpOfOne.squareRoot()
  /// let atol = Magnitude.leastNormalMagnitude * rtol
  /// a.isApproximatelyEqual(to: b,
  ///   relativeTolerance: rtol,
  ///   absoluteTolerance: atol
  /// )
  /// ```
  /// Consult the documentation for those methods for a detailed
  /// description of how the comparison is performed, and how to
  /// choose tolerances for your particular situation.
  @inlinable @inline(__always)
  public func isApproximatelyEqual(
    to other: Self
  ) -> Bool {
    return isApproximatelyEqual(
      to: other,
      relativeTolerance: Magnitude.ulpOfOne.squareRoot()
    )
  }
  
  /// Compares `self` and `other` for approximate equality with a specified
  /// relative tolerance and implicit absolute tolerance.
  ///
  /// If we ignore underflow and overflow for the moment, floating-point arithmetic
  /// is scale-invariant. Because of this, a _relative_ comparison usually
  /// makes the most sense when defining approximate equality.
  ///
  /// Normally in mathematics, comparison for relative approximate equality looks like:
  /// ```
  /// |a - b| ≤ tolerance * max(|a|,|b|)
  /// ```
  /// where `|a|` is the magnitude of `a` measured by some _norm_.
  ///
  /// However, floating-point is not perfectly scale-invariant when underflow occurs,
  /// so we slightly modify the definition of relative comparison to account for this,
  /// and use the following instead:
  /// ```
  /// |a - b| ≤ tolerance * max(|a|,|b|,n)
  /// ```
  /// where `n` is `.leastNormalMagnitude`, or equivalently:
  /// ```
  /// |a - b| ≤ max(tolerance*n, tolerance*max(|a|,|b|))
  /// ```
  /// This means that the actual error allowed for all subnormal values is exactly
  /// the tolerance allowed for the smallest normal value. If you want to avoid this
  /// special handling for subnormal values, pass an explicit
  /// `absoluteTolerance: 0` parameter.
  ///
  /// Scale-invariance also breaks down when overflow occurs, but in that case no
  /// useful comparison is recoverable, so we simply do not try; infinity compares
  /// not equal to any finite value with any allowed tolerance.
  @inlinable @inline(__always)
  public func isApproximatelyEqual(
    to other: Self,
    relativeTolerance: Magnitude
  ) -> Bool {
    return isApproximatelyEqual(
      to: other,
      relativeTolerance: relativeTolerance,
      absoluteTolerance: relativeTolerance * Magnitude.leastNormalMagnitude
    )
  }
  
  /// Compares `self` and `other` for approximate equality with a specified tolerances.
  ///
  /// `a.isApproximatelyEqual(to: b, relativeTolerance: rtol, absoluteTolerance: atol)`
  /// is `true` if a and b are equal, or if they are finite and
  /// ```
  /// |a - b| ≤ max(atol, rtol * max(|a|,|b|))
  /// ```
  ///
  /// Note that if `relativeTolerance` is omitted or is zero, a pure absolute tolerance is used:
  /// ```
  /// |a - b| ≤ atol
  /// ```
  ///
  /// If `absoluteTolerance` is zero, a pure relative tolerance is used:
  /// ```
  /// |a - b| ≤ rtol * max(|a|,|b|)
  /// ```
  ///
  /// Note that if `absoluteTolerance` is _omitted_,
  /// `relativeTolerance * .leastNormalMagnitude` is used, _not zero_.
  @inlinable
  public func isApproximatelyEqual(
    to other: Self,
    relativeTolerance: Magnitude = 0,
    absoluteTolerance: Magnitude
  ) -> Bool {
    assert(absoluteTolerance >= 0 && absoluteTolerance.isFinite)
    assert(relativeTolerance >= 0 && relativeTolerance <= 1)
    if self == other { return true }
    let delta = (self - other).magnitude
    let scale = max(self.magnitude, other.magnitude)
    let bound = max(absoluteTolerance, scale*relativeTolerance)
    return delta.isFinite && delta <= bound
  }
}
