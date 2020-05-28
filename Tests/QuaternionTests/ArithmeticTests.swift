//===--- ArithmeticTests.swift --------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import RealModule

@testable import QuaternionModule

final class ArithmeticTests: XCTestCase {

  func testDivisionByZero() {
    XCTAssertFalse((Quaternion(0, (0, 0, 0)) / Quaternion(0, (0, 0, 0))).isFinite)
    XCTAssertFalse((Quaternion(1, (1, 1, 1)) / Quaternion(0, (0, 0, 0))).isFinite)
    XCTAssertFalse((Quaternion.infinity / Quaternion(0, (0, 0, 0))).isFinite)
    XCTAssertFalse((Quaternion.i / Quaternion(0, (0, 0, 0))).isFinite)
  }
}
