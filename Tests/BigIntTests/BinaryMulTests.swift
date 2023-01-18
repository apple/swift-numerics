//===--- BinaryMulTests.swift ---------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// BinaryMulTests
import XCTest
@testable import BigIntModule

// swiftlint:disable line_length
// swiftlint:disable number_separator
// swiftformat:disable numberFormatting

private typealias Word = BigIntPrototype.Word

private let intZero = Int.zero
private let intMax = Int.max
private let intMaxAsWord = Word(intMax.magnitude)

/// `2^n = value`
private typealias Pow2 = (value: Int, n: Int)

private let powersOf2: [Pow2] = [
  (value: 2, n: 1),
  (value: 4, n: 2),
  (value: 16, n: 4)
]

class BinaryMulTests: XCTestCase {

  // MARK: - Int

  func test_int_zero() {
    let zero = BigInt()
    let expected = BigInt()

    for int in generateInts(approximateCount: 100) {
      let big = BigInt(int)
      XCTAssertEqual(zero * big, expected, "\(big)")
      XCTAssertEqual(big * zero, expected, "\(big)")
    }
  }

  func test_int_plus1() {
    let one = BigInt(1)

    for int in generateInts(approximateCount: 100) {
      let big = BigInt(int)
      let expected = BigInt(int)
      XCTAssertEqual(one * big, expected, "\(big)")
      XCTAssertEqual(big * one, expected, "\(big)")
    }
  }

  func test_int_minus1() {
    let minusOne = BigInt(-1)

    for int in generateInts(approximateCount: 100) {
      // '-Smi.min' overflows
      if int == .min {
        continue
      }

      let big = BigInt(int)
      let expected = BigInt(-int)
      XCTAssertEqual(minusOne * big, expected, "\(big)")
      XCTAssertEqual(big * minusOne, expected, "\(big)")
    }
  }

  func test_int_singleWord() {
    let intWidth = Int.bitWidth
    let ints = generateInts(approximateCount: 15)

    for (a, b) in CartesianProduct(ints) {
      let aPlus = a == .min ? nil : abs(a)
      let bPlus = b == .min ? nil : abs(b)
      let aMinus = a < 0 ? a : -a
      let bMinus = b < 0 ? b : -b

      let cases = [
        (aPlus, bPlus), // a * b
        (aPlus, bMinus), // a * (-b)
        (aMinus, bPlus), // -a * b
        (aMinus, bMinus) // -a * (-b)
      ]

      for (aInt, bInt) in cases {
        guard let aInt = aInt, let bInt = bInt else { continue }

        let aBig = BigInt(aInt)
        let bBig = BigInt(bInt)

        let (high, low) = aInt.multipliedFullWidth(by: bInt)
        let expected = (BigInt(high) << intWidth) | BigInt(low)

        XCTAssertEqual(aBig * bBig, expected, "\(aInt) * \(bInt)")
        XCTAssertEqual(bBig * aBig, expected, "\(aInt) * \(bInt)")
      }
    }
  }

  func test_int_multipleWords() {
    let bigWords: [Word] = [3689348814741910327, 2459565876494606880]
    let int = BigInt(370955168)
    let intNegative = -int

    // Both positive
    var big = BigInt(.positive, magnitude: bigWords)
    var expected = BigInt(.positive, magnitude: [11068046445635360608, 1229782937530123449, 49460689])
    XCTAssertEqual(big * int, expected)
    XCTAssertEqual(int * big, expected)

    // Self negative, other positive
    big = BigInt(.negative, magnitude: bigWords)
    expected = BigInt(.negative, magnitude: [11068046445635360608, 1229782937530123449, 49460689])
    XCTAssertEqual(big * int, expected)
    XCTAssertEqual(int * big, expected)

    // Self positive, other negative
    big = BigInt(.positive, magnitude: bigWords)
    expected = BigInt(.negative, magnitude: [11068046445635360608, 1229782937530123449, 49460689])
    XCTAssertEqual(big * intNegative, expected)
    XCTAssertEqual(intNegative * big, expected)

    // Both negative
    big = BigInt(.negative, magnitude: bigWords)
    expected = BigInt(.positive, magnitude: [11068046445635360608, 1229782937530123449, 49460689])
    XCTAssertEqual(big * intNegative, expected)
    XCTAssertEqual(intNegative * big, expected)
  }

