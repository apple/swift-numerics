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
      var temporary = [UInt]()
      temporary.reserveCapacity(wordCount)
      for _ in 0..<(wordCount &- 1) { temporary.append(next()) }
      temporary.append(mask == 0 ? next() : next() & mask)
      result =
        BigInt(_combination: 1, significand: BigInt._Significand(temporary))
    } while result >= upperBound
    return result
  }
}
