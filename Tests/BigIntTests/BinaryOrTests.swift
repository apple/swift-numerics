//===--- BinaryOrTests.swift ----------------------------------*- swift -*-===//
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

class BinaryOrTests: XCTestCase {

  // MARK: - Int

  func test_int_zero() {
    let zero = BigInt()

    for int in generateInts(approximateCount: 100) {
      let big = BigInt(int)
      let expected = BigInt(int)
      XCTAssertEqual(zero | big, expected, "\(big)")
      XCTAssertEqual(big | zero, expected, "\(big)")
    }
  }

  func test_int_truthTable() {
    let lhsWord: Word = 0b1100
    let rhsWord: Word = 0b1010

    let lhs = BigInt(.positive, magnitude: lhsWord)
    let rhs = BigInt(.positive, magnitude: rhsWord)

    let expected = BigInt(lhsWord | rhsWord)
    XCTAssertEqual(lhs | rhs, expected)
    XCTAssertEqual(rhs | lhs, expected)
  }

  func test_int_singleWord() {
    let ints = generateInts(approximateCount: 20)

    for (lhsInt, rhsInt) in CartesianProduct(ints) {
      let lhs = BigInt(lhsInt)
      let rhs = BigInt(rhsInt)
      let expected = BigInt(lhsInt | rhsInt)

      XCTAssertEqual(lhs | rhs, expected, "\(lhsInt) | \(rhsInt)")
      XCTAssertEqual(rhs | lhs, expected, "\(lhsInt) | \(rhsInt)")
    }
  }

  func test_int_multipleWords() {
    let bigWords: [Word] = [3689348814741910327, 2459565876494606880]
    let int = BigInt(370955168)
    let intNegative = -int

    // Both positive
    var big = BigInt(.positive, magnitude: bigWords)
    var expected = BigInt(.positive, magnitude: [3689348814809822135, 2459565876494606880])
    XCTAssertEqual(big | int, expected)
    XCTAssertEqual(int | big, expected)

    // Self negative, other positive
    big = BigInt(.negative, magnitude: bigWords)
    expected = BigInt(.negative, magnitude: [3689348814438866967, 2459565876494606880])
    XCTAssertEqual(big | int, expected)
    XCTAssertEqual(int | big, expected)

    // Self positive, other negative
    big = BigInt(.positive, magnitude: bigWords)
    expected = BigInt(.negative, magnitude: 67911817)
    XCTAssertEqual(big | intNegative, expected)
    XCTAssertEqual(intNegative | big, expected)

    // Both negative
    big = BigInt(.negative, magnitude: bigWords)
    expected = BigInt(.negative, magnitude: 303043351)
    XCTAssertEqual(big | intNegative, expected)
    XCTAssertEqual(intNegative | big, expected)
  }

  // MARK: - Big

  func test_big_zero() {
    let zero = BigInt()

    for p in generateBigInts(approximateCount: 100) {
      let big = p.create()
      let expected = p.create()
      XCTAssertEqual(zero | big, expected, "\(big)")
      XCTAssertEqual(big | zero, expected, "\(big)")
    }
  }

  func test_big_singleWord() {
    let values = generateInts(approximateCount: 20)

    for (lhsInt, rhsInt) in CartesianProduct(values) {
      let lhsWord = Word(lhsInt.magnitude)
      let rhsWord = Word(rhsInt.magnitude)

      let lhs = BigInt(lhsInt.sign, magnitude: lhsWord)
      let rhs = BigInt(rhsInt.sign, magnitude: rhsWord)

      let expected = BigInt(lhsInt | rhsInt)
      XCTAssertEqual(lhs | rhs, expected, "\(lhsInt) | \(rhsInt)")
      XCTAssertEqual(rhs | lhs, expected, "\(lhsInt) | \(rhsInt)")
    }
  }

  func test_big_singleWord_vs_multipleWords() {
    let multiWords: [Word] = [3689348814741910327, 2459565876494606880]
    let singleWords: [Word] = [1844674407370955168]

    // Both positive
    var multi = BigInt(.positive, magnitude: multiWords)
    var single = BigInt(.positive, magnitude: singleWords)
    var expected = BigInt(.positive, magnitude: [4304240283865562039, 2459565876494606880])
    XCTAssertEqual(multi | single, expected)
    XCTAssertEqual(single | multi, expected)

    // Self negative, other positive
    multi = BigInt(.negative, magnitude: multiWords)
    single = BigInt(.positive, magnitude: singleWords)
    expected = BigInt(.negative, magnitude: [2459565876494606871, 2459565876494606880])
    XCTAssertEqual(multi | single, expected)
    XCTAssertEqual(single | multi, expected)

    // Self positive, other negative
    multi = BigInt(.positive, magnitude: multiWords)
    single = BigInt(.negative, magnitude: singleWords)
    expected = BigInt(.negative, magnitude: [614891469123651721])
    XCTAssertEqual(multi | single, expected)
    XCTAssertEqual(single | multi, expected)

    // Both negative
    multi = BigInt(.negative, magnitude: multiWords)
    single = BigInt(.negative, magnitude: singleWords)
    expected = BigInt(.negative, magnitude: [1229782938247303447])
    XCTAssertEqual(multi | single, expected)
    XCTAssertEqual(single | multi, expected)
  }

  func test_big_bothMultipleWords() {
    let lhsWords: [Word] = [1844674407370955168, 4304240283865562048]
    let rhsWords: [Word] = [3689348814741910327, 2459565876494606880]

    // Both positive
    var lhs = BigInt(.positive, magnitude: lhsWords)
    var rhs = BigInt(.positive, magnitude: rhsWords)
    var expected = BigInt(.positive, magnitude: [4304240283865562039, 4304240283865562080])
    XCTAssertEqual(lhs | rhs, expected)
    XCTAssertEqual(rhs | lhs, expected)

    // Self negative, other positive
    lhs = BigInt(.negative, magnitude: lhsWords)
    rhs = BigInt(.positive, magnitude: rhsWords)
    expected = BigInt(.negative, magnitude: [614891469123651721, 1844674407370955200])
    XCTAssertEqual(lhs | rhs, expected)
    XCTAssertEqual(rhs | lhs, expected)

    // Self positive, other negative
    lhs = BigInt(.positive, magnitude: lhsWords)
    rhs = BigInt(.negative, magnitude: rhsWords)
    expected = BigInt(.negative, magnitude: [2459565876494606871, 32])
    XCTAssertEqual(lhs | rhs, expected)
    XCTAssertEqual(rhs | lhs, expected)

    // Both negative
    lhs = BigInt(.negative, magnitude: lhsWords)
    rhs = BigInt(.negative, magnitude: rhsWords)
    expected = BigInt(.negative, magnitude: [1229782938247303447, 2459565876494606848])
    XCTAssertEqual(lhs | rhs, expected)
    XCTAssertEqual(rhs | lhs, expected)
  }
}
