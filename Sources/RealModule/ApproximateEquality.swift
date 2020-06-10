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
  case absolute(_ tolerance: T = T.ulpOfOne.squareRoot())
}

extension Numeric where Magnitude: FloatingPoint {
  /// Approximate equality comparison
  ///
  /// Due to rounding of intermediate results, "the same" value computed using two different techniques
  /// frequently has a slightly different result in floating-point arithmetic. This comparison method may
  /// be helpful in these situations.
  ///
  /// By default, this method performs a relative comparison with a minimum scale set to the underflow
  /// threshold and a tolerance of √ulpOfOne. This is as sensible a default as any.
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