  /// Multiply by a power of `2^n` (2, 4, 8) is the same as shift left by `n`
  func test_int_powerOf2() {
    for p in generateBigInts(approximateCount: 100) {
      if p.isZero {
        continue
      }

      for power in powersOf2 {
        guard let p = self.cleanBitsSoItCanBeMultipliedWithoutOverflow(
          value: p,
          power: power
        ) else { continue }

        let big = p.create()
        let powerBig = BigInt(power.value)

        let expectedMagnitude = p.magnitude.map { $0 << power.n }
        let expected = BigInt(p.sign, magnitude: expectedMagnitude)
        XCTAssertEqual(big * powerBig, expected, "\(p) * \(power.value) (shift: \(power.n)")
        XCTAssertEqual(powerBig * big, expected, "\(p) * \(power.value) (shift: \(power.n)")
      }
    }
  }

  private func cleanBitsSoItCanBeMultipliedWithoutOverflow(
    value: BigIntPrototype,
    power: Pow2
  ) -> BigIntPrototype? {
    // 1111 >> 1 = 0111
    let mask = Word.max >> power.n
    // Apply mask to every word
    let magnitude = value.magnitude.map { $0 & mask }

    // Zero may behave differently than other numbers
    let allWordsZero = magnitude.allSatisfy { $0 == 0 }
    if allWordsZero {
      return nil
    }

    return BigIntPrototype(value.sign, magnitude: magnitude)
  }

  // MARK: - Big

  func test_big_zero() {
    let zero = BigInt()
    let expected = BigInt()

    for p in generateBigInts(approximateCount: 100) {
      let big = p.create()
      XCTAssertEqual(zero * big, expected, "\(big)")
      XCTAssertEqual(big * zero, expected, "\(big)")
    }
  }

  func test_big_plus1() {
    let one = BigInt(1)

    for p in generateBigInts(approximateCount: 100) {
      let big = p.create()
      let expected = p.create()
      XCTAssertEqual(one * big, expected, "\(big)")
      XCTAssertEqual(big * one, expected, "\(big)")
    }
  }

  func test_big_minus1() {
    let minusOne = BigInt(-1)

    for p in generateBigInts(approximateCount: 100) {
      let big = p.create()
      let expected = p.isZero ? BigInt() : p.withOppositeSign.create()
      XCTAssertEqual(minusOne * big, expected, "\(big)")
      XCTAssertEqual(big * minusOne, expected, "\(big)")
    }
  }

  /// Mul by `n^2` should shift left by `n`
  func test_big_powerOf2() {
    for p in generateBigInts(approximateCount: 100) {
      if p.isZero {
        continue
      }

      for power in powersOf2 {
        guard let p = self.cleanBitsSoItCanBeMultipliedWithoutOverflow(value: p, power: power) else {
          continue
        }

        let big = p.create()
        let powerBig = BigInt(power.value)

        let expectedMagnitude = p.magnitude.map { $0 << power.n }
        let expected = BigInt(p.sign, magnitude: expectedMagnitude)
        XCTAssertEqual(big * powerBig, expected, "\(p) * \(power.value) (shift: \(power.n)")
        XCTAssertEqual(powerBig * big, expected, "\(p) * \(power.value) (shift: \(power.n)")
      }
    }
  }

  func test_big_singleWord_vs_multipleWords() {
    let multiWords: [Word] = [3689348814741910327, 2459565876494606880]
    let singleWords: [Word] = [1844674407370955168]
    let expectedWords: [Word] = [
      18077809192235360608, 16110156491039675065, 245956587649460688
    ]

    // Both positive
    var multi = BigInt(.positive, magnitude: multiWords)
    var single = BigInt(.positive, magnitude: singleWords)
    var expected = BigInt(.positive, magnitude: expectedWords)
    XCTAssertEqual(multi * single, expected)
    XCTAssertEqual(single * multi, expected)

    // Self negative, other positive
    multi = BigInt(.negative, magnitude: multiWords)
    single = BigInt(.positive, magnitude: singleWords)
    expected = BigInt(.negative, magnitude: expectedWords)
    XCTAssertEqual(multi * single, expected)
    XCTAssertEqual(single * multi, expected)

    // Self positive, other negative
    multi = BigInt(.positive, magnitude: multiWords)
    single = BigInt(.negative, magnitude: singleWords)
    expected = BigInt(.negative, magnitude: expectedWords)
    XCTAssertEqual(multi * single, expected)
    XCTAssertEqual(single * multi, expected)

    // Both negative
    multi = BigInt(.negative, magnitude: multiWords)
    single = BigInt(.negative, magnitude: singleWords)
    expected = BigInt(.positive, magnitude: expectedWords)
    XCTAssertEqual(multi * single, expected)
    XCTAssertEqual(single * multi, expected)
  }

