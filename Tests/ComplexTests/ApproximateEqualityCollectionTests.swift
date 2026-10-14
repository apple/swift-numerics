//===--- ApproximateEqualityCollectionTests.swift -------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020-2026 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import Numerics
import XCTest

final class ComplexApproximateEqualityCollectionTests: XCTestCase {

  func testSpecials<T: Real>(absolute tol: T) {
    let zero = Complex<T>.zero
    let inf = Complex<T>.infinity

    // Single element collections - mirrors scalar tests
    XCTAssertTrue([zero].isElementwiseApproximatelyEqual(to: [zero], absoluteTolerance: tol))
    XCTAssertTrue([zero].isElementwiseApproximatelyEqual(to: [-zero], absoluteTolerance: tol))
    XCTAssertTrue([-zero].isElementwiseApproximatelyEqual(to: [zero], absoluteTolerance: tol))
    XCTAssertTrue([-zero].isElementwiseApproximatelyEqual(to: [-zero], absoluteTolerance: tol))

    // Complex has a single point at infinity
    XCTAssertTrue([inf].isElementwiseApproximatelyEqual(to: [inf], absoluteTolerance: tol))
    XCTAssertTrue([inf].isElementwiseApproximatelyEqual(to: [-inf], absoluteTolerance: tol))
    XCTAssertTrue([-inf].isElementwiseApproximatelyEqual(to: [inf], absoluteTolerance: tol))
    XCTAssertTrue([-inf].isElementwiseApproximatelyEqual(to: [-inf], absoluteTolerance: tol))

    // Multiple element collections
    XCTAssertTrue([zero, zero].isElementwiseApproximatelyEqual(to: [zero, -zero], absoluteTolerance: tol))
    XCTAssertTrue([inf, inf].isElementwiseApproximatelyEqual(to: [inf, -inf], absoluteTolerance: tol))
    XCTAssertTrue([zero, inf].isElementwiseApproximatelyEqual(to: [-zero, -inf], absoluteTolerance: tol))
  }

  func testSpecials<T: Real>(relative tol: T) {
    let zero = Complex<T>.zero
    let inf = Complex<T>.infinity

    // Single element collections - mirrors scalar tests
    XCTAssertTrue([zero].isElementwiseApproximatelyEqual(to: [zero], relativeTolerance: tol))
    XCTAssertTrue([zero].isElementwiseApproximatelyEqual(to: [-zero], relativeTolerance: tol))
    XCTAssertTrue([-zero].isElementwiseApproximatelyEqual(to: [zero], relativeTolerance: tol))
    XCTAssertTrue([-zero].isElementwiseApproximatelyEqual(to: [-zero], relativeTolerance: tol))

    // Complex has a single point at infinity
    XCTAssertTrue([inf].isElementwiseApproximatelyEqual(to: [inf], relativeTolerance: tol))
    XCTAssertTrue([inf].isElementwiseApproximatelyEqual(to: [-inf], relativeTolerance: tol))
    XCTAssertTrue([-inf].isElementwiseApproximatelyEqual(to: [inf], relativeTolerance: tol))
    XCTAssertTrue([-inf].isElementwiseApproximatelyEqual(to: [-inf], relativeTolerance: tol))

    // Multiple element collections
    XCTAssertTrue([zero, zero].isElementwiseApproximatelyEqual(to: [zero, -zero], relativeTolerance: tol))
    XCTAssertTrue([inf, inf].isElementwiseApproximatelyEqual(to: [inf, -inf], relativeTolerance: tol))
    XCTAssertTrue([zero, inf].isElementwiseApproximatelyEqual(to: [-zero, -inf], relativeTolerance: tol))
  }

  func testSpecials<T: Real>(_ type: T.Type) {
    XCTAssertTrue([Complex<T>.zero].isElementwiseApproximatelyEqual(to: [Complex<T>.zero]))
    XCTAssertTrue([Complex<T>.zero].isElementwiseApproximatelyEqual(to: [-Complex<T>.zero]))
    testSpecials(absolute: T.zero)
    testSpecials(absolute: T.greatestFiniteMagnitude)
    testSpecials(relative: T.ulpOfOne)
    testSpecials(relative: T(1))
  }

  func testDifferentCounts<T: Real>(_ type: T.Type) {
    let zero = Complex<T>.zero
    let one = Complex<T>(1, 0)
    let i = Complex<T>(0, 1)

    // Empty vs non-empty
    XCTAssertFalse([Complex<T>]().isElementwiseApproximatelyEqual(to: [one]))
    XCTAssertFalse([one].isElementwiseApproximatelyEqual(to: []))

    // Different non-zero lengths
    XCTAssertFalse([one].isElementwiseApproximatelyEqual(to: [one, i]))
    XCTAssertFalse([one, i].isElementwiseApproximatelyEqual(to: [one]))
    XCTAssertFalse([one, i, zero].isElementwiseApproximatelyEqual(to: [one, i]))

    // With very large tolerances - still should fail due to count mismatch
    XCTAssertFalse([one].isElementwiseApproximatelyEqual(
      to: [one, i],
      absoluteTolerance: T.greatestFiniteMagnitude
    ))
    XCTAssertFalse([one, i].isElementwiseApproximatelyEqual(
      to: [one],
      relativeTolerance: 1
    ))

    // Empty arrays should be equal
    XCTAssertTrue([Complex<T>]().isElementwiseApproximatelyEqual(to: []))
    XCTAssertTrue([Complex<T>]().isElementwiseApproximatelyEqual(to: [], absoluteTolerance: 0))
    XCTAssertTrue([Complex<T>]().isElementwiseApproximatelyEqual(to: [], relativeTolerance: 0))
  }

  func testFloat() {
    testSpecials(Float.self)
    testDifferentCounts(Float.self)
  }

  func testDouble() {
    testSpecials(Double.self)
    testDifferentCounts(Double.self)
  }

  #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
  func testFloat80() {
    testSpecials(Float80.self)
    testDifferentCounts(Float80.self)
  }
  #endif
}
