//===--- GCDTests.swift ---------------------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import IntegerUtilities
import XCTest

final class IntegerUtilitiesGCDTests: XCTestCase {
  func testGCDInt() {
    XCTAssertEqual(Int.gcd(0, 0), 0)
    XCTAssertEqual(Int.gcd(0, 1), 1)
    XCTAssertEqual(Int.gcd(1, 0), 1)
    XCTAssertEqual(Int.gcd(0, -1), 1)
    XCTAssertEqual(Int.gcd(1, 1), 1)
    XCTAssertEqual(Int.gcd(1, 2), 1)
    XCTAssertEqual(Int.gcd(2, 2), 2)
    XCTAssertEqual(Int.gcd(4, 2), 2)
    XCTAssertEqual(Int.gcd(6, 8), 2)
    XCTAssertEqual(Int.gcd(77, 91), 7)
    XCTAssertEqual(Int.gcd(24, -36), 12)
    XCTAssertEqual(Int.gcd(-24, -36), 12)
    XCTAssertEqual(Int.gcd(51, 34), 17)
    XCTAssertEqual(Int.gcd(64, 96), 32)
    XCTAssertEqual(Int.gcd(-64, 96), 32)
    XCTAssertEqual(Int.gcd(4*7*19, 27*25), 1)
    XCTAssertEqual(Int.gcd(16*315, 11*315), 315)
    XCTAssertEqual(Int.gcd(97*67*53*27*8, 83*67*53*9*32), 67*53*9*8)
    XCTAssertEqual(Int.gcd(Int.min, 2), 2)
  }
}
