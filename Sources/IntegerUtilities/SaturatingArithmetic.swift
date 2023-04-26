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
  
  @inlinable
  public func addingWithSaturation(_ other: Self) -> Self {
    let (wrapped, overflow) = addingReportingOverflow(other)
    if !overflow { return wrapped }
    return Self.max &- signExtension
  }
  
  @inlinable
  public func subtractingWithSaturation(_ other: Self) -> Self {
    let (wrapped, overflow) = subtractingReportingOverflow(other)
    if !overflow { return wrapped }
    return Self.max &- signExtension
  }
  
  @inlinable
  public func multipliedWithSaturation(by other: Self) -> Self {
    let (high, low) = multipliedFullWidth(by: other)
    let wrapped = Self(truncatingIfNeeded: low)
    if high == wrapped.signExtension { return wrapped }
    return Self.max &- high.signExtension
  }
  
  @inlinable
  public func shiftedWithSaturation<Count: BinaryInteger>(
    leftBy count: Count, rounding rule: RoundingRule = .down
  ) -> Self {
    // If count is zero or negative, negate it and do a right
    // shift without saturation instead, as that's easier.
    guard count > 0 else {
      // TODO: fixup case where 0 - count overflows
      return shifted(rightBy: 0 - count, rounding: rule)
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
