//===--- ApplyA_ApplyB_Equals_ApplyAB.swift -------------------*- swift -*-===//
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

private typealias Word = BigInt.Word

// MARK: - Test case

/// `∀x, (x+a)+b = x+(a+b)`
private struct TestCase {

  fileprivate typealias Operation = (BigInt, BigInt) -> BigInt

  fileprivate let a: BigInt
  fileprivate let b: BigInt
  fileprivate let ab: BigInt

  fileprivate init<A: BinaryInteger, B: BinaryInteger>(_ op: Operation, a: A, b: B) {
    self.a = BigInt(a)
    self.b = BigInt(b)
    self.ab = op(self.a, self.b)
  }

  fileprivate init?(
    _ op: Operation,
    a: String,
    b: String,
    file: StaticString,
    line: UInt
  ) {
    if let aInt = BigInt(a) {
      self.a = aInt
    } else {
      XCTFail("Unable to parse: '\(a)'.", file: file, line: line)
      return nil
    }

    if let bInt = BigInt(b) {
      self.b = bInt
    } else {
      XCTFail("Unable to parse: '\(b)'.", file: file, line: line)
      return nil
    }

    self.ab = op(self.a, self.b)
  }
}

private func createTestCases(_ op: TestCase.Operation,
                             useBigNumbers: Bool = true,
                             file: StaticString,
                             line: UInt) -> [TestCase]? {
  var strings = [
    "0",
    "1", "-1",
    "2147483647", "-2147483647",
    "429496735", "-429496735",
    "214748371", "-214748371",
    "18446744073709551615", "-18446744073709551615"
  ]

  if useBigNumbers {
    strings.append(contentsOf: [
      "340282366920938463481821351505477763074",
      "-340282366920938463481821351505477763074",
      "6277101735386680764516354157049543343010657915253861384197",
      "-6277101735386680764516354157049543343010657915253861384197"
    ])
  }

  var result = [TestCase]()

  for (a, b) in CartesianProduct(strings) {
    if let testCase = TestCase(op, a: a, b: b, file: file, line: line) {
      result.append(testCase)
    } else {
      return nil
    }
  }

  return result
}

// MARK: - Test class

/// Operation that applied 2 times can also be expressed as a single application.
/// For example: `∀x, (x+a)+b = x+(a+b)`.
///
/// This is not exactly associativity, because we will also do this for shifts:
/// `(x >> a) >> b = x >> (a + b)`.
class ApplyA_ApplyB_Equals_ApplyAB: XCTestCase {

  private lazy var ints = generateInts(approximateCount: 20)
  private lazy var bigs = generateBigInts(approximateCount: 20)

  // MARK: - Add

  func test_add_int() {
    for x in self.ints {
      let int = self.create(x)
      self.addTest(value: int)
    }
  }

  func test_add_big() {
    for x in self.bigs {
      let int = self.create(x)
      self.addTest(value: int)
    }
  }

  private func addTest(value: BigInt,
                       file: StaticString = #file,
                       line: UInt = #line) {
    guard let testCases = createTestCases(+, file: file, line: line) else {
      return
    }

    for testCase in testCases {
      let a_b = value + testCase.a + testCase.b
      let ab = value + testCase.ab

      XCTAssertEqual(
        a_b,
        ab,
        "\(value) + \(testCase.a) + \(testCase.b) vs \(value) + \(testCase.ab)",
        file: file,
        line: line
      )

      var inoutA_B = value
      inoutA_B += testCase.a
      inoutA_B += testCase.b

      var inoutAB = value
      inoutAB += testCase.ab
      assert(inoutAB == ab)

      XCTAssertEqual(
        inoutA_B,
        inoutAB,
        "inout: \(value) + \(testCase.a) + \(testCase.b) vs \(value) + \(testCase.ab)",
        file: file,
        line: line
      )
    }
  }

  // MARK: - Sub

  func test_sub_int() {
    for x in self.ints {
      let int = self.create(x)
      self.subTest(value: int)
    }
  }

  func test_sub_big() {
    for x in self.bigs {
      let int = self.create(x)
      self.subTest(value: int)
    }
  }

  private func subTest(value: BigInt,
                       file: StaticString = #file,
                       line: UInt = #line) {
    // '+' because: (x-a)-b = x-(a+b)
    guard let testCases = createTestCases(+, file: file, line: line) else {
      return
    }

    for testCase in testCases {
      let a_b = value - testCase.a - testCase.b
      let ab = value - testCase.ab

      XCTAssertEqual(
        a_b,
        ab,
        "\(value) - \(testCase.a) - \(testCase.b) vs \(value) - \(testCase.ab)",
        file: file,
        line: line
      )

      var inoutA_B = value
      inoutA_B -= testCase.a
      inoutA_B -= testCase.b

      var inoutAB = value
      inoutAB -= testCase.ab
      assert(inoutAB == ab)

      XCTAssertEqual(
        inoutA_B,
        inoutAB,
        "inout: \(value) - \(testCase.a) - \(testCase.b) vs \(value) - \(testCase.ab)",
        file: file,
        line: line
      )
    }
  }

  // MARK: - Mul

  func test_mul_int() {
    for x in self.ints {
      let int = self.create(x)
      self.mulTest(value: int)
    }
  }

  func test_mul_big() {
    for x in self.bigs {
      let int = self.create(x)
      self.mulTest(value: int)
    }
  }

