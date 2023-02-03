//===--- BinaryDivRemTests.swift ------------------------------*- swift -*-===//
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

// swiftlint:disable number_separator
// swiftlint:disable file_length
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

private func assertDiv<Q: SignedInteger, R: SignedInteger>(_ lhs: BigInt,
                                                           _ rhs: BigInt,
                                                           quotient _quotient: Q?,
                                                           remainder _remainder: R?,
                                                           file: StaticString = #file,
                                                           line: UInt = #line) {
  assert(rhs != 0, "[BinaryDivTests] Oooo… div by 0? 🐰")

  let q = lhs / rhs
  let r = lhs % rhs

  if let quotient = _quotient {
    let expected = BigInt(quotient)
    XCTAssertEqual(q, expected, "[\(lhs)/\(rhs)] Quotient", file: file, line: line)
  }

  if let remainder = _remainder {
    let expected = BigInt(remainder)
    XCTAssertEqual(r, expected, "[\(lhs)/\(rhs)] Remainder", file: file, line: line)
  }

  // lhs == q * rhs + r
  let restored = q * rhs + r
  XCTAssertEqual(lhs, restored, "[\(lhs)/\(rhs)] lhs == q * rhs + r", file: file, line: line)

  // There are multiple solutions for 'lhs = q * rhs + r':
  //              | -5/4 | -5%4 |
  // Python 3.7.4 | -2   |  3   |
  // Swift 5.3.2  | -1   | -1   | <- we want this (round toward 0)
  //
  // Check: |q * rhs| <= |lhs|
  // In Python: |-2*4| <= |-5| -> 8 <= 5 -> FALSE
  // In Swift:  |-1*4| <= |-5| -> 4 <= 5 -> TRUE
  let qRhs = q * rhs
  XCTAssertLessThanOrEqual(qRhs.magnitude, lhs.magnitude, "[\(lhs)/\(rhs)] Round toward 0", file: file, line: line)

  let (qq, rr) = lhs.quotientAndRemainder(dividingBy: rhs)
  XCTAssertEqual(qq, q, "[\(lhs)/\(rhs)] quotientAndRemainder-Quotient", file: file, line: line)
  XCTAssertEqual(rr, r, "[\(lhs)/\(rhs)] quotientAndRemainder-Remainder", file: file, line: line)
}

class BinaryDivRemTests: XCTestCase {

  // MARK: - Int

  func test_int_zero() {
    let zero = BigInt()

    for int in generateInts(approximateCount: 100) {
      if int == 0 {
        continue
      }

      // 0 / x = 0 rem 0
      let big = BigInt(int)
      assertDiv(zero, big, quotient: 0, remainder: 0)
      // For obvious reasons we will not have 'big / zero' test
    }
  }

  func test_int_plus1() {
    let one = BigInt(1)

    for int in generateInts(approximateCount: 100) {
      let big = BigInt(int)

      // x / 1 = x rem 0
      assertDiv(big, one, quotient: big, remainder: 0)

      // 1 / x = 0 rem 1 (except for '1/1 = 1 rem 0' and '1/(-1) = -1 rem 0')
      if int != 0 {
        let (q, r) = (1).quotientAndRemainder(dividingBy: int)
        assertDiv(one, big, quotient: q, remainder: r)
      }
    }
  }

  func test_int_minus1() {
    let minusOne = BigInt(-1)

    for int in generateInts(approximateCount: 100) {
      let big = BigInt(int)

      // x / (-1) = -x
      assertDiv(big, minusOne, quotient: -big, remainder: 0)

      // (-1) / x = 0 rem -1 (mostly)
      if int != 0 {
        let (q, r) = (-1).quotientAndRemainder(dividingBy: int)
        assertDiv(minusOne, big, quotient: q, remainder: r)
      }
    }
  }

  func test_int() {
    let ints = generateInts(approximateCount: 20)

    for (lhsInt, rhsInt) in CartesianProduct(ints) {
      let isOverflow = lhsInt == .min && rhsInt == -1
      if rhsInt == 0 || isOverflow {
        continue
      }

      let lhsBig = BigInt(lhsInt)
      let rhsBig = BigInt(rhsInt)
      let (q, r) = lhsInt.quotientAndRemainder(dividingBy: rhsInt)
      assertDiv(lhsBig, rhsBig, quotient: q, remainder: r)
    }
  }

