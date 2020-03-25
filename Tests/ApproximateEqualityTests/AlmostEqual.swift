//===--- ApproximateEqualityTests.swift -----------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import ApproximateEquality

final class AlmostEqualTests: XCTestCase {

  func testAlmostEqual<T: BinaryFloatingPoint>(
    _ type: T.Type
  ) where T.RawSignificand: FixedWidthInteger, T.Exponent: FixedWidthInteger {
    // Values for testing:
    var values = (type.leastNonzeroMagnitude.exponent ...
                  type.greatestFiniteMagnitude.exponent).flatMap {
      exp in [
        type.init(sign: .plus, exponent: exp, significand: 1).nextDown,
        type.init(sign: .plus, exponent: exp, significand: 1),
        type.init(sign: .plus, exponent: exp, significand: 1).nextUp,
        type.init(sign: .plus, exponent: exp, significand: .random(in: 1..<2))
      ]
    }
    values.append(.infinity)

    // Tolerances for testing:
    let tolerances = [
        2 * type.ulpOfOne, .random(in: .ulpOfOne..<1), type.init(1).nextDown
    ]

    // NaN is not almost equal to anything, with any tolerance.
    XCTAssertFalse(type.nan.isAlmostEqual(to: .nan))
    for tol in tolerances {
      XCTAssertFalse(type.nan.isAlmostEqual(to: .nan, tolerance: tol))
    }
    for val in values {
      XCTAssertFalse(type.nan.isAlmostEqual(to: val))
      XCTAssertFalse(val.isAlmostEqual(to: .nan))
      for tol in tolerances {
        XCTAssertFalse(type.nan.isAlmostEqual(to: val, tolerance: tol))
        XCTAssertFalse(val.isAlmostEqual(to: .nan, tolerance: tol))
      }
    }

    for val in values {
      XCTAssertTrue(val.isAlmostEqual(to: val))
      XCTAssertTrue(val.isAlmostEqual(to: val.nextUp))
      XCTAssertTrue(val.nextUp.isAlmostEqual(to: val))
      XCTAssertTrue(val.isAlmostEqual(to: val.nextDown))
      XCTAssertTrue(val.nextDown.isAlmostEqual(to: val))
      for tol in tolerances {
        XCTAssertTrue(val.isAlmostEqual(to: val, tolerance: tol))
        XCTAssertTrue(val.isAlmostEqual(to: val.nextUp, tolerance: tol))
        XCTAssertTrue(val.nextUp.isAlmostEqual(to: val, tolerance: tol))
        XCTAssertTrue(val.isAlmostEqual(to: val.nextDown, tolerance: tol))
        XCTAssertTrue(val.nextDown.isAlmostEqual(to: val, tolerance: tol))
      }
    }
  }

  func testAlmostEqual() {
    testAlmostEqual(Float.self)
    testAlmostEqual(Double.self)
    #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    testAlmostEqual(Float80.self)
    #endif
  }
}
