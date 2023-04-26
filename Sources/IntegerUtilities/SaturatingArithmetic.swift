//===--- SaturatingArithmetic.swift ---------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension FixedWidthInteger {
  @_transparent @usableFromInline
  var signExtension: Self { self &>> -1 }
  
  /// Saturating integer addition
  ///
  /// `self + other` clamped to the representable range of the type. e.g.:
  /// ```
  /// let a: Int8 = 84
  /// let b: Int8 = 100
  /// // 84 + 100 = 184 is not representable as
  /// // Int8, so `c` is clamped to Int8.max (127).
  /// let c = a.addingWithSaturation(b)
  /// ```
  ///
  /// Anytime the "normal addition" `self + other` does not trap,
  /// `addingWithSaturation` produces the same result.
  @inlinable
  public func addingWithSaturation(_ other: Self) -> Self {
    let (wrapped, overflow) = addingReportingOverflow(other)
    if !overflow { return wrapped }
    return Self.max &- signExtension
  }
  
  /// Saturating integer subtraction
  ///
  /// `self - other` clamped to the representable range of the type. e.g.:
  /// ```
  /// let a: UInt = 37
  /// let b: UInt = 42
  /// // 37 - 42 = -5, which is not representable as
  /// // UInt, so `c` is clamped to UInt.min (zero).
  /// let c = a.subtractingWithSaturation(b)
  /// ```
  ///
  /// Note that `a.addingWithSaturation(-b)` is not always equivalent to
  /// `a.subtractingWithSaturation(b)`, because `-b` is not representable
  /// if `b` is the minimum value of a signed type.
  ///
  /// Anytime the "normal subtraction" `self - other` does not trap,
  /// `subtractingWithSaturation` produces the same result.
  @inlinable
  public func subtractingWithSaturation(_ other: Self) -> Self {
    let (wrapped, overflow) = subtractingReportingOverflow(other)
    if !overflow { return wrapped }
    return Self.max &- signExtension
  }
  
  /// Saturating integer negation
  ///
  /// For unsigned types, the result is always zero. This is not very
  /// interesting, but may occasionally be useful in generic contexts.
  /// For signed types, the result is `-self` unless `self` is `.min`,
  /// in which case the result is `.max`.
  @inlinable
  public func negatedWithSaturation() -> Self {
    Self.zero.subtractingWithSaturation(self)
  }
  
  /// Saturating integer multiplication
  ///
  /// `self * other` clamped to the representable range of the type. e.g.:
  /// ```
  /// let a: Int8 = -16
  /// let b: Int8 = -8
  /// // -16 * -8 = 128 is not representable as
  /// // Int8, so `c` is clamped to Int8.max (127).
  /// let c = a.multipliedWithSaturation(by: b)
  /// ```
  ///
  /// Anytime the "normal multiplication" `self * other` does not trap,
  /// `multipliedWithSaturation` produces the same result.
  @inlinable
  public func multipliedWithSaturation(by other: Self) -> Self {
    let (high, low) = multipliedFullWidth(by: other)
    let wrapped = Self(truncatingIfNeeded: low)
    if high == wrapped.signExtension { return wrapped }
    return Self.max &- high.signExtension
  }
  
  /// Bitwise left with rounding and saturation.
  ///
  /// `self` multiplied by the rational number 2^(`count`), saturated to the
  /// range `Self.min ... Self.max`, and rounded according to `rule`.
  ///
  /// See `shifted(rightBy:rounding:)` for more discussion of rounding
  /// shifts with examples.
  ///
  /// - Parameters:
  ///   - leftBy count: the number of bits to shift by. If positive, this is a left-shift,
  ///   and if negative a right shift.
  ///   - rounding rule: the direction in which to round if `count` is negative.
  @inlinable
  public func shiftedWithSaturation<Count: BinaryInteger>(
    leftBy count: Count, rounding rule: RoundingRule = .down
  ) -> Self {
    // If count is zero or negative, negate it and do a right
    // shift without saturation instead, as that's easier.
    guard count > 0 else {
      return shifted(
        rightBy: Self(clamping: count).negatedWithSaturation(),
        rounding: rule
      )
    }
    guard count < Self.bitWidth else {
      // If count is bitWidth or greater, we always overflow
      // unless self is zero.
      return self == 0 ? 0 : Self.max &- signExtension
    }
    // Now we have 0 < count < bitWidth, so we can use a nice
    // straightforward implementation; the shift overflows if
    // the complementary shift doesn't match sign extension.
    let wrapped = self << count
    if self &>> ~count == signExtension { return wrapped }
    return Self.max &- signExtension
  }
}
