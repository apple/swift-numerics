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

import RealModule
import XCTest
import _TestSupport

final class ApproximateEqualityTests: XCTestCase {
  
  func testSpecials<T: Real>(absolute tol: T) {
    let zero = T.zero
    let gfm = T.greatestFiniteMagnitude
    let inf = T.infinity
    let nan = T.nan
    XCTAssertTrue(zero.isApproximatelyEqual(to: zero, absoluteTolerance: tol))
    XCTAssertTrue(zero.isApproximatelyEqual(to:-zero, absoluteTolerance: tol))
    XCTAssertFalse(inf.isApproximatelyEqual(to: gfm, absoluteTolerance: tol))
    XCTAssertFalse(gfm.isApproximatelyEqual(to: inf, absoluteTolerance: tol))
    XCTAssertTrue(inf.isApproximatelyEqual(to: inf, absoluteTolerance: tol))
    XCTAssertTrue(inf.isApproximatelyEqual(to: inf, absoluteTolerance: tol))
    XCTAssertFalse(nan.isApproximatelyEqual(to: nan, absoluteTolerance: tol))
  }
  
  func testSpecials<T: Real>(relative tol: T) {
    let zero = T.zero
    let gfm = T.greatestFiniteMagnitude
    let inf = T.infinity
    let nan = T.nan
    XCTAssertTrue(zero.isApproximatelyEqual(to: zero, relativeTolerance: tol))
    XCTAssertTrue(zero.isApproximatelyEqual(to:-zero, relativeTolerance: tol))
    XCTAssertFalse(inf.isApproximatelyEqual(to: gfm, relativeTolerance: tol))
    XCTAssertFalse(gfm.isApproximatelyEqual(to: inf, relativeTolerance: tol))
    XCTAssertTrue(inf.isApproximatelyEqual(to: inf, relativeTolerance: tol))
    XCTAssertTrue(inf.isApproximatelyEqual(to: inf, relativeTolerance: tol))
    XCTAssertFalse(nan.isApproximatelyEqual(to: nan, relativeTolerance: tol))
  }
  
  func testSpecials<T: Real>(_ type: T.Type) {
    XCTAssertTrue(T.zero.isApproximatelyEqual(to: .zero))
    XCTAssertTrue(T.zero.isApproximatelyEqual(to:-.zero))
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
    XCTAssertTrue(T(1).isApproximatelyEqual(to: 1 + e))
    XCTAssertTrue(T(1).isApproximatelyEqual(to: 1 - e/2))
    XCTAssertFalse(T(1).isApproximatelyEqual(to: 1 + 2*e))
    XCTAssertFalse(T(1).isApproximatelyEqual(to: 1 - 3*e/2))
  }
  
  func testRandom<T>(_ type: T.Type) where T: FixedWidthFloatingPoint & Real {
    var g = SystemRandomNumberGenerator()
    // Generate a bunch of random values in a small interval and a tolerance
    // and use them to check that various properties that we would like to
    // hold actually do.
    var x = [1] + (0 ..< 64).map {
      _ in T.random(in: 1 ..< 2, using: &g)
    } + [2]
    x.sort()
    // We have 66 values in 1 ... 2, so if we use a tolerance of around 1/64,
    // at least some of the pairs will compare equal with tolerance.
    let tol = T.random(in: 1/64 ... 1/32, using: &g)
    // We're going to walk the values in order, validating that some common-
    // sense properties hold.
    for i in x.indices {
      // reflexivity
      XCTAssertTrue(x[i].isApproximatelyEqual(to: x[i]))
      XCTAssertTrue(x[i].isApproximatelyEqual(to: x[i], relativeTolerance: tol))
      XCTAssertTrue(x[i].isApproximatelyEqual(to: x[i], absoluteTolerance: tol))
      for j in i ..< x.endIndex {
        // commutativity
        XCTAssertTrue(
          x[i].isApproximatelyEqual(to: x[j], relativeTolerance: tol) ==
          x[j].isApproximatelyEqual(to: x[i], relativeTolerance: tol)
        )
        XCTAssertTrue(
          x[i].isApproximatelyEqual(to: x[j], absoluteTolerance: tol) ==
          x[j].isApproximatelyEqual(to: x[i], absoluteTolerance: tol)
        )
        // scale invariance for relative comparisons
        let scale = T(
          sign:.plus,
          exponent: T.Exponent.random(in: T.leastNormalMagnitude.exponent ..< T.greatestFiniteMagnitude.exponent),
          significand: 1
        )
        XCTAssertTrue(
          x[i].isApproximatelyEqual(to: x[j], relativeTolerance: tol) ==
          (scale*x[i]).isApproximatelyEqual(to: scale*x[j], relativeTolerance: tol)
        )
      }
      // if a ≤ b ≤ c, and a ≈ c, then a ≈ b and b ≈ c (relative tolerance)
      var left = x.firstIndex { x[i].isApproximatelyEqual(to: $0, relativeTolerance: tol) }
      var right = x.lastIndex { x[i].isApproximatelyEqual(to: $0, relativeTolerance: tol) }
      if let l = left, let r = right {
        for j in l ..< r {
          XCTAssertTrue(x[i].isApproximatelyEqual(to: x[j], relativeTolerance: tol))
        }
      }
      // if a ≤ b ≤ c, and a ≈ c, then a ≈ b and b ≈ c (absolute tolerance)
      left = x.firstIndex { x[i].isApproximatelyEqual(to: $0, absoluteTolerance: tol) }
      right = x.lastIndex { x[i].isApproximatelyEqual(to: $0, absoluteTolerance: tol) }
      if let l = left, let r = right {
        for j in l ..< r {
          XCTAssertTrue(x[i].isApproximatelyEqual(to: x[j], absoluteTolerance: tol))
        }
      }
    }
  }
  
  func testFloat() {
    testSpecials(Float.self)
    testDefaults(Float.self)
    testRandom(Float.self)
  }
  
  func testDouble() {
    testSpecials(Double.self)
    testDefaults(Double.self)
    testRandom(Double.self)
  }
  
  #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
  func testFloat80() {
    testSpecials(Float80.self)
    testDefaults(Float80.self)
    testRandom(Float80.self)
  }
  #endif
}
