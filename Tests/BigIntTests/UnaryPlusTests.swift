//===--- UnaryPlusTests.swift ---------------------------------*- swift -*-===//
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

class UnaryPlusTests: XCTestCase {

  func test_int() {
    for int in generateInts(approximateCount: 100) {
      let big = BigInt(int)
      let result = +big
      XCTAssertEqual(result, big, "\(int)")
    }
  }

  func test_big() {
    for p in generateBigInts(approximateCount: 100) {
      let big = p.create()
      let result = +big
      XCTAssertEqual(result, big, "\(big)")
    }
  }
}
