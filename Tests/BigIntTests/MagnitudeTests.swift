//===--- MagnitudeTests.swift ---------------------------------*- swift -*-===//
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

class MagnitudeTests: XCTestCase {

  func test_int() {
    for int in generateInts(approximateCount: 100) {
      let big = BigInt(int)
      let magnitude = big.magnitude
      let expected = BigInt(int.magnitude)
      XCTAssertEqual(magnitude, expected)
    }
  }

  func test_big() {
    for p in generateBigInts(approximateCount: 100) {
      if p.isZero {
        continue
      }

      let positive = BigInt(.positive, magnitude: p.magnitude)
      let positiveMagnitude = positive.magnitude

      let negative = BigInt(.negative, magnitude: p.magnitude)
      let negativeMagnitude = negative.magnitude

      XCTAssertGreaterThanOrEqual(positiveMagnitude, 0)
      XCTAssertGreaterThanOrEqual(negativeMagnitude, 0)
      XCTAssertEqual(positive, negativeMagnitude)
      XCTAssertEqual(positiveMagnitude, negativeMagnitude)
    }
  }
}
