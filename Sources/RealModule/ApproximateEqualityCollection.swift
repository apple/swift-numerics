//===--- ApproximateEqualityCollection.swift ------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020-2026 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension RandomAccessCollection where Element: Numeric, Element.Magnitude: FloatingPoint {
  /// Test if `self` and `other` have approximately equal elements.
  ///
  /// Returns `true` if the collections have the same count and each pair of
  /// corresponding elements compare approximately equal using the specified
  /// tolerances.
  ///
  /// This performs an element-wise comparison. For vectors or matrices,
  /// you may want to compare using a vector or operator norm instead.
  ///
  /// For more information on element-wise approximate equality, see
  /// ``Numeric/isApproximatelyEqual(to:relativeTolerance:norm:)`` method.
  ///
  /// - Parameters:
  ///
  ///   - other: The collection to which `self` is compared.
  ///
  ///   - relativeTolerance: The tolerance to use for the comparison.
  ///     Defaults to `.ulpOfOne.squareRoot()`.
  ///
  ///     This value should be non-negative and less than or equal to 1.
  ///     This constraint is only checked in debug builds.
  ///
  ///   - norm: The [norm] to use for the comparison of each element.
  ///     Defaults to `\.magnitude`.
  ///
  /// - SeeAlso: ``isElementwiseApproximatelyEqual(to:absoluteTolerance:relativeTolerance:)``
  ///
  /// [norm]: https://en.wikipedia.org/wiki/Norm_(mathematics)
  @inlinable @inline(__always)
  public func isElementwiseApproximatelyEqual(
    to other: Self,
    relativeTolerance: Element.Magnitude = Element.Magnitude.ulpOfOne.squareRoot(),
    norm: (Element) -> Element.Magnitude = \.magnitude
  ) -> Bool {
    return isElementwiseApproximatelyEqual(
      to: other,
      absoluteTolerance: relativeTolerance * Element.Magnitude.leastNormalMagnitude,
      relativeTolerance: relativeTolerance,
      norm: norm
    )
  }

  /// Test if `self` and `other` have approximately equal elements with
  /// specified tolerances.
  ///
  /// Returns `true` if the collections have the same count and each pair of
  /// corresponding elements compare approximately equal using the specified
  /// tolerances.
  ///
  /// This performs an element-wise comparison. For vectors or matrices,
  /// you may want to compare using a vector or operator norm instead.
  ///
  /// For more information on element-wise approximate equality, see
  /// ``Numeric/isApproximatelyEqual(to:relativeTolerance:norm:)`` method.
  ///
  /// - Parameters:
  ///
  ///   - other: The collection to which `self` is compared.
  ///
  ///   - absoluteTolerance: The absolute tolerance to use in the comparison.
  ///
  ///     This value should be non-negative and finite.
  ///     This constraint is only checked in debug builds.
  ///
  ///   - relativeTolerance: The relative tolerance to use in the comparison.
  ///     Defaults to zero.
  ///
  ///     This value should be non-negative and less than or equal to 1.
  ///     This constraint is only checked in debug builds.
  ///
  /// - SeeAlso: ``isElementwiseApproximatelyEqual(to:relativeTolerance:norm:)``
  @inlinable @inline(__always)
  public func isElementwiseApproximatelyEqual(
    to other: Self,
    absoluteTolerance: Element.Magnitude,
    relativeTolerance: Element.Magnitude = 0
  ) -> Bool {
    return isElementwiseApproximatelyEqual(
      to: other,
      absoluteTolerance: absoluteTolerance,
      relativeTolerance: relativeTolerance,
      norm: \.magnitude
    )
  }
}

extension RandomAccessCollection where Element: AdditiveArithmetic {
  /// Test if `self` and `other` have approximately equal elements with
  /// specified tolerances and norm.
  ///
  /// Returns `true` if the collections have the same count and each pair of
  /// corresponding elements compare approximately equal using the specified
  /// tolerances and norm.
  ///
  /// This performs an element-wise comparison. For vectors or matrices,
  /// you may want to compare using a vector or operator norm instead.
  ///
  /// This method performs element-wise comparison using each element's
  /// ``AdditiveArithmetic/isApproximatelyEqual(to:absoluteTolerance:relativeTolerance:norm:)`` method.
  ///
  /// - Parameters:
  ///
  ///   - other: The collection to which `self` is compared.
  ///
  ///   - absoluteTolerance: The absolute tolerance to use in the comparison.
  ///
  ///     This value should be non-negative and finite.
  ///     This constraint is only checked in debug builds.
  ///
  ///   - relativeTolerance: The relative tolerance to use in the comparison.
  ///     Defaults to zero.
  ///
  ///     This value should be non-negative and less than or equal to 1.
  ///     This constraint is only checked in debug builds.
  ///
  ///   - norm: The norm to use for the comparison of each element.
  @inlinable
  public func isElementwiseApproximatelyEqual<Magnitude>(
    to other: Self,
    absoluteTolerance: Magnitude,
    relativeTolerance: Magnitude = 0,
    norm: (Element) -> Magnitude
  ) -> Bool
  where Magnitude: FloatingPoint {
    guard self.count == other.count else { return false }
    for (lhs, rhs) in zip(self, other) {
      if !lhs.isApproximatelyEqual(
        to: rhs,
        absoluteTolerance: absoluteTolerance,
        relativeTolerance: relativeTolerance,
        norm: norm
      ) {
        return false
      }
    }
    return true
  }
}