  /// Div by `n^2` (2, 4, 8) is the same as shift right by `n`
  func test_int_powerOf2() {
    for p in generateBigInts(approximateCount: 100) {
      if p.isZero {
        continue
      }

      for power in powersOf2 {
        guard let p = self.cleanBitsSoItCanBeDividedWithoutOverflow(
          value: p,
          power: power
        ) else { continue }

        let big = p.create()
        let rhs = BigInt(power.value)

        let expectedWords = p.magnitude.map { $0 >> power.n }
        let isZero = expectedWords.allSatisfy { $0 == 0 }
        let expectedIsPositive = p.isPositive || isZero
        let expected = BigInt(isPositive: expectedIsPositive, magnitude: expectedWords)

        // Rem is '0' because we cleaned those bits
        assertDiv(big, rhs, quotient: expected, remainder: 0)
      }
    }
  }

  private func cleanBitsSoItCanBeDividedWithoutOverflow(
    value: BigIntPrototype,
    power: Pow2
  ) -> BigIntPrototype? {
    // 1111 << 1 = 1110
    let mask = Word.max << power.n
    let magnitude = value.magnitude.map { $0 & mask }

    // Zero may behave differently than other numbers
    let allWordsZero = magnitude.allSatisfy { $0 == 0 }
    if allWordsZero {
      return nil
    }

    return BigIntPrototype(value.sign, magnitude: magnitude)
  }

  /// x / x = 1 rem 0
  func test_int_equalMagnitude() {
    for int in generateInts(approximateCount: 100) {
      if int == 0 {
        continue
      }

      let plus = int == .min ? nil : abs(int)
      let minus = int < 0 ? int : -int

      let cases = [
        (plus, plus), // a / a
        (plus, minus), // a / (-a)
        (minus, plus), // -a / a
        (minus, minus) // -a / (-a)
      ]

      for (aInt, bInt) in cases {
        guard let aInt = aInt, let bInt = bInt else { continue }

        let aBig = BigInt(aInt)
        let bBig = BigInt(bInt)
        let sameSign = (aInt < 0) == (bInt < 0)
        let expectedQuotient = sameSign ? 1 : -1

        // a/b
        if bInt != 0 {
          assertDiv(aBig, bBig, quotient: expectedQuotient, remainder: 0)
        }

        // b/a
        if aInt != 0 {
          assertDiv(bBig, aBig, quotient: expectedQuotient, remainder: 0)
        }
      }
    }
  }

  /// (x+n) / x = 1 rem n
  func test_int_lhs_hasGreaterMagnitude() {
    let ints = generateInts(approximateCount: 20)

    for (a, b) in CartesianProduct(ints) {
      // We have separate test for equal magnitude
      if a.magnitude == b.magnitude {
        continue
      }

      let (biggerInt, smolInt) = a.magnitude > b.magnitude ?
        (a, b) : (b, a)

      if smolInt == 0 {
        continue
      }

      let biggerBig = BigInt(biggerInt)
      let smolBig = BigInt(smolInt)

      let isOverflow = biggerInt == Int.min && smolInt == -1
      let q = isOverflow ? -BigInt(Int.min) : BigInt(biggerInt / smolInt)
      let r = isOverflow ? 0 : BigInt(biggerInt % smolInt)
      assertDiv(biggerBig, smolBig, quotient: q, remainder: r)
    }
  }

  /// x / (x + n) = 0 rem x
  func test_int_rhs_hasGreaterMagnitude() {
    let ints = generateInts(approximateCount: 20)

    for (a, b) in CartesianProduct(ints) {
      // We have separate test for equal magnitude
      if a.magnitude == b.magnitude {
        continue
      }

      let (biggerInt, smallerInt) = a.magnitude > b.magnitude ?
        (a, b) : (b, a)

      if biggerInt == 0 {
        continue
      }

      let biggerBig = BigInt(biggerInt)
      let smallerBig = BigInt(smallerInt)
      assertDiv(smallerBig, biggerBig, quotient: 0, remainder: smallerInt)
    }
  }

  func test_int_multipleWords() {
    let bigWords: [Word] = [3689348814741910327, 2459565876494606880]
    let int = BigInt(370955168)
    let intNegative = -int

    let q = BigInt(.positive, magnitude: [10690820303666397895, 6630358837])
    let r = 237957591

    // plus, plus
    var big = BigInt(.positive, magnitude: bigWords)
    assertDiv(big, int, quotient: q, remainder: r)

    // minus, plus
    big = BigInt(.negative, magnitude: bigWords)
    assertDiv(big, int, quotient: -q, remainder: -r)

    // plus, minus
    big = BigInt(.positive, magnitude: bigWords)
    assertDiv(big, intNegative, quotient: -q, remainder: r)

    // minus, minus
    big = BigInt(.negative, magnitude: bigWords)
    assertDiv(big, intNegative, quotient: q, remainder: -r)
  }

