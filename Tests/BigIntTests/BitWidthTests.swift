//===--- BitWidthTests.swift ----------------------------------*- swift -*-===//
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

class BitWidthTests: XCTestCase {

  func test_trivial() {
    let zero = BigInt(0)
    XCTAssertEqual(zero.bitWidth, 1) //  0 is just 0

    let plus1 = BigInt(1)
    XCTAssertEqual(plus1.bitWidth, 2) // 1 needs '0' prefix -> '01'

    let minus1 = BigInt(-1)
    XCTAssertEqual(minus1.bitWidth, 1) // -1 is just 1
  }

  // MARK: - Int

  private typealias IntTestCase = (value: Int, expected: Int)

  private let intTestCases: [IntTestCase] = [
    // zero
    (0, 1),
    // positive
    (1, 2),
    (2, 3),
    (3, 3),
    (4, 4),
    (5, 4),
    (6, 4),
    (7, 4),
    (8, 5),
    (9, 5),
    (10, 5),
    (11, 5),
    (12, 5),
    (13, 5),
    (14, 5),
    (15, 5),
    // negative
    (-1, 1),
    (-2, 2),
    (-3, 3),
    (-4, 3),
    (-5, 4),
    (-6, 4),
    (-7, 4),
    (-8, 4),
    (-9, 5),
    (-10, 5),
    (-11, 5),
    (-12, 5),
    (-13, 5),
    (-14, 5),
    (-15, 5)
  ]

  func test_ints() {
    for (value, expected) in self.intTestCases {
      let bigInt = BigInt(value)
      XCTAssertEqual(bigInt.bitWidth, expected, "\(value)")
    }
  }

  // MARK: - Positive power of 2

  // +-----+-----------+-------+-------+
  // | dec |    bin    | power |  bit  |
  // |     |           |       | width |
  // +-----+-----------+-------+-------+
  // |   1 |      0001 |     0 |     2 |
  // |   2 |      0010 |     1 |     3 |
  // |   4 |      0100 |     2 |     4 |
  // |   8 | 0000 1000 |     3 |     5 |
  // +-----+-----------+-------+-------+
  //
  // TLDR: bitWidth = power + 2
  private let positivePowerOf2Correction = 2

  func test_powerOf2_positive() {
    for (power, int) in PositivePowersOf2(type: Int.self) {
      let big = BigInt(int)
      let expected = power + self.positivePowerOf2Correction
      XCTAssertEqual(big.bitWidth, expected, "for \(int) (2^\(power))")
    }
  }

  func test_powerOf2_positive_multipleWords() {
    typealias Word = UInt64

    for zeroWordCount in [1, 2] {
      let zeroWords = [Word](repeating: 0, count: zeroWordCount)
      let zeroWordsBitWidth = zeroWordCount * Word.bitWidth

      for (power, value) in PositivePowersOf2(type: Word.self) {
        let words = zeroWords + [value]
        let proto = BigIntPrototype(.positive, magnitude: words)
        let big = proto.create()

        let expected = power + self.positivePowerOf2Correction + zeroWordsBitWidth
        XCTAssertEqual(big.bitWidth, expected, "\(proto)")
      }
    }
  }

  // MARK: - Negative power of 2

  // +-----+------+-------+-------+
  // | dec | bin  | power |  bit  |
  // |     |      |       | width |
  // +-----+------+-------+-------+
  // |  -1 | 1111 |     0 |     1 |
  // |  -2 | 1110 |     1 |     2 |
  // |  -4 | 1100 |     2 |     3 |
  // |  -8 | 1000 |     3 |     4 |
  // +-----+------+-------+-------+
  //
  // TLDR: bitWidth = power + 1
  private let negativePowerOf2Correction = 1

  func test_powerOf2_negative() {
    for (power, int) in NegativePowersOf2(type: Int.self) {
      let big = BigInt(int)
      let expected = power + self.negativePowerOf2Correction
      XCTAssertEqual(big.bitWidth, expected, "for \(int) (2^\(power))")
    }
  }

  func test_powerOf2_negative_multipleWords() {
    typealias Word = UInt64

    for zeroWordCount in [1, 2] {
      let zeroWords = [Word](repeating: 0, count: zeroWordCount)
      let zeroWordsBitWidth = zeroWordCount * Word.bitWidth

      for (power, value) in PositivePowersOf2(type: Word.self) {
        let words = zeroWords + [value]
        let proto = BigIntPrototype(.negative, magnitude: words)
        let big = proto.create()

        let expected = power + self.negativePowerOf2Correction + zeroWordsBitWidth
        XCTAssertEqual(big.bitWidth, expected, "\(proto)")
      }
    }
  }
}
