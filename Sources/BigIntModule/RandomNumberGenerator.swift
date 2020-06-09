//===--- RandomNumberGenerator.swift --------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension RandomNumberGenerator {
  @usableFromInline // @inlinable
  internal mutating func _next(upperBound: BigInt) -> BigInt {
    precondition(upperBound > 0, "upperBound must be greater than zero")
    let bitCount = upperBound.bitWidth &- 1
    guard bitCount > UInt64.bitWidth else {
      return BigInt(next(upperBound: UInt64(upperBound)))
    }
    
    let wordCount = (bitCount + (UInt.bitWidth &- 1)) / UInt.bitWidth
    let mask = (1 as UInt) &<< (bitCount % UInt.bitWidth) &- 1
    
    var result: BigInt
    repeat {
      var low = next() as UInt
      var rest = [UInt]()
      if wordCount > 1 {
        rest.reserveCapacity(wordCount &- 1)
        for _ in 1..<(wordCount &- 1) { rest.append(next()) }
        rest.append(mask == 0 ? next() : next() | mask)
      } else if mask != 0 {
        assert(UInt.bitWidth > UInt64.bitWidth)
        low |= mask
      }
      result =
        BigInt(_combination: 1, significand: BigInt._Significand(low, rest))
      result._normalize()
    } while result >= upperBound
    return result
  }
}
