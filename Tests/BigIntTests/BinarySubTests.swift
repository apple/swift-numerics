//===--- BinarySubTests.swift ---------------------------------*- swift -*-===//
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
// swiftformat:disable numberFormatting

private typealias Word = BigIntPrototype.Word

private let intZero = Int.zero
private let intMax = Int.max
private let intMaxAsWord = Word(intMax.magnitude)

class BinarySubTests: XCTestCase {

  // MARK: - Int

  func test_int_zero() {
    let zero = BigInt()

    for int in generateInts(approximateCount: 100) {
      // '-Int.min' overflows
      if int == .min {
        continue
      }

      let big = BigInt(int)
      let plusInt = BigInt(int)
      let minusInt = BigInt(-int)
      XCTAssertEqual(big - zero, plusInt, "\(big)")
      XCTAssertEqual(zero - big, minusInt, "\(big)")
    }
  }

  func test_int_singleWord() {
    let ints = generateInts(approximateCount: 20)

    for (a, b) in CartesianProduct(ints) {
      let aPlus = a == .min ? nil : abs(a)
      let bPlus = b == .min ? nil : abs(b)
      let aMinus = a < 0 ? a : -a
      let bMinus = b < 0 ? b : -b

      let cases = [
        (aPlus, bPlus), // a - b
        (aPlus, bMinus), // a - (-b)
        (aMinus, bPlus), // -a - b
        (aMinus, bMinus) // -a - (-b)
      ]

      for (aInt, bInt) in cases {
        guard let aInt = aInt, let bInt = bInt else { continue }

        let aBig = BigInt(aInt)
        let bBig = BigInt(bInt)

        let (expected1, overflow1) = aInt.subtractingReportingOverflow(bInt)
        if !overflow1 {
          let expectedBig = BigInt(expected1)
          XCTAssertEqual(aBig - bBig, expectedBig, "\(aInt) - \(bInt)")
        }

        let (expected2, overflow2) = bInt.subtractingReportingOverflow(aInt)
        if !overflow2 {
          let expectedBig = BigInt(expected2)
          XCTAssertEqual(bBig - aBig, expectedBig, "\(bInt) - \(aInt)")
        }
      }
    }
  }

  func test_int_multipleWords() {
    let bigWords: [Word] = [3689348814741910327, 2459565876494606880]
    let int = BigInt(370955168)
    let intNegative = -int

    // Both positive
    var big = BigInt(.positive, magnitude: bigWords)
    var expected = BigInt(.positive, magnitude: [3689348814370955159, 2459565876494606880])
    XCTAssertEqual(big - int, expected)
    XCTAssertEqual(int - big, -expected)

    // Self negative, other positive
    big = BigInt(.negative, magnitude: bigWords)
    expected = BigInt(.negative, magnitude: [3689348815112865495, 2459565876494606880])
    XCTAssertEqual(big - int, expected)
    XCTAssertEqual(int - big, -expected)

    // Self positive, other negative
    big = BigInt(.positive, magnitude: bigWords)
    expected = BigInt(.positive, magnitude: [3689348815112865495, 2459565876494606880])
    XCTAssertEqual(big - intNegative, expected)
    XCTAssertEqual(intNegative - big, -expected)

    // Both negative
    big = BigInt(.negative, magnitude: bigWords)
    expected = BigInt(.negative, magnitude: [3689348814370955159, 2459565876494606880])
    XCTAssertEqual(big - intNegative, expected)
    XCTAssertEqual(intNegative - big, -expected)
  }

  // MARK: - Sign

