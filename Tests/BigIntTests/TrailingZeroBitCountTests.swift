//===--- TrailingZeroBitCountTests.swift ----------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import BigIntModule

class TrailingZeroBitCountTests: XCTestCase {

  // There is an edge case for '0':
  // - 'int' is finite, so they can return 'bitWidth'
  // - 'BigInt' is infinite, but we can't return this
  //
  // So, trailingZeroBitCount is equal to bitWidth, see:
  // https://developer.apple.com/documentation/swift/binaryinteger/trailingzerobitcount
  func test_zero() {
    let zero = BigInt(0)
    XCTAssertEqual(zero.trailingZeroBitCount, 1)
  }

  func test_int() {
    for int in generateInts(approximateCount: 100) {
      // There is a separate test for '0', because it is complicated...
      if int == 0 {
        continue
      }

      let big = BigInt(int)
      let result = big.trailingZeroBitCount

      let expected = int.trailingZeroBitCount
      XCTAssertEqual(result, expected, "\(int)")
    }
  }

  func test_shift() {
    for shift in [1, 5, 7, 42, 127, 127, 129] {
      let value = BigInt(1) << shift
      XCTAssertEqual(value.trailingZeroBitCount, shift)
    }
  }

  func test_shift_andAdd() {
    for shift in [127, 127, 129] {
      for added in [0b10, 0b100, 0b1000] {
        let value = (BigInt(1) << shift) + BigInt(added)
        XCTAssertEqual(value.trailingZeroBitCount, added.trailingZeroBitCount)
      }
    }
  }

  func test_manuallyCountedZeros() {
    for p in generateBigInts(approximateCount: 200, maxWordCount: 4) {
      // There is a separate test for '0', because it is complicated...
      if p.isZero {
        continue
      }

      let big = p.create()
      let result = big.trailingZeroBitCount
      let expected = self.countTrailingZeroBits(big)
      XCTAssertEqual(result, expected, "\(big)")
    }
  }

  func test_manuallyCountedZeros_additionalZeroWord() {
    for p in generateBigInts(approximateCount: 200, maxWordCount: 4) {
      // There is a separate test for '0', because it is complicated...
      if p.isZero {
        continue
      }

      let magnitude = [0] + p.magnitude
      let p2 = BigIntPrototype(p.sign, magnitude: magnitude)

      let big = p2.create()
      let result = big.trailingZeroBitCount
      let expected = self.countTrailingZeroBits(big)
      XCTAssertEqual(result, expected, "\(big)")
    }
  }

  private func countTrailingZeroBits(_ n: BigInt) -> Int {
    var n = n
    var result = 0

    while true {
      if n == 0 {
        return result
      }

      let bit = n & 1
      if bit == 1 {
        return result
      }

      result += 1
      n >>= 1
    }
  }
}