  // MARK: - Big

  func test_big_zero() {
    let zero = BigInt()

    for p in generateBigInts(approximateCount: 100) {
      if p.isZero {
        continue
      }

      // 0 / x = 0 rem 0
      let big = p.create()
      assertDiv(zero, big, quotient: 0, remainder: 0)
      // For obvious reasons we will not have 'big / zero' test
    }
  }

  func test_big_plus1() {
    let one = BigInt(1)

    for p in generateBigInts(approximateCount: 100) {
      let big = p.create()

      // x / 1 = x rem 0
      assertDiv(big, one, quotient: big, remainder: 0)

      // 1 / x = 0 rem 1 (mostly)
      if !p.isZero {
        // 1 / 1 = 1 rem 0
        if p.isPositive && p.isMagnitude1 {
          assertDiv(one, big, quotient: 1, remainder: 0)
          continue
        }

        // 1 / (-1) = -1 rem 0
        if p.isNegative && p.isMagnitude1 {
          assertDiv(one, big, quotient: -1, remainder: 0)
          continue
        }

        // Remainder is always positive!
        assertDiv(one, big, quotient: 0, remainder: 1)
      }
    }
  }

  func test_big_minus1() {
    let minusOne = BigInt(-1)

    for p in generateBigInts(approximateCount: 100) {
      let big = p.create()

      // x / (-1) = -x
      assertDiv(big, minusOne, quotient: -big, remainder: 0)

      // (-1) / x = 0 rem -1 (mostly)
      if !p.isZero {
        // (-1) / 1 = -1 rem 0
        if p.isPositive && p.isMagnitude1 {
          assertDiv(minusOne, big, quotient: -1, remainder: 0)
          continue
        }

        // (-1) / (-1) = 1 rem 0
        if p.isNegative && p.isMagnitude1 {
          assertDiv(minusOne, big, quotient: 1, remainder: 0)
          continue
        }

        assertDiv(minusOne, big, quotient: 0, remainder: -1)
      }
    }
  }

  /// Div by `n^2` (2, 4, 8) is the same as shift right by `n`
  func test_big_powerOf2() {
    for p in generateBigInts(approximateCount: 20) {
      if p.isZero {
        continue
      }

      for power in powersOf2 {
        guard let p = self.cleanBitsSoItCanBeDividedWithoutOverflow(
          value: p,
          power: power
        ) else { continue }

        let big = p.create()
        let rhs = BigInt(power.value)

        let expectedWords = p.magnitude.map { $0 >> power.n }
        let isZero = expectedWords.allSatisfy { $0 == 0 }
        let expectedSign: BigIntPrototype.Sign = p.isPositive || isZero ? .positive : .negative
        let expected = BigInt(expectedSign, magnitude: expectedWords)

        // Rem is '0' because we cleaned those bits
        assertDiv(big, rhs, quotient: expected, remainder: 0)
      }
    }
  }

  /// x / x = 1 rem 0
  func test_big_equalMagnitude() {
    for p in generateBigInts(approximateCount: 100) {
      if p.isZero {
        continue
      }

      let plus = BigInt(.positive, magnitude: p.magnitude)
      let minus = BigInt(.negative, magnitude: p.magnitude)

      // plus / plus = 1 rem 0
      assertDiv(plus, plus, quotient: 1, remainder: 0)

      // plus / minus = -1 rem 0
      assertDiv(plus, minus, quotient: -1, remainder: 0)

      // minus / plus = -1 rem 0
      assertDiv(minus, plus, quotient: -1, remainder: 0)

      // minus / minus = 1 rem 0
      assertDiv(minus, minus, quotient: 1, remainder: 0)
    }
  }

  /// (x+n) / x = 1 rem n
  func test_big_lhs_hasGreaterMagnitude() {
    let bigs = generateBigInts(approximateCount: 20)

    for (lhs, rhs) in CartesianProduct(bigs) {
      let bigger: BigInt
      let smol: BigInt

      switch BigIntPrototype.compare(lhs, rhs) {
      case .equal:
        // We have separate test for equal magnitude
        continue
      case .less:
        bigger = rhs.create()
        smol = lhs.create()
      case .greater:
        bigger = lhs.create()
        smol = rhs.create()
      }

      if smol == 0 {
        continue
      }

      // We don't know the exact values, but we still can do some tests.
      let quotient: Int? = nil
      let remainder: Int? = nil
      assertDiv(bigger, smol, quotient: quotient, remainder: remainder)
    }
  }

