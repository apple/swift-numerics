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

/// A tolerance to use for approximate comparisons
///
/// These values are consumed by the `approximatelyEquals` method defined on `Numeric`
/// whenever the `Magnitude` associated type conforms to floating-point.
public enum Tolerance<T: FloatingPoint> {
  case relative(_ tolerance: T = T.ulpOfOne.squareRoot(), minimumScale: T = .leastNormalMagnitude)
  case absolute(_ tolerance: T)
}

extension Numeric where Magnitude: FloatingPoint {
  /// Approximate equality comparison
  ///
  /// Due to rounding of intermediate results, "the same" value computed using
  /// two different techniques frequently has slightly different results in
  /// floating-point arithmetic. This comparison method may be helpful in
  /// these situations.
  ///
  /// The simplest use of this method looks like:
  /// ```
  /// a.approximatelyEquals(b)
  /// ```
  /// when used like this, the result is true if `a ` and `b` agree to about
  /// half the representable significant digits, which is the usual naive
  /// guidance in numerical analysis ("if you don't have a careful analysis,
  /// half your bits are probably bad").
  ///
  /// You can specify a tolerance to use for more specialized scenarios.
  /// Three types of tolerance are supported:
  ///
  /// - `.absolute(t)`
  ///   `a` is approximately equal to `b` with absolute tolerance `t` if
  ///   ```
  ///   (a - b).magnitude < t
  ///   ```
  ///   The trouble with an absolute tolerance is that it only makes sense
  ///   when you know the expected scale of the `a` and `b`, but the *raison d'être*
  ///   of floating-point numbers is to avoid scale dependent computations as much
  ///   as possible. Because of this absolute tolerances are often a bad choice,
  ///   unless you have very specific requirements.
  ///
  ///   There is no default absolute tolerance, because it's impossible for a general-purpose
  ///   library to know what the scale of the values being compared might be.
  ///
  ///   However, when you do know the scale of an expected result, this can be an excellent
  ///   choice. For example, suppose we want to repeat an iterative process until the result
  ///   is within `0.1` of π:
  ///   ```
  ///   while !result.approximatelyEquals(.pi, tolerance: .absolute(0.1)) {
  ///   }
  ///   ```
  ///   The tolerance `t` must be positive and finite.
  ///
  /// - `.relative(t)`
  ///   `a` and `b` are approximately equal with relative tolerance `t` if
  ///   ```
  ///   let scale = max(a.magnitude, b.magnitude, .leastNormalMagnitude)
  ///   return (a - b).magnitude < t * scale
  ///   ```
  ///   This type of tolerance matches well with the scale invariance of floating-point,
  ///   making it a good choice for most problems. If you do not specify a tolerance,
  ///   `approximatelyEquals` uses a relative tolerance of `sqrt(ulpOfOne)`.
  ///
  ///   The tolerance `t` must be in `.ulpOfOne ..< 1`.
  ///
  /// - `.relative(t, minimumScale: s)`
  ///   In some cases it is desirable to override the `minimumScale` used in a relative
  ///   comparison (either by setting it to zero, so that there is no rolloff at zero, or by setting it
  ///   to a much larger value to account for cancellation). When a `minimumScale` is
  ///   specified, the computation performed is:
  ///   ```
  ///   let scale = max(a.magnitude, b.magnitude, minimumScale)
  ///   return (a - b).magnitude < t * scale
  ///   ```
  ///   The tolerance `t` must be in `.ulpOfOne ..< 1`.  The `minimumScale` must
  ///   be positive and finite.
  ///
  /// - Parameters:
  ///   - other: The value to compare.
  ///   - tolerance: Either `.relative(...)` or `.absolute(t)`.
  @inlinable
  public func approximatelyEquals(
    _ other: Self,
    tolerance: Tolerance<Magnitude> = .relative()
  ) -> Bool {
    // If a and b are actually equal, then they are certainly *almost* equal,
    // with any allowable tolerance.
    if self == other { return true }
    let delta = (self - other).magnitude
    switch tolerance {
    case let .absolute(atol):
      assert(atol > 0 && atol.isFinite, "Absolute tolerance must be positive and finite.")
      return delta < atol
    case let .relative(rtol, floor):
      assert(rtol >= .ulpOfOne && rtol < 1, "Relative tolerance must be in [.ulpOfOne, 1).")
      assert(floor >= 0 && floor.isFinite, "Minimum scale must be positive and finite.")
      let scale = max(self.magnitude, other.magnitude, floor)
      return delta < scale*rtol
    }
  }
}
