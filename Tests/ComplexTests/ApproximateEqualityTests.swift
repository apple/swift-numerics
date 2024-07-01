//===--- ApproximateEqualityTests.swift -----------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Numerics
import XCTest

final class ApproximateEqualityTests: XCTestCase {
  
  func testSpecials<T: Real>(absolute tol: T) {
    let zero = Complex<T>.zero
    let inf = Complex<T>.infinity
    XCTAssertTrue(zero.isApproximatelyEqual(to: zero, absoluteTolerance: tol))
    XCTAssertTrue(zero.isApproximatelyEqual(to:-zero, absoluteTolerance: tol))
    XCTAssertTrue((-zero).isApproximatelyEqual(to: zero, absoluteTolerance: tol))
    XCTAssertTrue((-zero).isApproximatelyEqual(to:-zero, absoluteTolerance: tol))
    // Complex has a single point at infinity.
    XCTAssertTrue(inf.isApproximatelyEqual(to: inf, absoluteTolerance: tol))
    XCTAssertTrue(inf.isApproximatelyEqual(to:-inf, absoluteTolerance: tol))
    XCTAssertTrue((-inf).isApproximatelyEqual(to: inf, absoluteTolerance: tol))
    XCTAssertTrue((-inf).isApproximatelyEqual(to:-inf, absoluteTolerance: tol))
  }
  
  func testSpecials<T: Real>(relative tol: T) {
    let zero = Complex<T>.zero
    let inf = Complex<T>.infinity
    XCTAssertTrue(zero.isApproximatelyEqual(to: zero, relativeTolerance: tol))
    XCTAssertTrue(zero.isApproximatelyEqual(to:-zero, relativeTolerance: tol))
    XCTAssertTrue((-zero).isApproximatelyEqual(to: zero, relativeTolerance: tol))
    XCTAssertTrue((-zero).isApproximatelyEqual(to:-zero, relativeTolerance: tol))
    // Complex has a single point at infinity.
    XCTAssertTrue(inf.isApproximatelyEqual(to: inf, relativeTolerance: tol))
    XCTAssertTrue(inf.isApproximatelyEqual(to:-inf, relativeTolerance: tol))
    XCTAssertTrue((-inf).isApproximatelyEqual(to: inf, relativeTolerance: tol))
    XCTAssertTrue((-inf).isApproximatelyEqual(to:-inf, relativeTolerance: tol))
  }
  
  func testSpecials<T: Real>(_ type: T.Type) {
    XCTAssertTrue(Complex<T>.zero.isApproximatelyEqual(to: .zero))
    XCTAssertTrue(Complex<T>.zero.isApproximatelyEqual(to:-.zero))
    testSpecials(absolute: T.zero)
    testSpecials(absolute: T.greatestFiniteMagnitude)
    testSpecials(relative: T.ulpOfOne)
    testSpecials(relative: T(1))
  }
  
  func testFloat() {
    testSpecials(Float.self)
  }
  
  func testDouble() {
    testSpecials(Double.self)
  }
  
  #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
  func testFloat80() {
    testSpecials(Float80.self)
  }
  #endif
}
