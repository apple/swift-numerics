//===--- BigInt+Extensions.swift ------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import BigIntModule

extension BigInt {

  internal typealias Word = Words.Element

  internal init(isPositive: Bool, magnitude: [BigIntPrototype.Word]) {
    let p = BigIntPrototype(isPositive: isPositive, magnitude: magnitude)
    self = p.create()
  }

  internal init(_ sign: BigIntPrototype.Sign, magnitude: BigIntPrototype.Word) {
    let p = BigIntPrototype(sign, magnitude: magnitude)
    self = p.create()
  }

  internal init(_ sign: BigIntPrototype.Sign, magnitude: [BigIntPrototype.Word]) {
    let p = BigIntPrototype(sign, magnitude: magnitude)
    self = p.create()
  }

  internal func power(exponent: BigInt) -> BigInt {
    precondition(exponent >= 0, "Exponent must be positive")

    if exponent == 0 {
      return BigInt(1)
    }

    if exponent == 1 {
      return self
    }

    // This has to be after 'exp == 0', because 'pow(0, 0) -> 1'
    if self == 0 {
      return 0
    }

    var base = self
    var exponent = exponent
    var result = BigInt(1)

    // Eventually we will arrive to most significant '1'
    while exponent != 1 {
      let exponentIsOdd = exponent & 0b1 == 1

      if exponentIsOdd {
        result *= base
      }

      base *= base
      exponent >>= 1 // Basically divided by 2, but faster
    }

    // Most significant '1' is odd:
    result *= base
    return result
  }
}