  func test_big_bothMultipleWords() {
    let lhsWords: [Word] = [1844674407370955168, 4304240283865562048]
    let rhsWords: [Word] = [3689348814741910327, 2459565876494606880]
    let expectedWords: [Word] = [
      18077809192235360608, 6640827866535438585, 11600952384132895787, 573898704515408272
    ]

    // Both positive
    var lhs = BigInt(.positive, magnitude: lhsWords)
    var rhs = BigInt(.positive, magnitude: rhsWords)
    var expected = BigInt(.positive, magnitude: expectedWords)
    XCTAssertEqual(lhs * rhs, expected)
    XCTAssertEqual(rhs * lhs, expected)

    // Self negative, other positive
    lhs = BigInt(.negative, magnitude: lhsWords)
    rhs = BigInt(.positive, magnitude: rhsWords)
    expected = BigInt(.negative, magnitude: expectedWords)
    XCTAssertEqual(lhs * rhs, expected)
    XCTAssertEqual(rhs * lhs, expected)

    // Self positive, other negative
    lhs = BigInt(.positive, magnitude: lhsWords)
    rhs = BigInt(.negative, magnitude: rhsWords)
    expected = BigInt(.negative, magnitude: expectedWords)
    XCTAssertEqual(lhs * rhs, expected)
    XCTAssertEqual(rhs * lhs, expected)

    // Both negative
    lhs = BigInt(.negative, magnitude: lhsWords)
    rhs = BigInt(.negative, magnitude: rhsWords)
    expected = BigInt(.positive, magnitude: expectedWords)
    XCTAssertEqual(lhs * rhs, expected)
    XCTAssertEqual(rhs * lhs, expected)
  }

  // MARK: - Carry overflow

  /// This proves that naive school algorithm will never overflow on 'carry'
  /// (in sign + magnitude representation).
  ///
  /// Basically, it will `Word.max * Word.max` to get max possible carry,
  /// then it will add it to another `Word.max * Word.max` and so on...
  func test_big_carryOverflow() {
    typealias Word = BigIntPrototype.Word

    // Case 1
    // lowIndex 0
    //   high, low = 18446744073709551615 * 18446744073709551615 = 18446744073709551614 1
    //   carry, result[i] = current[i] + low + current carry = 0 1 0 = 0 1
    //   next carry = carry + high = 0 + 18446744073709551614 = 18446744073709551614
    //
    // lowIndex 1
    //   high, low = 18446744073709551615 * 18446744073709551615 = 18446744073709551614 1
    //   carry, result[i] = current[i] + low + current carry = 0 1 18446744073709551614 = 0 18446744073709551615
    //   next carry = carry + high = 0 + 18446744073709551614 = 18446744073709551614
    //   ^^^^^^^^^^ no overflow here!
    do {
      let lhs = BigInt(.positive, magnitude: [.max, .max, .max])
      let rhs = BigInt(.positive, magnitude: [.max, .max])
      XCTAssertNotNil(lhs * rhs)
    }

    // Case 2
    // lowIndex 0
    //   high, low = 18446744073709551615 * 18446744073709551614 = 18446744073709551613 2
    //   carry, result[i] = current[i] + low + current carry = 0 2 0 = 0 2
    //   next carry = carry + high = 0 + 18446744073709551613 = 18446744073709551613
    //
    // lowIndex 1
    //   high, low = 18446744073709551615 * 18446744073709551615 = 18446744073709551614 1
    //   carry, result[i] = current[i] + low + current carry = 0 1 18446744073709551613 = 0 18446744073709551614
    //   next carry = carry + high = 0 + 18446744073709551614 = 18446744073709551614
    //   ^^^^^^^^^^ no overflow here!
    do {
      let lhs = BigInt(.positive, magnitude: [.max, .max, .max])
      let rhs = BigInt(.positive, magnitude: [.max - Word(1), .max])
      XCTAssertNotNil(lhs * rhs)
    }

    // Case 3
    // lowIndex 0
    //   high, low = 18446744073709551615 * 18446744073709551615 = 18446744073709551614 1
    //   carry, result[i] = current[i] + low + current carry = 0 1 0 = 0 1
    //   next carry = carry + high = 0 + 18446744073709551614 = 18446744073709551614
    //
    // lowIndex 1
    //   high, low = 18446744073709551615 * 18446744073709551614 = 18446744073709551613 2
    //   carry, result[i] = current[i] + low + current carry = 0 2 18446744073709551614 = 1 0
    //   next carry = carry + high = 1 + 18446744073709551613 = 18446744073709551614
    //   ^^^^^^^^^^ no overflow here!
    do {
      let lhs = BigInt(.positive, magnitude: [.max, .max, .max])
      let rhs = BigInt(.positive, magnitude: [.max, .max, Word(1)])
      XCTAssertNotNil(lhs * rhs)
    }
  }
}
