//===--- BinaryShiftRightTests.swift --------------------------*- swift -*-===//
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
//  12345 >> 3 ->  1543
// -12345 >> 3 -> -1543
// Shifting values with the same magnitude gives us result with the same
// magnitude (1543 vs -1543). Later you just have to do sign correction.

private typealias Word = BigIntPrototype.Word

private let intWidth = Int.bitWidth
private let intShifts = [
  0, 1, 5, 8,
  intWidth / 2,
  intWidth - 3,
  intWidth
]

class BinaryShiftRightTests: XCTestCase {

  // MARK: - Int

  func test_int_byPositive() {
    for int in generateInts(approximateCount: 100) {
      for s in intShifts {
        let big = BigInt(int)
        let expected = BigInt(int >> s)
        XCTAssertEqual(big >> s, expected, "\(int) >> \(s)")
      }
    }
  }

  func test_int_byMoreThanBitWidth() {
    let zero = BigInt()
    let minus1 = BigInt(-1)
    let moreThanBitWidth = 3 * intWidth

    for int in generateInts(approximateCount: 100) {
      let big = BigInt(int)
      let expected = int >= 0 ? zero : minus1
      XCTAssertEqual(big >> moreThanBitWidth, expected, "\(int) >> \(moreThanBitWidth)")
    }
  }

  func test_int_byNegative() {
    for int in generateInts(approximateCount: 100) {
      let big = BigInt(int)

      for s in intShifts {
        let expected = int.shiftLeftFullWidth(by: s)
        XCTAssertEqual(big >> -s, expected, "\(int) << \(s)")
      }
    }
  }

  // MARK: - Big

  func test_big_byZero() {
    for p in generateBigInts(approximateCount: 100) {
      let big = p.create()
      let expected = p.create()
      XCTAssertEqual(big >> 0, expected, "\(big)")
    }
  }

  /// `1011_0000_0000 >> 5 = 0101_1000` (assuming that our Word has 4 bits):
  func test_big_exampleFromCode() {
    let big = BigInt(.positive, magnitude: [0b0000, 0b0000, 0b1011])
    let shift = Word.bitWidth + 1
    let expected = BigInt(.positive, magnitude: [1 << (Word.bitWidth - 1), 0b0101])
    XCTAssertEqual(big >> shift, expected)
  }

  func test_big_byMoreThanBitWidth() {
    let zero = BigInt()
    let minus1 = BigInt(-1)

    for p in generateBigInts(approximateCount: 35) {
      let big = p.create()
      let moreThanBitWidth = p.magnitude.count * Word.bitWidth + 7
      let expected = p.isPositive ? zero : minus1
      XCTAssertEqual(big >> moreThanBitWidth, expected, "\(big) >> \(moreThanBitWidth)")
    }
  }

  func test_big_positive_byWholeWord() {
    for p in generateBigInts(approximateCount: 50) {
      // No point in shifting '0'
      if p.isZero {
        continue
      }

      for wordShift in 1..<p.magnitude.count {
        let big = BigInt(.positive, magnitude: p.magnitude)

        let expectedWords = Array(p.magnitude.dropFirst(wordShift))
        let expected = BigInt(.positive, magnitude: expectedWords)

        let bitShift = wordShift * Word.bitWidth
        XCTAssertEqual(big >> bitShift, expected, "\(p) >> \(bitShift)")
      }
    }
  }

  func test_big_negative_byWholeWord_withoutAdjustment() {
    for p in generateBigInts(approximateCount: 50) {
      // No point in shifting '0'
      if p.isZero {
        continue
      }

      for wordShift in 1..<p.magnitude.count {
        // Set lowest words to '0' to avoid floor rounding case:
        // -5 / 2 = -3 not -2
        var words = p.magnitude
        for i in 0..<wordShift {
          words[i] = 0
        }

        let big = BigInt(.negative, magnitude: words)

        let expectedWords = Array(p.magnitude.dropFirst(wordShift))
        let expectedSign: BigIntPrototype.Sign = expectedWords.isEmpty ? .positive : .negative
        let expected = BigInt(expectedSign, magnitude: expectedWords)

        let bitShift = wordShift * Word.bitWidth
        XCTAssertEqual(big >> bitShift, expected, "\(p) >> \(bitShift)")
      }
    }
  }

  func test_big_negative_byWholeWord_withAdjustment() {
    for p in generateBigInts(approximateCount: 50) {
      // No point in shifting '0'
      if p.isZero {
        continue
      }

      for wordShift in 1..<p.magnitude.count {
        // Setting the lowest word to non-zero value will force adjustment.
        // -5 / 2 = -3 not -2
        var words = p.magnitude
        words[0] = max(words[0], 1)

        let big = BigInt(.negative, magnitude: words)

        // We need to drop words and then apply adjustment to increase magnitude
        var expectedWords = Array(p.magnitude.dropFirst(wordShift))
        if !expectedWords.isEmpty {
          let (increasedMagnitude, overflow) = expectedWords[0].addingReportingOverflow(1)
          if overflow {
            continue
          }
          expectedWords[0] = increasedMagnitude
        }

        let expectedSign: BigIntPrototype.Sign = expectedWords.isEmpty ? .positive : .negative
        let expected = BigInt(expectedSign, magnitude: expectedWords)

        let bitShift = wordShift * Word.bitWidth
        XCTAssertEqual(big >> bitShift, expected, "\(p) >> \(bitShift)")
      }
    }
  }

  func test_big_byBits_noOverflow() {
    for p in generateBigInts(approximateCount: 50) {
      // There is a different test for this
      if p.isZero {
        continue
      }

      for s in 1...3 {
        // Clean low bits, so we can shift without overflow
        let lowBitsMask: Word = (1 << s) - 1
        let remainingBitsMask = ~lowBitsMask

        let bigMagnitude = p.magnitude.map { $0 & remainingBitsMask }
        let big = BigInt(p.sign, magnitude: bigMagnitude)

        let expectedMagnitude = p.magnitude.map { $0 >> s }
        let expected = BigInt(p.sign, magnitude: expectedMagnitude)
        XCTAssertEqual(big >> s, expected, "\(big) >> \(s)")
      }
    }
  }

  func test_big_left() {
    let wordShift = 1
    let bitShift = -wordShift * Word.bitWidth

    for p in generateBigInts(approximateCount: 50) {
      // We just want to test if we call 'shiftLeft',
      // we do not care about edge cases.
      guard p.magnitude.count > wordShift else {
        continue
      }

      let big = p.create()

      let expectedMagnitude = [0] + p.magnitude
      let expectedIsPositive = expectedMagnitude.isEmpty || p.isPositive
      let expected = BigInt(isPositive: expectedIsPositive, magnitude: expectedMagnitude)
      XCTAssertEqual(big >> bitShift, expected, "\(big) >> \(bitShift)")
    }
  }
}
