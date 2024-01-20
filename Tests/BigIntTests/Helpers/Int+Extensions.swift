//===--- Int+Extensions.swift ---------------------------------*- swift -*-===//
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

extension SignedInteger {

  internal var isPositive: Bool {
    return self.sign == .positive
  }

  internal var isNegative: Bool {
    return self.sign == .negative
  }

  internal var sign: BigIntPrototype.Sign {
    return self >= .zero ? .positive : .negative
  }
}

extension Int {
  internal func shiftLeftFullWidth(by n: Int) -> BigInt {
    // A lot of those bit shenanigans are based on the following observation:
    //  7<<5 ->  224
    // -7<<5 -> -224
    // Shifting values with the same magnitude gives us result with the same
    // magnitude (224 vs -224). Later you just have to do sign correction.
    let magnitude = self.magnitude
    let width = Int.bitWidth

    let low = magnitude << n
    let high = magnitude >> (width - n) // Will sign extend
    let big = (BigInt(high) << width) | BigInt(low)
    return self < 0 ? -big : big
  }
}
