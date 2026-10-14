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

import RealModule
import XCTest
import _TestSupport

final class ApproximateEqualityCollectionTests: XCTestCase {

  func testSpecials<T: Real>(absolute tol: T) {
    let zero = T.zero
    let gfm = T.greatestFiniteMagnitude
    let inf = T.infinity
    let nan = T.nan

    // Test collections with special values
    XCTAssertTrue([zero].isElementwiseApproximatelyEqual(to: [zero], absoluteTolerance: tol))
    XCTAssertTrue([zero].isElementwiseApproximatelyEqual(to: [-zero], absoluteTolerance: tol))
    XCTAssertFalse([inf].isElementwiseApproximatelyEqual(to: [gfm], absoluteTolerance: tol))
    XCTAssertFalse([gfm].isElementwiseApproximatelyEqual(to: [inf], absoluteTolerance: tol))
    XCTAssertTrue([inf].isElementwiseApproximatelyEqual(to: [inf], absoluteTolerance: tol))
    XCTAssertTrue([inf].isElementwiseApproximatelyEqual(to: [inf], absoluteTolerance: tol))
    XCTAssertFalse([nan].isElementwiseApproximatelyEqual(to: [nan], absoluteTolerance: tol))

    // Test multiple elements
    XCTAssertTrue([zero, zero].isElementwiseApproximatelyEqual(to: [zero, -zero], absoluteTolerance: tol))
    XCTAssertTrue([inf, inf].isElementwiseApproximatelyEqual(to: [inf, inf], absoluteTolerance: tol))
    XCTAssertFalse([nan, zero].isElementwiseApproximatelyEqual(to: [nan, zero], absoluteTolerance: tol))
    XCTAssertFalse([zero, nan].isElementwiseApproximatelyEqual(to: [zero, nan], absoluteTolerance: tol))
  }

  func testSpecials<T: Real>(relative tol: T) {
    let zero = T.zero
    let gfm = T.greatestFiniteMagnitude
    let inf = T.infinity
    let nan = T.nan

    // Test collections with special values
    XCTAssertTrue([zero].isElementwiseApproximatelyEqual(to: [zero], relativeTolerance: tol))
    XCTAssertTrue([zero].isElementwiseApproximatelyEqual(to: [-zero], relativeTolerance: tol))
    XCTAssertFalse([inf].isElementwiseApproximatelyEqual(to: [gfm], relativeTolerance: tol))
    XCTAssertFalse([gfm].isElementwiseApproximatelyEqual(to: [inf], relativeTolerance: tol))
    XCTAssertTrue([inf].isElementwiseApproximatelyEqual(to: [inf], relativeTolerance: tol))
    XCTAssertTrue([inf].isElementwiseApproximatelyEqual(to: [inf], relativeTolerance: tol))
    XCTAssertFalse([nan].isElementwiseApproximatelyEqual(to: [nan], relativeTolerance: tol))

    // Test multiple elements
    XCTAssertTrue([zero, zero].isElementwiseApproximatelyEqual(to: [zero, -zero], relativeTolerance: tol))
    XCTAssertTrue([inf, inf].isElementwiseApproximatelyEqual(to: [inf, inf], relativeTolerance: tol))
    XCTAssertFalse([nan, zero].isElementwiseApproximatelyEqual(to: [nan, zero], relativeTolerance: tol))
    XCTAssertFalse([zero, nan].isElementwiseApproximatelyEqual(to: [zero, nan], relativeTolerance: tol))
  }

  func testSpecials<T: Real>(_ type: T.Type) {
    XCTAssertTrue([T.zero].isElementwiseApproximatelyEqual(to: [T.zero]))
    XCTAssertTrue([T.zero].isElementwiseApproximatelyEqual(to: [-T.zero]))
    testSpecials(absolute: T.zero)
    testSpecials(absolute: T.leastNormalMagnitude)
    testSpecials(absolute: T.greatestFiniteMagnitude)
    testSpecials(relative: T.zero)
    testSpecials(relative: T.ulpOfOne)
    testSpecials(relative: T(1).nextDown)
    testSpecials(relative: T(1))
  }

  func testDefaults<T: Real>(_ type: T.Type) {
    let e = T.ulpOfOne.squareRoot()

    // Single element collections - mirrors scalar tests
    XCTAssertTrue([T(1)].isElementwiseApproximatelyEqual(to: [1 + e]))
    XCTAssertTrue([T(1)].isElementwiseApproximatelyEqual(to: [1 - e/2]))
    XCTAssertFalse([T(1)].isElementwiseApproximatelyEqual(to: [1 + 2*e]))
    XCTAssertFalse([T(1)].isElementwiseApproximatelyEqual(to: [1 - 3*e/2]))

    // Multiple element collections - each element follows same pattern
    XCTAssertTrue([T(1), T(1)].isElementwiseApproximatelyEqual(to: [1 + e, 1 + e]))
    XCTAssertTrue([T(1), T(1)].isElementwiseApproximatelyEqual(to: [1 - e/2, 1 - e/2]))
    XCTAssertFalse([T(1), T(1)].isElementwiseApproximatelyEqual(to: [1 + 2*e, 1]))
    XCTAssertFalse([T(1), T(1)].isElementwiseApproximatelyEqual(to: [1, 1 - 3*e/2]))
  }

  func testDifferentCounts<T: Real>(_ type: T.Type) {
    // Empty vs non-empty
    XCTAssertFalse([T]().isElementwiseApproximatelyEqual(to: [1]))
    XCTAssertFalse([T(1)].isElementwiseApproximatelyEqual(to: []))

    // Different non-zero lengths
    XCTAssertFalse([T(1)].isElementwiseApproximatelyEqual(to: [1, 2]))
    XCTAssertFalse([T(1), T(2)].isElementwiseApproximatelyEqual(to: [1]))
    XCTAssertFalse([T(1), T(2), T(3)].isElementwiseApproximatelyEqual(to: [1, 2]))

    // With very large tolerances - still should fail due to count mismatch
    XCTAssertFalse([T(1)].isElementwiseApproximatelyEqual(
      to: [1, 2],
      absoluteTolerance: T.greatestFiniteMagnitude
    ))
    XCTAssertFalse([T(1), T(2)].isElementwiseApproximatelyEqual(
      to: [1],
      relativeTolerance: 1
    ))

    // Empty arrays should be equal
    XCTAssertTrue([T]().isElementwiseApproximatelyEqual(to: []))
    XCTAssertTrue([T]().isElementwiseApproximatelyEqual(to: [], absoluteTolerance: 0))
    XCTAssertTrue([T]().isElementwiseApproximatelyEqual(to: [], relativeTolerance: 0))
  }

  func testFloat() {
    testSpecials(Float.self)
    testDefaults(Float.self)
    testDifferentCounts(Float.self)
  }

  func testDouble() {
    testSpecials(Double.self)
    testDefaults(Double.self)
    testDifferentCounts(Double.self)
  }

  #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
  func testFloat80() {
    testSpecials(Float80.self)
    testDefaults(Float80.self)
    testDifferentCounts(Float80.self)
  }
  #endif
}
