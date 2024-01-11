//===--- ComparableTests.swift --------------------------------*- swift -*-===//
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
                         _ rhs: Int,
                         file: StaticString = #file,
                         line: UInt = #line) {
  let rhsBig = BigInt(rhs)
  assertEqual(lhs, rhsBig, file: file, line: line)
}

private func assertEqual(_ lhs: BigInt,
                         _ rhs: BigInt,
                         file: StaticString = #file,
                         line: UInt = #line) {
  XCTAssertTrue(lhs == rhs, "\(lhs) == \(rhs)", file: file, line: line)
  XCTAssertFalse(lhs < rhs, "\(lhs) < \(rhs)", file: file, line: line)
  XCTAssertTrue(lhs <= rhs, "\(lhs) <= \(rhs)", file: file, line: line)
  XCTAssertFalse(lhs > rhs, "\(lhs) > \(rhs)", file: file, line: line)
  XCTAssertTrue(lhs >= rhs, "\(lhs) >= \(rhs)", file: file, line: line)
}

private func assertLess(_ lhs: BigInt,
                        _ rhs: Int,
                        file: StaticString = #file,
                        line: UInt = #line) {
  let rhsBig = BigInt(rhs)
  assertLess(lhs, rhsBig, file: file, line: line)
}

private func assertLess(_ lhs: BigInt,
                        _ rhs: BigInt,
                        file: StaticString = #file,
                        line: UInt = #line) {
  XCTAssertFalse(lhs == rhs, "\(lhs) == \(rhs)", file: file, line: line)
  XCTAssertTrue(lhs < rhs, "\(lhs) < \(rhs)", file: file, line: line)
  XCTAssertTrue(lhs <= rhs, "\(lhs) <= \(rhs)", file: file, line: line)
  XCTAssertFalse(lhs > rhs, "\(lhs) > \(rhs)", file: file, line: line)
  XCTAssertFalse(lhs >= rhs, "\(lhs) <= \(rhs)", file: file, line: line)
}

private func assertGreater(_ lhs: BigInt,
                           _ rhs: Int,
                           file: StaticString = #file,
                           line: UInt = #line) {
  let rhsBig = BigInt(rhs)
  assertGreater(lhs, rhsBig, file: file, line: line)
}

private func assertGreater(_ lhs: BigInt,
                           _ rhs: BigInt,
                           file: StaticString = #file,
                           line: UInt = #line) {
  XCTAssertFalse(lhs == rhs, "\(lhs) == \(rhs)", file: file, line: line)
  XCTAssertFalse(lhs < rhs, "\(lhs) < \(rhs)", file: file, line: line)
  XCTAssertFalse(lhs <= rhs, "\(lhs) <= \(rhs)", file: file, line: line)
  XCTAssertTrue(lhs > rhs, "\(lhs) > \(rhs)", file: file, line: line)
  XCTAssertTrue(lhs >= rhs, "\(lhs) <= \(rhs)", file: file, line: line)
}

class ComparableTests: XCTestCase {

  // MARK: - Int

  func test_int_equal() {
    for int in generateInts(approximateCount: 100) {
      let big = BigInt(int)
      assertEqual(big, int)
    }
  }

  func test_int_differentSign_negative_isLess() {
    let ints = generateInts(approximateCount: 20)

    for (positive, negative) in CartesianProduct(ints) {
      // '-min' is not representable as 'Int'
      // '0' stays the same after negation
      if positive == .min || negative == 0 {
        continue
      }

      let positiveInt = positive >= 0 ? positive : -positive
      let negativeInt = negative < 0 ? negative : -negative
      let negativeBig = BigInt(negativeInt)

      assertLess(negativeBig, positiveInt)
    }
  }

  func test_int_minus1_isLess() {
    for int in generateInts(approximateCount: 100) {
      // '.min - 1' overflows
      if int == .min {
        continue
      }

      let minus1 = BigInt(int - 1)
      assertLess(minus1, int)
    }
  }

  func test_int_plus1_isGreater() {
    for int in generateInts(approximateCount: 100) {
      // '.max + 1' overflows
      if int == .max {
        continue
      }

      let plus1 = BigInt(int + 1)
      assertGreater(plus1, int)
    }
  }

  func test_int_sameSign_moreThan1Word() {
    for int in generateInts(approximateCount: 20) {
      for p in generateBigInts(approximateCount: 20) {
        guard p.magnitude.count > 1 else {
          continue
        }

        // We need the same sign as 'int'
        let pp = BigIntPrototype(isPositive: int >= 0, magnitude: p.magnitude)
        let big = pp.create()

        // positive - more words -> bigger number
        // negative - more words -> smaller number
        if int >= 0 {
          assertGreater(big, int)
        } else {
          assertLess(big, int)
        }
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

  func test_big_differentSign_negative_isLess() {
    let ints = generateBigInts(approximateCount: 20)

    for (p, n) in CartesianProduct(ints) {
      // '0' stays the same after negation
      if n.isZero {
        continue
      }

      let positive = BigInt(.positive, magnitude: p.magnitude)
      let negative = BigInt(.negative, magnitude: n.magnitude)
      assertLess(negative, positive)
    }
  }

  func test_big_minus1_isLess() {
    for p in generateBigInts(approximateCount: 100) {
      let value = p.create()
      let minus1 = value - 1
      assertLess(minus1, value)
    }
  }

  func test_big_plus1_isGreater() {
    for p in generateBigInts(approximateCount: 100) {
      let value = p.create()
      let plus1 = value + 1
      assertGreater(plus1, value)
    }
  }

  func test_big_sameSign_biggerWords() {
    for p in generateBigInts(approximateCount: 20) {
      // '0' has no words
      if p.isZero {
        continue
      }

      let original = p.create()

      for b in p.withEachMagnitudeWordModified(byAdding: 3) {
        let bigger = b.create()

        // positive - more words -> bigger number
        // negative - more words -> smaller number
        if p.isPositive {
          assertGreater(bigger, original)
        } else {
          assertLess(bigger, original)
        }
      }
    }
  }

  func test_big_sameSign_smallerWords() {
    for p in generateBigInts(approximateCount: 20) {
      // '0' has no words
      if p.isZero {
        continue
      }

      let original = p.create()

      for s in p.withEachMagnitudeWordModified(byAdding: -3) {
        let smaller = s.create()

        // positive - less words -> smaller number
        // negative - less words -> bigger number
        if p.isPositive {
          assertLess(smaller, original)
        } else {
          assertGreater(smaller, original)
        }
      }
    }
  }

  func test_big_sameSign_moreWords() {
    for p in generateBigInts(approximateCount: 100) {
      let original = p.create()
      let moreWords = p.withAddedWord(word: 42).create()

      // positive - more words -> bigger number
      // negative - more words -> smaller number
      if p.isPositive {
        assertGreater(moreWords, original)
      } else {
        assertLess(moreWords, original)
      }
    }
  }

  func test_big_sameSign_lessWords() {
    for p in generateBigInts(approximateCount: 100) {
      // We can't remove word if we don't have any!
      if p.isZero {
        continue
      }

      let original = p.create()
      let lessWords = p.withRemovedWord.create()

      // positive - less words -> smaller number
      // negative - less words -> bigger number
      if p.isPositive {
        assertLess(lessWords, original)
      } else {
        assertGreater(lessWords, original)
      }
    }
  }
}
