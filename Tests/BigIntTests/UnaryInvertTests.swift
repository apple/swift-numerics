//===--- UnaryInvertTests.swift -------------------------------*- swift -*-===//
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

class UnaryInvertTests: XCTestCase {

  func test_int() {
    for int in generateInts(approximateCount: 100) {
      let big = BigInt(int)
      let result = ~big
      let expected = BigInt(~int)
      XCTAssertEqual(result, expected, "\(int)")
    }
  }

  func test_big() {
    for p in generateBigInts(approximateCount: 100) {
      let big = p.create()
      let result = ~big

      // We always change sign, '0' becomes '-1'
      XCTAssertNotEqual(result.isPositive, p.isPositive, "\(big)")

      // 2 complement (equal magnitude opposite sign): (~x) + 1
      let complement = result + 1
      XCTAssertEqual(complement.magnitude, big.magnitude, "\(big)")

      // x + (~x) = -1
      let add = big + result
      XCTAssertEqual(add, -1, "\(big)")
    }
  }
}
