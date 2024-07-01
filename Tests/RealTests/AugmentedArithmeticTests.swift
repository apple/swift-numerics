//===--- AugmentedArithmeticTests.swift -----------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import RealModule
import XCTest
import _TestSupport

final class AugmentedArithmeticTests: XCTestCase {

  func testTwoSumSpecials<T: Real & FixedWidthFloatingPoint>(_: T.Type) {
    // Must be exact and not overflow on outer bounds
    var x =  T.greatestFiniteMagnitude
    var y = -T.greatestFiniteMagnitude
    XCTAssertEqual(Augmented.sum(x, y).head, .zero)
    XCTAssertEqual(Augmented.sum(x, y).tail, .zero)
    XCTAssert(Augmented.sum(x, y).head.isFinite)
    XCTAssert(Augmented.sum(x, y).tail.isFinite)
    // Must be exact on lower subnormal bounds
    x =  T.leastNonzeroMagnitude
    y = -T.leastNonzeroMagnitude
    XCTAssertEqual(Augmented.sum(x, y).head, .zero)
    XCTAssertEqual(Augmented.sum(x, y).tail, .zero)
    // Must preserve floating point signs for:
    // (1)    (+0) + (-0) == +0
    // (2)    (-0) + (+0) == +0
    // (3)    (-0) + (-0) == -0
    x = T(sign: .plus, exponent: 1, significand: 0)
    y = T(sign: .minus, exponent: 1, significand: 0)
    XCTAssertEqual(Augmented.sum(x, y).head.sign, .plus)  // (1)
    XCTAssertEqual(Augmented.sum(x, y).tail.sign, .plus)
    x = T(sign: .minus, exponent: 1, significand: 0)
    y = T(sign: .plus, exponent: 1, significand: 0)
    XCTAssertEqual(Augmented.sum(x, y).head.sign, .plus)  // (2)
    XCTAssertEqual(Augmented.sum(x, y).tail.sign, .plus)
    x = T(sign: .minus, exponent: 1, significand: 0)
    y = T(sign: .minus, exponent: 1, significand: 0)
    XCTAssertEqual(Augmented.sum(x, y).head.sign, .minus) // (3)
    XCTAssertEqual(Augmented.sum(x, y).tail.sign, .plus)
    // Infinity and NaN are propagated correctly
    XCTAssertEqual(Augmented.sum(          0,  T.infinity).head,  T.infinity)
    XCTAssertEqual(Augmented.sum( T.infinity,  0         ).head,  T.infinity)
    XCTAssertEqual(Augmented.sum( T.infinity,  T.infinity).head,  T.infinity)
    XCTAssertEqual(Augmented.sum(          0, -T.infinity).head, -T.infinity)
    XCTAssertEqual(Augmented.sum(-T.infinity,  0         ).head, -T.infinity)
    XCTAssertEqual(Augmented.sum(-T.infinity, -T.infinity).head, -T.infinity)
    XCTAssert(Augmented.sum( T.infinity, -T.infinity).head.isNaN)
    XCTAssert(Augmented.sum(-T.infinity,  T.infinity).head.isNaN)
    XCTAssert(Augmented.sum( T.infinity,       T.nan).head.isNaN)
    XCTAssert(Augmented.sum(      T.nan,  T.infinity).head.isNaN)
    XCTAssert(Augmented.sum(-T.infinity,       T.nan).head.isNaN)
    XCTAssert(Augmented.sum(      T.nan, -T.infinity).head.isNaN)
    XCTAssert(Augmented.sum(    0, T.nan).head.isNaN)
    XCTAssert(Augmented.sum(T.nan,     0).head.isNaN)
    XCTAssert(Augmented.sum(T.nan, T.nan).head.isNaN)
  }

  func testTwoSumRandomValues<T: Real & FixedWidthFloatingPoint>(_: T.Type) {
    // For randomly-chosen well-scaled finite values, we expect:
    // (1)    `head` to be exactly the IEEE 754 sum of `a + b`
    // (2)    `tail` to be less than or equal `head.ulp/2`
    // (3)    the result of `twoSum` for unordered input to be exactly equal to
    //        the result of `fastTwoSum` for ordered input.
    var g = SystemRandomNumberGenerator()
    let values: [T] = (0 ..< 100).map { _ in
      T.random(
        in: T.ulpOfOne ..< 1,
        using: &g)
    }
    for a in values {
      for b in values {
        let twoSum = Augmented.sum(a, b)
        XCTAssertEqual(twoSum.head, a + b)                    // (1)
        XCTAssert(twoSum.tail.magnitude <= twoSum.head.ulp/2) // (2)
        let x: T = a.magnitude < b.magnitude ? b : a
        let y: T = a.magnitude < b.magnitude ? a : b
        let fastTwoSum = Augmented.sum(large: x, small: y)
        XCTAssertEqual(twoSum.head, fastTwoSum.head)          // (3)
        XCTAssertEqual(twoSum.tail, fastTwoSum.tail)          // (3)
      }
    }
  }

