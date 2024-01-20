//===--- StringTests.swift ------------------------------------*- swift -*-===//
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

private typealias TestSuite = StringTestCases.TestSuite
private typealias TestCase = StringTestCases.TestCase
private typealias BinaryTestCases = StringTestCases.Binary
private typealias QuinaryTestCases = StringTestCases.Quinary
private typealias OctalTestCases = StringTestCases.Octal
private typealias DecimalTestCases = StringTestCases.Decimal
private typealias HexTestCases = StringTestCases.Hex

class StringTests: XCTestCase {

  // MARK: - Description

  func test_description_trivial() {
    XCTAssertEqual(String(describing: BigInt(0)), "0")
    XCTAssertEqual(String(describing: BigInt(1)), "1")
    XCTAssertEqual(String(describing: BigInt(42)), "42")
    XCTAssertEqual(String(describing: BigInt(-1)), "-1")
    XCTAssertEqual(String(describing: BigInt(-42)), "-42")
  }

  func test_description_int() {
    for int in generateInts(approximateCount: 100) {
      let value = BigInt(int)
      XCTAssertEqual(value.description, int.description, "\(int)")
    }
  }

  func test_description_singleWord() {
    self.runDescriptionTests(suite: DecimalTestCases.singleWord)
  }

  func test_description_twoWords() {
    self.runDescriptionTests(suite: DecimalTestCases.twoWords)
  }

  func test_description_threeWords() {
    self.runDescriptionTests(suite: DecimalTestCases.threeWords)
  }

  func test_description_fourWords() {
    self.runDescriptionTests(suite: DecimalTestCases.fourWords)
  }

  private func runDescriptionTests(suite: TestSuite,
                                   file: StaticString = #file,
                                   line: UInt = #line) {
    for testCase in suite.cases {
      let value = testCase.create()
      let expected = testCase.string
      XCTAssertEqual(value.description,
                     expected,
                     file: file,
                     line: line)

      if value != 0 {
        let valueNegative = testCase.create(sign: .negative)
        let expectedNegative = "-" + testCase.string
        XCTAssertEqual(valueNegative.description,
                       expectedNegative,
                       "NEGATIVE",
                       file: file,
                       line: line)
      }
    }
  }

  // MARK: - Binary

  func test_binary_singleWord() {
    self.run(suite: BinaryTestCases.singleWord)
  }

  func test_binary_twoWords() {
    self.run(suite: BinaryTestCases.twoWords)
  }

  // MARK: - Quinary

  func test_quinary_singleWord() {
    self.run(suite: QuinaryTestCases.singleWord)
  }

  func test_quinary_twoWords() {
    self.run(suite: QuinaryTestCases.twoWords)
  }

  // MARK: - Octal

  func test_octal_singleWord() {
    self.run(suite: OctalTestCases.singleWord)
  }

  func test_octal_twoWords() {
    self.run(suite: OctalTestCases.twoWords)
  }

  func test_octal_threeWords() {
    self.run(suite: OctalTestCases.threeWords)
  }

  // MARK: - Decimal

  func test_decimal_singleWord() {
    self.run(suite: DecimalTestCases.singleWord)
  }

  func test_decimal_twoWords() {
    self.run(suite: DecimalTestCases.twoWords)
  }

  func test_decimal_threeWords() {
    self.run(suite: DecimalTestCases.threeWords)
  }

  func test_decimal_fourWords() {
    self.run(suite: DecimalTestCases.fourWords)
  }

  // MARK: - Hex

  func test_hex_singleWord() {
    self.run(suite: HexTestCases.singleWord)
  }

  func test_hex_twoWords() {
    self.run(suite: HexTestCases.twoWords)
  }

  func test_hex_threeWords() {
    self.run(suite: HexTestCases.threeWords)
  }

  // MARK: - Helpers

  /// Abstraction over `BigInt.init(_:radix:)`.
  private func create(string: String, radix: Int) -> BigInt? {
    return BigInt(string, radix: radix)
  }

  private func run(suite: TestSuite,
                   file: StaticString = #file,
                   line: UInt = #line) {
    let radix = suite.radix

    for testCase in suite.cases {
      let value = testCase.create()
      let valueNegative = testCase.create(sign: .negative)

      let expectedLower = testCase.string
      let expectedUpper = testCase.string.uppercased()

      let positiveLower = String(value, radix: radix, uppercase: false)
      XCTAssertEqual(positiveLower,
                     expectedLower,
                     "LOWERCASE \(value)",
                     file: file,
                     line: line)

      let positiveUpper = String(value, radix: radix, uppercase: true)
      XCTAssertEqual(positiveUpper,
                     expectedUpper,
                     "UPPERCASE \(value)",
                     file: file,
                     line: line)

      let negativeLower = String(valueNegative, radix: radix, uppercase: false)
      XCTAssertEqual(negativeLower,
                     "-" + expectedLower,
                     "NEGATIVE LOWERCASE \(value)",
                     file: file,
                     line: line)

      let negativeUpper = String(valueNegative, radix: radix, uppercase: true)
      XCTAssertEqual(negativeUpper,
                     "-" + expectedUpper,
                     "NEGATIVE UPPERCASE \(value)",
                     file: file,
                     line: line)
    }
  }
}
