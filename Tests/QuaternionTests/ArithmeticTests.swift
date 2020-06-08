//===--- ArithmeticTests.swift --------------------------------*- swift -*-===//
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
import RealModule

@testable import QuaternionModule

final class ArithmeticTests: XCTestCase {

  func testMultiplication<T: Real>(_ type: T.Type) {
    for value: T in [-3, -2, -1, +1, +2, +3] {
      let q = Quaternion<T>(real: value, imaginary: value, value, value)
      XCTAssertEqual(q * .one, q)
      XCTAssertEqual(q * 1, q)
      XCTAssertEqual(1 * q, q)
    }
  }

  func testMultiplication() {
    testMultiplication(Float32.self)
    testMultiplication(Float64.self)
    #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    testMultiplication(Float80.self)
    #endif
  }

  func testDivision<T: Real>(_ type: T.Type) {
    for value: T in [-3, -2, -1, +1, +2, +3] {
      let q = Quaternion<T>(real: value, imaginary: value, value, value)
      XCTAssertEqual(q/q, .one)
      XCTAssertEqual(0/q, .zero)

      for q2: Quaternion<T> in [-3, -2, -1, 0, +1, +2, +3] {
        XCTAssertEqual(q2/q, q2 * q.reciprocal!)
      }

      for q2: T in [-3, -2, -1, +1, +2, +3] {
        XCTAssertEqual(q.divided(by: q2), q.multiplied(by: 1/q2))
      }
    }
  }

  func testDivision() {
    testDivision(Float32.self)
    testDivision(Float64.self)
    #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    testDivision(Float80.self)
    #endif
  }

  func testDivisionByZero<T: Real>(_ type: T.Type) {
    XCTAssertFalse((Quaternion<T>(real: 0, imaginary: 0, 0, 0) / Quaternion<T>(real: 0, imaginary: 0, 0, 0)).isFinite)
    XCTAssertFalse((Quaternion<T>(real: 1, imaginary: 1, 1, 1) / Quaternion<T>(real: 0, imaginary: 0, 0, 0)).isFinite)
    XCTAssertFalse((Quaternion<T>.infinity / Quaternion<T>(real: 0, imaginary: 0, 0, 0)).isFinite)
    XCTAssertFalse((Quaternion<T>.i / Quaternion<T>(real: 0, imaginary: 0, 0, 0)).isFinite)
    XCTAssertFalse((Quaternion<T>.j / Quaternion<T>(real: 0, imaginary: 0, 0, 0)).isFinite)
    XCTAssertFalse((Quaternion<T>.k / Quaternion<T>(real: 0, imaginary: 0, 0, 0)).isFinite)
  }

  func testDivisionByZero() {
    testDivisionByZero(Float32.self)
    testDivisionByZero(Float64.self)
    #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    testDivisionByZero(Float80.self)
    #endif
  }
}
