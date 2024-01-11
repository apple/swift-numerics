//===--- EquatableTests.swift ---------------------------------*- swift -*-===//
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

// MARK: - Asserts

private func assertEqual(_ lhs: BigInt,
                         _ rhs: BigInt,
                         file: StaticString = #file,
                         line: UInt = #line) {
  XCTAssertTrue(lhs == rhs, "\(lhs) == \(rhs)", file: file, line: line)
  XCTAssertFalse(lhs != rhs, "[NOT EQUAL] \(lhs) != \(rhs)", file: file, line: line)
}

private func assertEqual(_ lhs: BigInt,
                         _ rhs: Int,
                         file: StaticString = #file,
                         line: UInt = #line) {
  XCTAssertTrue(lhs == rhs, "\(lhs) == \(rhs)", file: file, line: line)
  XCTAssertFalse(lhs != rhs, "[NOT EQUAL] \(lhs) != \(rhs)", file: file, line: line)
}

private func assertNotEqual(_ lhs: BigInt,
                            _ rhs: BigInt,
                            file: StaticString = #file,
                            line: UInt = #line) {
  XCTAssertFalse(lhs == rhs, "[EQUAL] \(lhs) == \(rhs)", file: file, line: line)
  XCTAssertTrue(lhs != rhs, "\(lhs) != \(rhs)", file: file, line: line)
}

private func assertNotEqual(_ lhs: BigInt,
                            _ rhs: Int,
                            file: StaticString = #file,
                            line: UInt = #line) {
  XCTAssertFalse(lhs == rhs, "[EQUAL] \(lhs) == \(rhs)", file: file, line: line)
  XCTAssertTrue(lhs != rhs, "\(lhs) != \(rhs)", file: file, line: line)
}

class EquatableTests: XCTestCase {

  // MARK: - Zero

  func test_zero() {
    let zero = BigInt()
    assertEqual(zero, zero)
    assertEqual(zero, -zero)
    assertEqual(zero, 2 * zero)
    assertEqual(zero, zero * 2)
    assertEqual(zero, -1 * zero)
    assertEqual(zero, zero * -1)
    assertEqual(zero, zero + 0)
    assertEqual(zero, zero + zero)
  }

  // MARK: - Int

  func test_int_equal() {
    for int in generateInts(approximateCount: 100) {
      let big = BigInt(int)
      assertEqual(big, int)
    }
  }

  func test_int_notEqual() {
    let ints = generateInts(approximateCount: 20)

    for (lhs, rhs) in CartesianProduct(ints) {
      if lhs == rhs {
        continue
      }

      let lhsBig = BigInt(lhs)
      let rhsBig = BigInt(rhs)

      assertNotEqual(lhsBig, rhsBig)
      assertNotEqual(lhsBig, rhs)
      assertNotEqual(rhsBig, lhs)
    }
  }

  func test_int_moreThan1Word_isNotEqual() {
    for int in generateInts(approximateCount: 20) {
      for p in generateBigInts(approximateCount: 20) {
        guard p.magnitude.count > 1 else {
          continue
        }

        let big = p.create()
        assertNotEqual(big, int)
      }
    }
  }

  // MARK: - Big

  func test_big_equal() {
    for p in generateBigInts(approximateCount: 100) {
      let lhs = p.create()
      let rhs = p.create()
      assertEqual(lhs, rhs)
    }
  }

  func test_big_withDifferentSign_isNeverEqual() {
    for p in generateBigInts(approximateCount: 100) {
      // '0' is always positive
      if p.isZero {
        continue
      }

      let lhs = p.create()
      let rhs = p.withOppositeSign.create()
      assertNotEqual(lhs, rhs)
    }
  }

  func test_big_withBiggerWords_isNeverEqual() {
    for p in generateBigInts(approximateCount: 20) {
      // '0' has no words
      if p.isZero {
        continue
      }

      let original = p.create()

      for b in p.withEachMagnitudeWordModified(byAdding: 3) {
        let bigger = b.create()
        assertNotEqual(original, bigger)
      }
    }
  }

  func test_big_withSmallerWords_isNeverEqual() {
    for p in generateBigInts(approximateCount: 20) {
      // '0' has no words
      if p.isZero {
        continue
      }

      let original = p.create()

      for s in p.withEachMagnitudeWordModified(byAdding: -3) {
        let smaller = s.create()
        assertNotEqual(original, smaller)
      }
    }
  }

  func test_big_moreWords_isNeverEqual() {
    for p in generateBigInts(approximateCount: 20) {
      let original = p.create()
      let moreWords = p.withAddedWord(word: 42).create()
      assertNotEqual(original, moreWords)
    }
  }

  func test_big_lessWords_isNeverEqual() {
    for p in generateBigInts(approximateCount: 20) {
      // We can't remove word if we don't have any!
      if p.isZero {
        continue
      }

      let original = p.create()
      let lessWords = p.withRemovedWord.create()
      assertNotEqual(original, lessWords)
    }
  }
}
