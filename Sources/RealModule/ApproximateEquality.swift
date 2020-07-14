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
  /// Compares `self` and `other` for approximate equality with a specified
  /// relative tolerance and implicit absolute tolerance.
  ///
  /// `true` if `self` and `other` are equal, or if they are finite and
  /// ```
  /// (self - other).magnitude ≤ relativeTolerance * scale
  /// ```
  /// where `scale` is
  /// ```
  /// max(self.magnitude, other.magnitude, .leastNormalMagnitude)
  /// ```
  ///
  /// The default value of `relativeTolerance` is `.ulpOfOne.squareRoot()`,
  /// which corresponds to expecting "about half the digits" in the computed results to be good.
  /// This is the usual guidance in numerical analysis, if you don't know anything about the
  /// computation being performed, but is not suitable for all use cases.
  ///
  /// Mathematical Properties:
  /// -
  /// - `isApproximatelyEqual(to:relativeTolerance:)` is _reflexive_ for
  ///   non-exceptional values (such as NaN).
  ///
  /// - `isApproximatelyEqual(to:relativeTolerance:)` is _symmetric_.
  ///
  /// - `isApproximatelyEqual(to:relativeTolerance:)` is __not__ _transitive_.
  ///   Because of this, approximately equality is __not an equivalence relation__,
  ///   even when restricted to non-exceptional values.
  ///
  /// - For any point `a`, the set of values that compare approximately equal to `a` is _convex_.
  ///   (Under the assumption that the `.magnitude` property implements a valid norm.)
  ///
  /// - `isApproximatelyEqual(to:relativeTolerance:)` is _scale invariant_,
  ///   so long as no underflow or overflow has occured, and no exceptional value is produced
  ///   by the scaling.
  ///
  /// - Parameters:
  ///
  ///   - other: The value to which `self` is compared.
  ///
  ///   - relativeTolerance: The tolerance to use for the comparison.
  ///     Defaults to `.ulpOfOne.squareRoot()`.
  ///
  ///     This value should be non-negative and less than or equal to 1.
  ///     This constraint on is only checked in debug builds, because a mathematically
  ///     well-defined result exists for any tolerance, even one out of range.
  @inlinable @inline(__always)
  public func isApproximatelyEqual(
    to other: Self,
    relativeTolerance: Magnitude = Magnitude.ulpOfOne.squareRoot()
  ) -> Bool {
    return isApproximatelyEqual(
      to: other,
      absoluteTolerance: relativeTolerance * Magnitude.leastNormalMagnitude,
      relativeTolerance: relativeTolerance
    )
  }
  
  /// Compares `self` and `other` for approximate equality with specified tolerances.
  ///
  /// `true` if `self` and `other` are equal, or if they are finite and either
  /// ```
  /// (self - other).magnitude ≤ absoluteTolerance
  /// ```
  /// or
  /// ```
  /// (self - other).magnitude ≤ relativeTolerance * scale
  /// ```
  /// where `scale` is `max(self.magnitude, other.magnitude)`.
  ///
  /// Mathematical Properties:
  /// -
  /// - `isApproximatelyEqual(to:absoluteTolerance:relativeTolerance:)`
  ///   is _reflexive_ for non-exceptional values (such as NaN).
  ///
  /// - `isApproximatelyEqual(to:absoluteTolerance:relativeTolerance:)`
  ///   is _symmetric_.
  ///
  /// - `isApproximatelyEqual(to:absoluteTolerance:relativeTolerance:)`
  ///   is __not__ _transitive_. Because of this, approximately equality is
  ///   __not an equivalence relation__, even when restricted to non-exceptional values.
  ///
  /// - For any point `a`, the set of values that compare approximately equal to `a` is _convex_.
  ///   (Under the assumption that `norm` implements a valid norm, which cannot be checked
  ///   by this function.)
  ///
  /// - Parameters:
  ///
  ///   - other: The value to which `self` is compared.
  ///
  ///   - absoluteTolerance: The absolute tolerance to use in the comparison.
  ///
  ///     This value should be non-negative and finite.
  ///     This constraint on is only checked in debug builds, because a mathematically
  ///     well-defined result exists for any tolerance, even one out of range.
  ///
  ///   - relativeTolerance: The relative tolerance to use in the comparison.
  ///     Defaults to zero.
  ///
  ///     This value should be non-negative and less than or equal to 1.
  ///     This constraint on is only checked in debug builds, because a mathematically
  ///     well-defined result exists for any tolerance, even one out of range.
  ///
  ///   - norm: The norm to use for the comparison. Defaults to the `.magnitude`
  ///     property.
  ///
  ///     When porting code or working with specialized algorithms, it may
  ///     be desirable to override the norm. For example, if we wanted to test if
  ///     a complex value was inside a circle of radius 0.001 centered at (1 + 0i), we
  ///     could use:
  ///     ```
  ///     z.isApproximatelyEqual(
  ///       to: 1,
  ///       absoluteTolerance: 0.001,
  ///       norm: \.length
  ///     )
  ///     ```
  ///     (if we used the default, we would be testing if `z` were inside a square region
  ///     instead.)
  @inlinable @inline(__always)
  public func isApproximatelyEqual(
    to other: Self,
    absoluteTolerance: Magnitude,
    relativeTolerance: Magnitude = 0,
    norm: (Self) -> Magnitude = { $0.magnitude }
  ) -> Bool {
    assert(
      absoluteTolerance >= 0 && absoluteTolerance.isFinite,
      "absoluteTolerance should be non-negative and finite, " +
      "but is \(absoluteTolerance)."
    )
    assert(
      relativeTolerance >= 0 && relativeTolerance <= 1,
      "relativeTolerance should be non-negative and <= 1, " +
      "but is \(relativeTolerance)."
    )
    if self == other { return true }
    let delta = norm(self - other)
    let scale = max(norm(self), norm(other))
    let bound = max(absoluteTolerance, scale*relativeTolerance)
    return delta.isFinite && delta <= bound
  }
}