  func testTwoSumCancellation<T: Real & FixedWidthFloatingPoint>(_: T.Type) {
    // Must be exact for exactly representable values
    XCTAssertEqual(Augmented.sum( 0.984375, 1.375).head, 2.359375)
    XCTAssertEqual(Augmented.sum( 0.984375, 1.375).tail,      0.0)
    XCTAssertEqual(Augmented.sum(-0.984375, 1.375).head, 0.390625)
    XCTAssertEqual(Augmented.sum(-0.984375, 1.375).tail,      0.0)
    XCTAssertEqual(Augmented.sum( 0.984375,-1.375).head,-0.390625)
    XCTAssertEqual(Augmented.sum( 0.984375,-1.375).tail,      0.0)
    XCTAssertEqual(Augmented.sum(-0.984375,-1.375).head,-2.359375)
    XCTAssertEqual(Augmented.sum(-0.984375,-1.375).tail,      0.0)
    XCTAssertEqual(Augmented.sum( 1.375, 0.984375).head, 2.359375)
    XCTAssertEqual(Augmented.sum( 1.375, 0.984375).tail,      0.0)
    XCTAssertEqual(Augmented.sum( 1.375,-0.984375).head, 0.390625)
    XCTAssertEqual(Augmented.sum( 1.375,-0.984375).tail,      0.0)
    XCTAssertEqual(Augmented.sum(-1.375, 0.984375).head,-0.390625)
    XCTAssertEqual(Augmented.sum(-1.375, 0.984375).tail,      0.0)
    XCTAssertEqual(Augmented.sum(-1.375,-0.984375).head,-2.359375)
    XCTAssertEqual(Augmented.sum(-1.375,-0.984375).tail,      0.0)
    // Must handle cancellation when `b` is not representable in `a` and
    // we expect `b` to be lost entirely in the calculation of `a + b`.
    var a: T = 1.0
    var b: T = .ulpOfOne * .ulpOfOne
    var twoSum = Augmented.sum(a,  b)
    XCTAssertEqual(twoSum.head, a) // a + b = a
    XCTAssertEqual(twoSum.tail, b) // Error: b
    twoSum = Augmented.sum( a, -b)
    XCTAssertEqual(twoSum.head, a)
    XCTAssertEqual(twoSum.tail,-b)
    twoSum = Augmented.sum(-a,  b)
    XCTAssertEqual(twoSum.head,-a)
    XCTAssertEqual(twoSum.tail, b)
    twoSum = Augmented.sum(-a, -b)
    XCTAssertEqual(twoSum.head,-a)
    XCTAssertEqual(twoSum.tail,-b)
    // Must handle cancellation when `b` is only partially representable in `a`.
    // We expect the fractional digits of `b` to be cancelled in the following
    // example but the fractional digits to be preserved in `tail`.
    let exponent = T.Exponent(T.significandBitCount + 1)
    a = T(sign: .plus, exponent: exponent, significand: 1.0)
    b = 256 + 0.5
    twoSum = Augmented.sum( a,  b)
    XCTAssertEqual(twoSum.head,  a + 256)
    XCTAssertEqual(twoSum.tail,  0.5)
    twoSum = Augmented.sum( a, -b)
    XCTAssertEqual(twoSum.head,  a - 256)
    XCTAssertEqual(twoSum.tail, -0.5)
    twoSum = Augmented.sum(-a,  b)
    XCTAssertEqual(twoSum.head, -a + 256)
    XCTAssertEqual(twoSum.tail,  0.5)
    twoSum = Augmented.sum(-a, -b)
    XCTAssertEqual(twoSum.head, -a - 256)
    XCTAssertEqual(twoSum.tail, -0.5)
  }

  func testTwoSum() {
    testTwoSumSpecials(Float32.self)
    testTwoSumRandomValues(Float32.self)
    testTwoSumCancellation(Float32.self)
    testTwoSumSpecials(Float64.self)
    testTwoSumRandomValues(Float64.self)
    testTwoSumCancellation(Float64.self)
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    testTwoSumSpecials(Float80.self)
    testTwoSumRandomValues(Float80.self)
    testTwoSumCancellation(Float80.self)
#endif
  }
}

