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

final class AlmostZeroTests: XCTestCase {

  func testAlmostZero<T: FloatingPoint>(_ type: T.Type) {
    for val in [
      type.ulpOfOne.squareRoot(), 1, .greatestFiniteMagnitude,
      .infinity, .nan
    ] {
      XCTAssertFalse(val.isAlmostZero())
      XCTAssertFalse((-val).isAlmostZero())
    }

    for val in [
      type.ulpOfOne.squareRoot().nextDown, .leastNormalMagnitude,
      .leastNonzeroMagnitude, 0
    ] {
      XCTAssertTrue(val.isAlmostZero())
      XCTAssertTrue((-val).isAlmostZero())
    }
  }

  func testAlmostZero() {
    testAlmostZero(Float.self)
    testAlmostZero(Double.self)
    #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    testAlmostZero(Float80.self)
    #endif
  }
}