  /// x / (x + n) = 0 rem x
  func test_big_rhs_hasGreaterMagnitude() {
    let bigs = generateBigInts(approximateCount: 20)

    for (lhs, rhs) in CartesianProduct(bigs) {
      let bigger: BigInt
      let smol: BigInt

      switch BigIntPrototype.compare(lhs, rhs) {
      case .equal:
        // We have separate test for equal magnitude
        continue
      case .less:
        bigger = rhs.create()
        smol = lhs.create()
      case .greater:
        bigger = lhs.create()
        smol = rhs.create()
      }

      if bigger == 0 {
        continue
      }

      assertDiv(smol, bigger, quotient: 0, remainder: smol)
    }
  }

  func test_big_lhsLonger() {
    let lhsWords: [Word] = [3689348814741910327, 2459565876494606880]
    let rhsWords: [Word] = [1844674407370955168]

    let quotient = BigInt(.positive, magnitude: [6148914691236517100, 1])
    let remainder = BigInt(.positive, magnitude: [1229782938247304119])

    // plus, plus
    var lhs = BigInt(.positive, magnitude: lhsWords)
    var rhs = BigInt(.positive, magnitude: rhsWords)
    assertDiv(lhs, rhs, quotient: quotient, remainder: remainder)

    // minus, plus
    lhs = BigInt(.negative, magnitude: lhsWords)
    rhs = BigInt(.positive, magnitude: rhsWords)
    assertDiv(lhs, rhs, quotient: -quotient, remainder: -remainder)

    // plus, minus
    lhs = BigInt(.positive, magnitude: lhsWords)
    rhs = BigInt(.negative, magnitude: rhsWords)
    assertDiv(lhs, rhs, quotient: -quotient, remainder: remainder)

    // minus, minus
    lhs = BigInt(.negative, magnitude: lhsWords)
    rhs = BigInt(.negative, magnitude: rhsWords)
    assertDiv(lhs, rhs, quotient: quotient, remainder: -remainder)
  }

  func test_big_rhsLonger() {
    let lhsWords: [Word] = [1844674407370955168]
    let rhsWords: [Word] = [3689348814741910327, 2459565876494606880]
    let remainder = BigInt(.positive, magnitude: lhsWords)

    // plus, plus
    var lhs = BigInt(.positive, magnitude: lhsWords)
    var rhs = BigInt(.positive, magnitude: rhsWords)
    assertDiv(lhs, rhs, quotient: 0, remainder: remainder)

    // minus, plus
    lhs = BigInt(.negative, magnitude: lhsWords)
    rhs = BigInt(.positive, magnitude: rhsWords)
    assertDiv(lhs, rhs, quotient: 0, remainder: -remainder)

    // plus, minus
    lhs = BigInt(.positive, magnitude: lhsWords)
    rhs = BigInt(.negative, magnitude: rhsWords)
    assertDiv(lhs, rhs, quotient: 0, remainder: remainder)

    // minus, minus
    lhs = BigInt(.negative, magnitude: lhsWords)
    rhs = BigInt(.negative, magnitude: rhsWords)
    assertDiv(lhs, rhs, quotient: 0, remainder: -remainder)
  }

  func test_big_bothMultipleWords() {
    let lhsWords: [Word] = [1844674407370955168, 4304240283865562048]
    let rhsWords: [Word] = [3689348814741910327, 2459565876494606880]

    let quotient = BigInt(.positive, magnitude: [1])
    let remainder = BigInt(.positive, magnitude: [16602069666338596457, 1844674407370955167])

    // plus, plus
    var lhs = BigInt(.positive, magnitude: lhsWords)
    var rhs = BigInt(.positive, magnitude: rhsWords)
    assertDiv(lhs, rhs, quotient: quotient, remainder: remainder)

    // minus, plus
    lhs = BigInt(.negative, magnitude: lhsWords)
    rhs = BigInt(.positive, magnitude: rhsWords)
    assertDiv(lhs, rhs, quotient: -quotient, remainder: -remainder)

    // plus, minus
    lhs = BigInt(.positive, magnitude: lhsWords)
    rhs = BigInt(.negative, magnitude: rhsWords)
    assertDiv(lhs, rhs, quotient: -quotient, remainder: remainder)

    // minus, minus
    lhs = BigInt(.negative, magnitude: lhsWords)
    rhs = BigInt(.negative, magnitude: rhsWords)
    assertDiv(lhs, rhs, quotient: quotient, remainder: -remainder)
  }
}
