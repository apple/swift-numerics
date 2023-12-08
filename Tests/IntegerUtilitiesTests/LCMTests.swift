//===--- LCMTests.swift ---------------------------------------*- swift -*-===//
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

final class IntegerUtilitiesLCMTests: XCTestCase {
    func testLCMInt() {
        XCTAssertEqual(lcm(2), 2)
        XCTAssertEqual(lcm(0, 0, 0, 0), 0)
        XCTAssertEqual(lcm(2, 2, 0, 0), 0)
        XCTAssertEqual(lcm(2, 5), 10)
        XCTAssertEqual(lcm(2, 5, 20), 20)
        XCTAssertEqual(lcm(1,2,3,4,5,6,7,8,9,0), 0)
        XCTAssertEqual(lcm(-1, 1), 1)
//        XCTAssertEqual(lcm(Int.min + 1, 2), 1)
    }
}
