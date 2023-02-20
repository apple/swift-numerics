//===--- ApplyA_UndoA.swift -----------------------------------*- swift -*-===//
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

// swiftlint:disable type_name

private typealias Word = BigInt.Word

/// Operations for which exists 'reverse' operation that undoes its effect.
/// For example for addition it is subtraction: `(n + x) - x = n`.
class ApplyA_UndoA: XCTestCase {

  private lazy var ints = generateInts(approximateCount: 20)
  private lazy var bigs = generateBigInts(approximateCount: 20)

  private lazy var intInt = CartesianProduct(self.ints)
  private lazy var intBig = CartesianProduct(self.ints, self.bigs)
  private lazy var bigInt = CartesianProduct(self.bigs, self.ints)
  private lazy var bigBig = CartesianProduct(self.bigs, self.bigs)

  // MARK: - Add, sub

  func test_addSub_intInt() {
    for (lhsRaw, rhsRaw) in self.intInt {
      let lhs = self.create(lhsRaw)
      let rhs = self.create(rhsRaw)
      self.addSub(lhs: lhs, rhs: rhs)
    }
  }

  func test_addSub_intBig() {
    for (lhsRaw, rhsRaw) in self.intBig {
      let lhs = self.create(lhsRaw)
      let rhs = self.create(rhsRaw)
      self.addSub(lhs: lhs, rhs: rhs)
    }
  }

  func test_addSub_bigInt() {
    for (lhsRaw, rhsRaw) in self.bigInt {
      let lhs = self.create(lhsRaw)
      let rhs = self.create(rhsRaw)
      self.addSub(lhs: lhs, rhs: rhs)
    }
  }

  func test_addSub_bigBig() {
    for (lhsRaw, rhsRaw) in self.bigBig {
      let lhs = self.create(lhsRaw)
      let rhs = self.create(rhsRaw)
      self.addSub(lhs: lhs, rhs: rhs)
    }
  }

  private func addSub(lhs: BigInt,
                      rhs: BigInt,
                      file: StaticString = #file,
                      line: UInt = #line) {
    let expectedLhs = (lhs + rhs) - rhs
    XCTAssertEqual(lhs, expectedLhs, "\(lhs) +- \(rhs)", file: file, line: line)
  }

  // MARK: - Mul, div

  func test_mulDiv_intInt() {
    for (lhsRaw, rhsRaw) in self.intInt {
      let lhs = self.create(lhsRaw)
      let rhs = self.create(rhsRaw)
      self.mulDiv(lhs: lhs, rhs: rhs)
    }
  }

  func test_mulDiv_intBig() {
    for (lhsRaw, rhsRaw) in self.intBig {
      let lhs = self.create(lhsRaw)
      let rhs = self.create(rhsRaw)
      self.mulDiv(lhs: lhs, rhs: rhs)
    }
  }

  func test_mulDiv_bigInt() {
    for (lhsRaw, rhsRaw) in self.bigInt {
      let lhs = self.create(lhsRaw)
      let rhs = self.create(rhsRaw)
      self.mulDiv(lhs: lhs, rhs: rhs)
    }
  }

  func test_mulDiv_bigBig() {
    for (lhsRaw, rhsRaw) in self.bigBig {
      let lhs = self.create(lhsRaw)
      let rhs = self.create(rhsRaw)
      self.mulDiv(lhs: lhs, rhs: rhs)
    }
  }

  private func mulDiv(lhs: BigInt,
                      rhs: BigInt,
                      file: StaticString = #file,
                      line: UInt = #line) {
    if rhs == 0 {
      return
    }

    let expectedLhs = (lhs * rhs) / rhs
    XCTAssertEqual(lhs, expectedLhs, "\(lhs) */ \(rhs)", file: file, line: line)
  }

  // MARK: - Shift left, right

  func test_shiftLeftRight_int() {
    for x in self.ints {
      let value = self.create(x)
      self.shiftLeftRight(value: value)
    }
  }

  func test_shiftLeftRight_big() {
    for x in self.bigs {
      let value = self.create(x)
      self.shiftLeftRight(value: value)
    }
  }

  private func shiftLeftRight(value: BigInt,
                              file: StaticString = #file,
                              line: UInt = #line) {
    let lessThanWord = 5
    let word = Word.bitWidth
    let moreThanWord = Word.bitWidth + Word.bitWidth - 7

    for count in [lessThanWord, word, moreThanWord] {
      let result = (value << count) >> count
      XCTAssertEqual(result, value, "\(value) <<>> \(count)", file: file, line: line)
    }
  }

  // MARK: - To string, init

  func test_toStringInit_ints() {
    for x in self.ints {
      let value = self.create(x)
      self.toStringInit(value: value)
    }
  }

  func test_toStringInit_big() {
    for x in self.bigs {
      let value = self.create(x)
      self.toStringInit(value: value)
    }
  }

  private func toStringInit(value: BigInt,
                            file: StaticString = #file,
                            line: UInt = #line) {
    for radix in [2, 5, 10, 16] {
      let string = String(value, radix: radix)

      if let int = BigInt(string, radix: radix) {
        XCTAssertEqual(int, value, "\(string), radix: \(radix)", file: file, line: line)
      } else {
        XCTFail("\(string), radix: \(radix)", file: file, line: line)
      }
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
