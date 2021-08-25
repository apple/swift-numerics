//===--- Rotate.swift -----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension FixedWidthInteger {
  @_transparent @usableFromInline
  internal func rotateImplementation(right count: Int) -> Self {
    // We don't have an unsigned right shift operation for signed values, so
    // we need to convert to an unsigned type. The only unsigned type that's
    // guaranteed to be able to represent the bit pattern of any Self value
    // is Magnitude. It would be possible to have Magnitude be _wider_ than
    // Self, but that's OK as long as we're careful to complement the shift
    // count using Self.bitWidth and not Magnitude.bitWidth or zero.
    let bitPattern = Magnitude(truncatingIfNeeded: self)
    let countComplement = Self.bitWidth &- count
    return Self(truncatingIfNeeded:
      bitPattern &>> count | bitPattern &<< countComplement
    )
  }
  
  /// `self` rotated bitwise right by `count` bits.
  ///
  /// Equivalent to `rotated(left: 0 &- count)`.
  @inlinable
  public func rotated<Count: BinaryInteger>(right count: Count) -> Self {
    rotateImplementation(right: Int(truncatingIfNeeded: count))
  }
  
  /// `self` rotated bitwise left by `count` bits.
  ///
  /// Equivalent to `rotated(right: 0 &- count)`.
  @inlinable
  public func rotated<Count: BinaryInteger>(left count: Count) -> Self {
    rotateImplementation(right: 0 &- Int(truncatingIfNeeded: count))
  }
}
