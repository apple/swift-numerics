//===--- UnaryMinusTests.swift --------------------------------*- swift -*-===//
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

class UnaryMinusTests: XCTestCase {

  func test_zero() {
    let zero = BigInt()
    XCTAssertEqual(zero, -zero)

    var negated = BigInt()
    negated.negate()
    XCTAssertEqual(negated, zero)
  }

  func test_int() {
    for int in generateInts(approximateCount: 100) {
      // 'Int.min' negation overflows
      // This test code can crash if 'Int.bitWidth > BigIntPrototype.Word.bitWidth'
      let expected = int == .min ?
        BigInt(.positive, magnitude: BigIntPrototype.Word(int.magnitude)) :
        BigInt(-int)

      let big = -BigInt(int)
      XCTAssertEqual(big, expected, "\(big) == \(expected)")

      var negated = BigInt(int)
      negated.negate()
      XCTAssertEqual(negated, expected, "\(negated) == \(expected)")
    }
  }

  func test_big() {
    for p in generateBigInts(approximateCount: 100) {
      // There is special test for '0'
      if p.isZero {
        continue
      }

      let big = p.create()
      let bigSign = big.signum()
      let bigMagnitude = big.magnitude

      let minus = -big
      XCTAssertNotEqual(minus.signum(), bigSign, "\(big)")
      XCTAssertEqual(minus.magnitude, bigMagnitude, "\(big)")

      var negated = p.create()
      negated.negate()
      XCTAssertNotEqual(negated.signum(), bigSign, "\(big)")
      XCTAssertEqual(negated.magnitude, bigMagnitude, "\(big)")
    }
  }

  func test_big_apply2Times() {
    for p in generateBigInts(approximateCount: 100) {
      // There is special test for '0'
      if p.isZero {
        continue
      }

      let big = p.create()

      let minus = -(-big)
      XCTAssertEqual(minus, big, "\(big)")

      var negated = p.create()
      negated.negate()
      negated.negate()
      XCTAssertEqual(negated, big, "\(big)")
    }
  }
}