  func test_big_sign_bothPositive() {
    let max = BigInt(intMax)

    // Same sign: Word.max - intMax = well… something
    var value = BigInt(.positive, magnitude: Word.max)
    var expected = BigInt(.positive, magnitude: Word.max - intMaxAsWord)
    XCTAssertEqual(value - max, expected)
    // Changing sign: intMax - Word.max = -(Word.max - intMax)
    expected = BigInt(.negative, magnitude: Word.max - intMaxAsWord)
    XCTAssertEqual(max - value, expected)

    // Zero: intMax - intMax = 0
    value = BigInt(.positive, magnitude: intMaxAsWord)
    expected = BigInt() // zero
    XCTAssertEqual(value - max, expected)
    XCTAssertEqual(max - value, expected)

    // Changing sign: 10 - intMax = -(intMax - 10)
    value = BigInt(.positive, magnitude: 10)
    expected = BigInt(.negative, magnitude: intMaxAsWord - 10)
    XCTAssertEqual(value - max, expected)
    // Same sign: intMax - 10
    expected = BigInt(.positive, magnitude: intMaxAsWord - 10)
    XCTAssertEqual(max - value, expected)
  }

  func test_big_sign_bothNegative() {
    let minusMax = BigInt(-intMax)

    // Same sign: -Word.max - (-intMax) = well… something
    var value = BigInt(.negative, magnitude: Word.max)
    var expected = BigInt(.negative, magnitude: Word.max - intMaxAsWord)
    XCTAssertEqual(value - minusMax, expected)
    // Changing sign: -intMax - (-Word.max) = Word.max - intMax
    expected = BigInt(.positive, magnitude: Word.max - intMaxAsWord)
    XCTAssertEqual(minusMax - value, expected)

    // Zero: -intMax - (-intMax) = 0
    value = BigInt(.negative, magnitude: intMaxAsWord)
    expected = BigInt() // zero
    XCTAssertEqual(value - minusMax, expected)
    XCTAssertEqual(minusMax - value, expected)

    // Changing sign: 10 - intMax =  -(intMax - 10)
    value = BigInt(.negative, magnitude: 10)
    expected = BigInt(.positive, magnitude: intMaxAsWord - 10)
    XCTAssertEqual(value - minusMax, expected)
    // Same sign: -intMax - (-10)
    expected = BigInt(.negative, magnitude: intMaxAsWord - 10)
    XCTAssertEqual(minusMax - value, expected)
  }

  func test_big_sign_positiveNegative() {
    let minusMax = BigInt(-intMax)

    // (Word.max - intMax) - (-intMax) = Word.max
    var value = BigInt(.positive, magnitude: Word.max - intMaxAsWord)
    var expected = BigInt(.positive, magnitude: Word.max)
    XCTAssertEqual(value - minusMax, expected)
    // (-intMax) - (Word.max - intMax) = Word.max
    expected = BigInt(.negative, magnitude: Word.max)
    XCTAssertEqual(minusMax - value, expected)

    // Word.max - (-intMax) = well… a lot
    value = BigInt(.positive, magnitude: Word.max)
    // Why '-1'? 99 + 5 = 104, not 105!
    expected = BigInt(.positive, magnitude: [intMaxAsWord - 1, 1])
    XCTAssertEqual(value - minusMax, expected)
    // (-intMax) - Word.max = well… a lot
    expected = BigInt(.negative, magnitude: [intMaxAsWord - 1, 1])
    XCTAssertEqual(minusMax - value, expected)
  }

  func test_big_sign_negativePositive() {
    let max = BigInt(intMax)

    // -(Word.max - intMax) - intMax =
    // -Word.max + intMax - intMax =
    // -Word.max
    var value = BigInt(.negative, magnitude: Word.max - intMaxAsWord)
    var expected = BigInt(.negative, magnitude: Word.max)
    XCTAssertEqual(value - max, expected)
    // intMax - (-(Word.max - intMax)) =
    // intMax - (-Word.max + intMax) =
    // intMax + Word.max - intMax =
    // Word.max
    expected = BigInt(.positive, magnitude: Word.max)
    XCTAssertEqual(max - value, expected)

    // -Word.max - intMax = well… a lot
    value = BigInt(.negative, magnitude: Word.max)
    // Why '-1'? 99 + 5 = 104, not 105!
    expected = BigInt(.negative, magnitude: [intMaxAsWord - 1, 1])
    XCTAssertEqual(value - max, expected)
    // intMax - (-Word.max) = ...
    expected = BigInt(.positive, magnitude: [intMaxAsWord - 1, 1])
    XCTAssertEqual(max - value, expected)
  }