  private func mulTest(value: BigInt,
                       file: StaticString = #file,
                       line: UInt = #line) {
    guard let testCases = createTestCases(*,
                                          useBigNumbers: false,
                                          file: file,
                                          line: line) else {
      return
    }

    for testCase in testCases {
      let a_b = value * testCase.a * testCase.b
      let ab = value * testCase.ab

      XCTAssertEqual(
        a_b,
        ab,
        "\(value) * \(testCase.a) * \(testCase.b) vs \(value) * \(testCase.ab)",
        file: file,
        line: line
      )

      var inoutA_B = value
      inoutA_B *= testCase.a
      inoutA_B *= testCase.b

      var inoutAB = value
      inoutAB *= testCase.ab
      assert(inoutAB == ab)

      XCTAssertEqual(
        inoutA_B,
        inoutAB,
        "inout: \(value) * \(testCase.a) * \(testCase.b) vs \(value) * \(testCase.ab)",
        file: file,
        line: line
      )
    }
  }

  // MARK: - Div

  func test_div_int() {
    for x in self.ints {
      let int = self.create(x)
      self.divTest(value: int)
    }
  }

  func test_div_big() {
    for x in self.bigs {
      let int = self.create(x)
      self.divTest(value: int)
    }
  }

  private let divTestCases = [
    TestCase(*, a: 3, b: 5),
    TestCase(*, a: 3, b: -5),
    TestCase(*, a: -3, b: 5),
    TestCase(*, a: -3, b: -5)
  ]

  private func divTest(value: BigInt,
                       file: StaticString = #file,
                       line: UInt = #line) {
    for testCase in self.divTestCases {
      let a_b = value / testCase.a / testCase.b
      let ab = value / testCase.ab

      XCTAssertEqual(
        a_b,
        ab,
        "\(value) / \(testCase.a) / \(testCase.b) vs \(value) / \(testCase.ab)",
        file: file,
        line: line
      )

      var inoutA_B = value
      inoutA_B /= testCase.a
      inoutA_B /= testCase.b

      var inoutAB = value
      inoutAB /= testCase.ab
      assert(inoutAB == ab)

      XCTAssertEqual(
        inoutA_B,
        inoutAB,
        "inout: \(value) / \(testCase.a) / \(testCase.b) vs \(value) / \(testCase.ab)",
        file: file,
        line: line
      )
    }
  }

  // MARK: - Left shift

  func test_shiftLeft_int() {
    for x in self.ints {
      let int = self.create(x)
      self.shiftLeftTest(value: int)
    }
  }

  func test_shiftLeft_big() {
    for x in self.bigs {
      let int = self.create(x)
      self.shiftLeftTest(value: int)
    }
  }

  // '+' because: (x << 3) << 5 = x << (3+5)
  private let shiftLeftTestCases: [TestCase] = [
    // Shift by 0 is important to test!
    TestCase(+, a: 1, b: 0),
    TestCase(+, a: 1, b: 1),
    TestCase(+, a: 3, b: 5),
    // More than Word
    TestCase(+, a: 7, b: Word.bitWidth - 5),
    TestCase(+, a: Word.bitWidth - 5, b: 7)
  ]

  private func shiftLeftTest(value: BigInt,
                             file: StaticString = #file,
                             line: UInt = #line) {
    for testCase in self.shiftLeftTestCases {
      let a_b = (value << testCase.a) << testCase.b
      let ab = value << testCase.ab

      XCTAssertEqual(
        a_b,
        ab,
        "(\(value) << \(testCase.a)) << \(testCase.b) vs \(value) << \(testCase.ab)",
        file: file,
        line: line
      )

      var inoutA_B = value
      inoutA_B <<= testCase.a
      inoutA_B <<= testCase.b

      var inoutAB = value
      inoutAB <<= testCase.ab
      assert(inoutAB == ab)

      XCTAssertEqual(
        inoutA_B,
        inoutAB,
        "inout: (\(value) << \(testCase.a)) << \(testCase.b) vs \(value) << \(testCase.ab)",
        file: file,
        line: line
      )
    }
  }

  // MARK: - Right shift

  func test_shiftRight_int() {
    for x in self.ints {
      let int = self.create(x)
      self.shiftRightTest(value: int)
    }
  }

  func test_shiftRight_big() {
    for x in self.bigs {
      let int = self.create(x)
      self.shiftRightTest(value: int)
    }
  }

  // '+' because: (x >> 3) >> 5 = x >> (3+5)
  //
  // Right shift for more than 'Word.bitWidth' has a high probability
  // of shifting value into oblivion (0 or -1).
  private let shiftRightTestCases: [TestCase] = [
    // Shift by 0 is important to test!
    TestCase(+, a: 1, b: 0),
    TestCase(+, a: 1, b: 1),
    TestCase(+, a: 3, b: 5),
    // More than Word
    TestCase(+, a: 7, b: Word.bitWidth - 5),
    TestCase(+, a: Word.bitWidth - 5, b: 7)
  ]

  private func shiftRightTest(value: BigInt,
                              file: StaticString = #file,
                              line: UInt = #line) {
    for testCase in self.shiftRightTestCases {
      let a_b = (value >> testCase.a) >> testCase.b
      let ab = value >> testCase.ab

      XCTAssertEqual(
        a_b,
        ab,
        "(\(value) >> \(testCase.a)) >> \(testCase.b) vs \(value) >> \(testCase.ab)",
        file: file,
        line: line
      )

      var inoutA_B = value
      inoutA_B >>= testCase.a
      inoutA_B >>= testCase.b

      var inoutAB = value
      inoutAB >>= testCase.ab
      assert(inoutAB == ab)

      XCTAssertEqual(
        inoutA_B,
        inoutAB,
        "inout: (\(value) >> \(testCase.a)) >> \(testCase.b) vs \(value) >> \(testCase.ab)",
        file: file,
        line: line
      )
    }
  }

  // MARK: - Helpers

  private func create(_ int: Int) -> BigInt {
    return BigInt(int)
  }

  private func create(_ p: BigIntPrototype) -> BigInt {
    return p.create()
  }
}
