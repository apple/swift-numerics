//===--- BigInt.Words.swift -----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension BigInt {
  /// The words of an arbitrarily large signed integer.
  ///
  /// For a negative value, words are of the two’s complement representation.
  @frozen
  public struct Words {
    /// The arbitrarily large signed integer.
    @usableFromInline
    internal var _value: BigInt

    /// Creates a `BigInt.Words` from the given arbitrarily large signed
    /// integer.
    ///
    /// - Parameter value: The arbitrarily large signed integer.
    @inlinable
    public init(_ value: BigInt) {
      _value = value
    }
  }
}

extension BigInt.Words: RandomAccessCollection {
  @inlinable
  public var count: Int {
    if _value._combination == 0 { return 1 }
    let temporary = _value._exponent + _value._significand.count
    let lastIndex = _value._significand.count &- 1
    let highWord = _value._significand[lastIndex]
    guard Int(bitPattern: highWord) < 0 else {
      return temporary
    }
    // If the leading bit is set, then--
    //
    // For a positive value:
    // We need to add at least one leading zero bit (and therefore one
    // additional word) for a signed representation.
    if _value._combination > 0 { return temporary + 1 }
    // For a negative value:
    // The two's complement of a magnitude has the same bit width as that of
    // the magnitude itself if and only if the magnitude is a power of two.
    // Otherwise, we need one additional bit (and therefore one additional
    // word) to fit the two's complement.
    //
    // (Note that `(x & (x &- 1)) == 0` is a method of determining if `x` is
    // a power of two.)
    return lastIndex == 0 && (highWord & (highWord &- 1)) == 0
      ? temporary
      : temporary + 1
  }
  
  @inlinable
  public var startIndex: Int { 0 }
  
  @inlinable
  public var endIndex: Int { count }
  
  @inlinable
  public func index(before i: Int) -> Int { i - 1 }
  
  @inlinable
  public func index(after i: Int) -> Int { i + 1 }
  
  @inlinable
  public subscript(position: Int) -> UInt {
    precondition(position >= 0, "Index out of bounds")
    guard position >= _value._exponent else { return 0 }
    let idx = position &- _value._exponent
    guard idx < _value._significand.count else {
      return _value._combination < 0 ? UInt.max : 0
    }
    let word = _value._significand[idx]
    return _value._combination < 0
      ? idx == 0 ? ~word &+ 1 : ~word
      : word
  }
}