  // MARK: - Big

  func test_big_zero() {
    let zero = BigInt()

    for p in generateBigInts(approximateCount: 100) {
      // We have separate test for 'self == 0'
      if p.isZero {
        continue
      }

      let big = p.create()
      let plus = p.create()
      let minus = p.withOppositeSign.create()

      XCTAssertEqual(big - zero, plus, "\(big)")
      XCTAssertEqual(zero - big, minus, "\(big)")
    }
  }

  func test_big_singleWord_vs_multipleWords() {
    let multiWords: [Word] = [3689348814741910327, 2459565876494606880]
    let singleWords: [Word] = [1844674407370955168]

    // Both positive
    var multi = BigInt(.positive, magnitude: multiWords)
    var single = BigInt(.positive, magnitude: singleWords)
    var expected = BigInt(.positive, magnitude: [1844674407370955159, 2459565876494606880])
    XCTAssertEqual(multi - single, expected)
    XCTAssertEqual(single - multi, -expected)

    // Self negative, other positive
    multi = BigInt(.negative, magnitude: multiWords)
    single = BigInt(.positive, magnitude: singleWords)
    expected = BigInt(.negative, magnitude: [5534023222112865495, 2459565876494606880])
    XCTAssertEqual(multi - single, expected)
    XCTAssertEqual(single - multi, -expected)

    // Self positive, other negative
    multi = BigInt(.positive, magnitude: multiWords)
    single = BigInt(.negative, magnitude: singleWords)
    expected = BigInt(.positive, magnitude: [5534023222112865495, 2459565876494606880])
    XCTAssertEqual(multi - single, expected)
    XCTAssertEqual(single - multi, -expected)

    // Both negative
    multi = BigInt(.negative, magnitude: multiWords)
    single = BigInt(.negative, magnitude: singleWords)
    expected = BigInt(.negative, magnitude: [1844674407370955159, 2459565876494606880])
    XCTAssertEqual(multi - single, expected)
    XCTAssertEqual(single - multi, -expected)
  }

  func test_big_bothMultipleWords() {
    let lhsWords: [Word] = [1844674407370955168, 4304240283865562048]
    let rhsWords: [Word] = [3689348814741910327, 2459565876494606880]

    // Both positive
    var lhs = BigInt(.positive, magnitude: lhsWords)
    var rhs = BigInt(.positive, magnitude: rhsWords)
    var expected = BigInt(.positive, magnitude: [16602069666338596457, 1844674407370955167])
    XCTAssertEqual(lhs - rhs, expected)
    XCTAssertEqual(rhs - lhs, -expected)

    // Self negative, other positive
    lhs = BigInt(.negative, magnitude: lhsWords)
    rhs = BigInt(.positive, magnitude: rhsWords)
    expected = BigInt(.negative, magnitude: [5534023222112865495, 6763806160360168928])
    XCTAssertEqual(lhs - rhs, expected)
    XCTAssertEqual(rhs - lhs, -expected)

    // Self positive, other negative
    lhs = BigInt(.positive, magnitude: lhsWords)
    rhs = BigInt(.negative, magnitude: rhsWords)
    expected = BigInt(.positive, magnitude: [5534023222112865495, 6763806160360168928])
    XCTAssertEqual(lhs - rhs, expected)
    XCTAssertEqual(rhs - lhs, -expected)

    // Both negative
    lhs = BigInt(.negative, magnitude: lhsWords)
    rhs = BigInt(.negative, magnitude: rhsWords)
    expected = BigInt(.negative, magnitude: [16602069666338596457, 1844674407370955167])
    XCTAssertEqual(lhs - rhs, expected)
    XCTAssertEqual(rhs - lhs, -expected)
  }
}
