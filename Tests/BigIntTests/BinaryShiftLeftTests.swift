//===--- BinaryShiftLeftTests.swift ---------------------------*- swift -*-===//
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

// A lot of those bit shenanigans are based on the following observation:
//  7<<5 ->  224
// -7<<5 -> -224
// Shifting values with the same magnitude gives us result with the same
// magnitude (224 vs -224). Later you just have to do sign correction.

private typealias Word = BigIntPrototype.Word

private let intWidth = Int.bitWidth
private let intShifts = [
  0, 1, 5, 8,
  intWidth / 2,
  intWidth - 3,
  intWidth
]

class BinaryShiftLeftTests: XCTestCase {

  // MARK: - Int

  func test_int_byPositive() {
    for int in generateInts(approximateCount: 100) {
      let big = BigInt(int)

      for s in intShifts {
        let expected = int.shiftLeftFullWidth(by: s)
        XCTAssertEqual(big << s, expected, "\(int) << \(s)")
      }
    }
  }

  func test_int_byNegative() {
    for int in generateInts(approximateCount: 100) {
      let big = BigInt(int)

      for s in intShifts {
        let expected = BigInt(int << -s)
        XCTAssertEqual(big << -s, expected, "\(int) << -\(s)")
      }
    }
  }

  // MARK: - Big

  func test_big_byZero() {
    for p in generateBigInts(approximateCount: 100) {
      let big = p.create()
      let expected = p.create()
      XCTAssertEqual(big << 0, expected, "\(big)")
    }
  }

  func test_big_byWholeWord() {
    for p in generateBigInts(approximateCount: 35) {
      // Shifting '0' obeys a bit different rules
      if p.isZero {
        continue
      }

      for wordCount in 1...3 {
        let big = p.create()

        let prefix = [Word](repeating: 0, count: wordCount)
        let expected = BigInt(p.sign, magnitude: prefix + p.magnitude)

        let bitShift = wordCount * Word.bitWidth
        XCTAssertEqual(big << bitShift, expected, "\(big) << \(bitShift)")
      }
    }
  }

  func test_big_byBits_noOverflow() {
    for p in generateBigInts(approximateCount: 50) {
      // Shifting '0' obeys a bit different rules
      if p.isZero {
        continue
      }

      for s in 1...3 {
        // Clear high bits, so we can shift without overflow
        let lowBitsMask: Word = (1 << s) - 1
        let highBitsMask = lowBitsMask << (Word.bitWidth - s)
        let remainingBitsMask = ~highBitsMask

        let bigMagnitude = p.magnitude.map { $0 & remainingBitsMask }
        let big = BigInt(p.sign, magnitude: bigMagnitude)

        let expectedMagnitude = p.magnitude.map { $0 << s }
        let expected = BigInt(p.sign, magnitude: expectedMagnitude)
        XCTAssertEqual(big << s, expected, "\(big) << \(s)")
      }
    }
  }

  /// `1011 << 5 = 1_0110_0000` (assuming that our Word has 4 bits)
  func test_big_exampleFromCode() {
    // 1000_0000…0011
    let word = Word(bitPattern: 1 << (Word.bitWidth - 1) | 0b0011)
    let big = BigInt(.positive, magnitude: word)
    let shift = Word.bitWidth + 1
    let expected = BigInt(.positive, magnitude: [0b0000, 0b0110, 0b0001])
    XCTAssertEqual(big << shift, expected, "\(big) << \(shift)")
  }

  func test_big_right() {
    let wordShift = 1
    let bitShift = -wordShift * Word.bitWidth

    for p in generateBigInts(approximateCount: 50) {
      // We just want to test if we call 'shiftRight',
      // we do not care about edge cases.
      guard p.magnitude.count > wordShift else {
        continue
      }

      // Set lowest word to '0' to avoid floor rounding case:
      // -5 / 2 = -3 not -2
      var words = p.magnitude
      words[0] = 0

      let big = BigInt(p.sign, magnitude: words)

      let expectedMagnitude = Array(words.dropFirst(wordShift))
      let expectedIsPositive = expectedMagnitude.isEmpty || p.isPositive
      let expected = BigInt(isPositive: expectedIsPositive, magnitude: expectedMagnitude)
      XCTAssertEqual(big << bitShift, expected, "\(big) << \(bitShift)")
    }
  }
}
