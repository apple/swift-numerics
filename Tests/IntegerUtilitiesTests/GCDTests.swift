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
    XCTAssertEqual(gcd(0, 0), 0)
    XCTAssertEqual(gcd(0, 1), 1)
    XCTAssertEqual(gcd(1, 0), 1)
    XCTAssertEqual(gcd(0, -1), 1)
    XCTAssertEqual(gcd(1, 1), 1)
    XCTAssertEqual(gcd(1, 2), 1)
    XCTAssertEqual(gcd(2, 2), 2)
    XCTAssertEqual(gcd(4, 2), 2)
    XCTAssertEqual(gcd(6, 8), 2)
    XCTAssertEqual(gcd(77, 91), 7)
    XCTAssertEqual(gcd(24, -36), 12)
    XCTAssertEqual(gcd(-24, -36), 12)
    XCTAssertEqual(gcd(51, 34), 17)
    XCTAssertEqual(gcd(64, 96), 32)
    XCTAssertEqual(gcd(-64, 96), 32)
    XCTAssertEqual(gcd(4*7*19, 27*25), 1)
    XCTAssertEqual(gcd(16*315, 11*315), 315)
    XCTAssertEqual(gcd(97*67*53*27*8, 83*67*53*9*32), 67*53*9*8)
    XCTAssertEqual(gcd(Int.min, 2), 2)
    
    // TODO: Enable these when version compatibility allows.
    //
    // XCTExpectFailure{ gcd(0, Int.min) }
    // XCTExpectFailure{ gcd(Int.min, 0) }
    // XCTExpectFailure{ gcd(Int.min, Int.min) }
  }
}
