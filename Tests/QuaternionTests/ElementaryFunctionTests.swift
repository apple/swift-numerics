//===--- ElementaryFunctionTests.swift ------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2022 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import RealModule
import _TestSupport

@testable import QuaternionModule

final class ElementaryFunctionTests: XCTestCase {

  // MARK: - exp-like functions

  func testExp<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    // exp(0) = 1
    XCTAssertEqual(1, Quaternion<T>.exp(Quaternion(real: .zero, imaginary: .zero)))
    XCTAssertEqual(1, Quaternion<T>.exp(Quaternion(real:-.zero, imaginary: .zero)))
    XCTAssertEqual(1, Quaternion<T>.exp(Quaternion(real:-.zero, imaginary:-.zero)))
    XCTAssertEqual(1, Quaternion<T>.exp(Quaternion(real: .zero, imaginary:-.zero)))
    // exp is the identity at infinity.
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:      .nan, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:     .zero, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real: .infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:-.infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real: .ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:-.ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:      .nan, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:     .zero, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real: .infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:-.infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real: .ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:-.ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:      .nan, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:-.infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real: .infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:      .nan, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:     .zero, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real: .infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:-.infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real: .ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:-.ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:      .nan, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:-.infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real: .infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:      .nan, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:-.infinity, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real: .infinity, imaginary:-.ulpOfOne)).isFinite)
    // Find a value of x such that exp(x) just overflows. Then exp((x, π/4))
    // should not overflow, but will do so if it is not computed carefully.
    // The correct value is:
    //
    //   exp((log(gfm) + log(9/8), π/4) = exp((log(gfm*9/8), π/4))
    //                                  = gfm*9/8 * (1/sqrt(2), 1/(sqrt(2))
    let x = T.log(.greatestFiniteMagnitude) + T.log(9/8)
    let huge = Quaternion<T>.exp(Quaternion(real: x, imaginary: SIMD3(.pi/4, 0, 0)))
    let mag = T.greatestFiniteMagnitude/T.sqrt(2) * (9/8)
    XCTAssert(huge.real.isApproximatelyEqual(to: mag))
    XCTAssert(huge.imaginary.x.isApproximatelyEqual(to: mag))
    XCTAssertEqual(huge.imaginary.y, .zero)
    XCTAssertEqual(huge.imaginary.z, .zero)
    // For randomly-chosen well-scaled finite values, we expect to have the
    // usual identities:
    //
    //   exp(z + w) = exp(z) * exp(w)
    //   exp(z - w) = exp(z) / exp(w)
    var g = SystemRandomNumberGenerator()
    let values: [Quaternion<T>] = (0..<100).map { _ in
      Quaternion(
        real: T.random(in: -1 ... 1, using: &g),
        imaginary: SIMD3(repeating: T.random(in: -.pi ... .pi, using: &g) / 3))
    }
    for z in values {
      for w in values {
        let p = Quaternion.exp(z) * Quaternion.exp(w)
        let q = Quaternion.exp(z) / Quaternion.exp(w)
        XCTAssert(Quaternion.exp(z + w).isApproximatelyEqual(to: p))
        XCTAssert(Quaternion.exp(z - w).isApproximatelyEqual(to: q))
      }
    }
  }

  func testExpMinusOne<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    // expMinusOne(0) = 0
    XCTAssert(Quaternion<T>.expMinusOne(Quaternion(real: .zero, imaginary: .zero)).isZero)
    XCTAssert(Quaternion<T>.expMinusOne(Quaternion(real:-.zero, imaginary: .zero)).isZero)
    XCTAssert(Quaternion<T>.expMinusOne(Quaternion(real:-.zero, imaginary:-.zero)).isZero)
    XCTAssert(Quaternion<T>.expMinusOne(Quaternion(real: .zero, imaginary:-.zero)).isZero)
    // expMinusOne is the identity at infinity
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:      .nan, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:     .zero, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real: .infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:-.infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real: .ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:-.ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:      .nan, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:     .zero, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real: .infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:-.infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real: .ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:-.ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:      .nan, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:-.infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real: .infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:      .nan, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:     .zero, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real: .infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:-.infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real: .ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:-.ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:      .nan, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:-.infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real: .infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:      .nan, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:-.infinity, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real: .infinity, imaginary:-.ulpOfOne)).isFinite)
    // Near-overflow test, same as exp() above.
    let x = T.log(.greatestFiniteMagnitude) + T.log(9/8)
    let huge = Quaternion<T>.expMinusOne(Quaternion(real: x, imaginary: SIMD3(.pi/4, 0, 0)))
    let mag = T.greatestFiniteMagnitude/T.sqrt(2) * (9/8)
    XCTAssert(huge.real.isApproximatelyEqual(to: mag))
    XCTAssert(huge.imaginary.x.isApproximatelyEqual(to: mag))
    XCTAssertEqual(huge.imaginary.y, .zero)
    XCTAssertEqual(huge.imaginary.z, .zero)
    // For small values, expMinusOne should be approximately the identity.
    var g = SystemRandomNumberGenerator()
    let small = T.ulpOfOne
    for _ in 0 ..< 100 {
      let q = Quaternion<T>(
        real: T.random(in: -small ... small, using: &g),
        imaginary:
          T.random(in: -small ... small, using: &g),
          T.random(in: -small ... small, using: &g),
          T.random(in: -small ... small, using: &g)
      )
      XCTAssert(q.isApproximatelyEqual(to: Quaternion.expMinusOne(q), relativeTolerance: 16 * .ulpOfOne))
    }
  }

  func testCosh<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    // cosh(0) = 1
    XCTAssertEqual(1, Quaternion<T>.cosh(Quaternion(real: .zero, imaginary: .zero)))
    XCTAssertEqual(1, Quaternion<T>.cosh(Quaternion(real:-.zero, imaginary: .zero)))
    XCTAssertEqual(1, Quaternion<T>.cosh(Quaternion(real:-.zero, imaginary:-.zero)))
    XCTAssertEqual(1, Quaternion<T>.cosh(Quaternion(real: .zero, imaginary:-.zero)))
    // cosh is the identity at infinity.
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:      .nan, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:     .zero, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real: .infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:-.infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real: .ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:-.ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:      .nan, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:     .zero, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real: .infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:-.infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real: .ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:-.ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:      .nan, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:-.infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real: .infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:      .nan, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:     .zero, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real: .infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:-.infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real: .ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:-.ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:      .nan, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:-.infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real: .infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:      .nan, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:-.infinity, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real: .infinity, imaginary:-.ulpOfOne)).isFinite)
    // Near-overflow test, same as exp() above, but it happens later, because
    // for large x, cosh(x + v) ~ exp(x + v)/2.
    let x = T.log(.greatestFiniteMagnitude) + T.log(18/8)
    let mag = T.greatestFiniteMagnitude/T.sqrt(2) * (9/8)
    var huge = Quaternion<T>.cosh(Quaternion(real: x, imaginary: SIMD3(.pi/4, 0, 0)))
    XCTAssert(huge.real.isApproximatelyEqual(to: mag))
    XCTAssert(huge.imaginary.x.isApproximatelyEqual(to: mag))
    XCTAssertEqual(huge.imaginary.y, .zero)
    XCTAssertEqual(huge.imaginary.z, .zero)
    huge = Quaternion<T>.cosh(Quaternion(real: -x, imaginary: SIMD3(.pi/4, 0, 0)))
    XCTAssert(huge.real.isApproximatelyEqual(to: mag))
    XCTAssert(huge.imaginary.x.isApproximatelyEqual(to: mag))
    XCTAssertEqual(huge.imaginary.y, .zero)
    XCTAssertEqual(huge.imaginary.z, .zero)
  }

  func testSinh<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    // sinh(0) = 0
    XCTAssert(Quaternion<T>.sinh(Quaternion(real: .zero, imaginary: .zero)).isZero)
    XCTAssert(Quaternion<T>.sinh(Quaternion(real:-.zero, imaginary: .zero)).isZero)
    XCTAssert(Quaternion<T>.sinh(Quaternion(real:-.zero, imaginary:-.zero)).isZero)
    XCTAssert(Quaternion<T>.sinh(Quaternion(real: .zero, imaginary:-.zero)).isZero)
    // sinh is the identity at infinity.
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:      .nan, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:     .zero, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real: .infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:-.infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real: .ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:-.ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:      .nan, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:     .zero, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real: .infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:-.infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real: .ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:-.ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:      .nan, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:-.infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real: .infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:      .nan, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:     .zero, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real: .infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:-.infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real: .ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:-.ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:      .nan, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:-.infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real: .infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:      .nan, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:-.infinity, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real: .infinity, imaginary:-.ulpOfOne)).isFinite)
    // Near-overflow test, same as exp() above, but it happens later, because
    // for large x, sinh(x + v) ~ ±exp(x + v)/2.
    let x = T.log(.greatestFiniteMagnitude) + T.log(18/8)
    let mag = T.greatestFiniteMagnitude/T.sqrt(2) * (9/8)
    var huge = Quaternion<T>.sinh(Quaternion(real: x, imaginary: SIMD3(.pi/4, 0, 0)))
    XCTAssert(huge.real.isApproximatelyEqual(to: mag))
    XCTAssert(huge.imaginary.x.isApproximatelyEqual(to: mag))
    XCTAssertEqual(huge.imaginary.y, .zero)
    XCTAssertEqual(huge.imaginary.z, .zero)
    huge = Quaternion<T>.sinh(Quaternion(real: -x, imaginary: SIMD3(.pi/4, 0, 0)))
    XCTAssert(huge.real.isApproximatelyEqual(to: -mag))
    XCTAssert(huge.imaginary.x.isApproximatelyEqual(to: -mag))
    XCTAssertEqual(huge.imaginary.y, .zero)
    XCTAssertEqual(huge.imaginary.z, .zero)
    // For randomly-chosen well-scaled finite values, we expect to have
    // cosh² - sinh² ≈ 1. Note that this test would break down due to
    // catastrophic cancellation as we get further away from the origin.
    var g = SystemRandomNumberGenerator()
    let values: [Quaternion<T>] = (0..<1000).map { _ in
      Quaternion(
        real: T.random(in: -2 ... 2, using: &g),
        imaginary:
          T.random(in: -2 ... 2, using: &g),
          T.random(in: -2 ... 2, using: &g),
          T.random(in: -2 ... 2, using: &g)
      )
    }
    for q in values {
      let c = Quaternion.cosh(q)
      let s = Quaternion.sinh(q)
      XCTAssert((c*c - s*s).isApproximatelyEqual(to: .one))
    }
  }

  func testCosSin<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    var g = SystemRandomNumberGenerator()
    let values: [Quaternion<T>] = (0..<1000).map { _ in
      Quaternion(
        real: T.random(in: -2 ... 2, using: &g),
        imaginary:
          T.random(in: -2 ... 2, using: &g),
          T.random(in: -2 ... 2, using: &g),
          T.random(in: -2 ... 2, using: &g)
      )
    }
    for q in values {
      // For randomly-chosen well-scaled finite values, we expect to have
      // cos² + sin² ≈ 1
      let s = Quaternion.sin(q)
      let c = Quaternion.cos(q)
      XCTAssert((c*c + s*s).isApproximatelyEqual(to: .one))
    }
  }

  // MARK: - log-like functions

  func testLog<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    // log(0) = infinity
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real: .zero, imaginary: .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:-.zero, imaginary: .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:-.zero, imaginary:-.zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real: .zero, imaginary:-.zero)).isFinite)
    // log is the identity at infinity
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:      .nan, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:     .zero, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real: .infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:-.infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real: .ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:-.ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:      .nan, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:     .zero, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real: .infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:-.infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real: .ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:-.ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:      .nan, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:-.infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real: .infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:      .nan, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:     .zero, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real: .infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:-.infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real: .ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:-.ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:      .nan, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:-.infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real: .infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:      .nan, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:-.infinity, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real: .infinity, imaginary:-.ulpOfOne)).isFinite)

    // For randomly-chosen well-scaled finite values, we expect to have
    // log(exp(q)) ≈ q
    var g = SystemRandomNumberGenerator()
    let values: [Quaternion<T>] = (0..<1000).map { _ in
      Quaternion(
        real: T.random(in: -2 ... 2, using: &g),
        imaginary:
          T.random(in: -.pi/2 ... .pi/2, using: &g),
          T.random(in: -.pi/2 ... .pi/2, using: &g),
          T.random(in: -.pi/2 ... .pi/2, using: &g)
      )
    }
    for q in values {
      XCTAssert(q.isApproximatelyEqual(to: .log(.exp(q))))
    }
  }

  func testLogOnePlus<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    // log(onePlus: 0) = 0
    XCTAssert(Quaternion<T>.log(onePlus: Quaternion(real: .zero, imaginary: .zero)).isZero)
    XCTAssert(Quaternion<T>.log(onePlus: Quaternion(real:-.zero, imaginary: .zero)).isZero)
    XCTAssert(Quaternion<T>.log(onePlus: Quaternion(real:-.zero, imaginary:-.zero)).isZero)
    XCTAssert(Quaternion<T>.log(onePlus: Quaternion(real: .zero, imaginary:-.zero)).isZero)
    // log(onePlus:) is the identity at infinity.
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:      .nan, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:     .zero, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real: .infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:-.infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real: .ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:-.ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:      .nan, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:     .zero, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real: .infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:-.infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real: .ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:-.ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:      .nan, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:-.infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real: .infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:      .nan, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:     .zero, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real: .infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:-.infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real: .ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:-.ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:      .nan, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:-.infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real: .infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:      .nan, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real:-.infinity, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(onePlus: Quaternion(real: .infinity, imaginary:-.ulpOfOne)).isFinite)

    // For randomly-chosen well-scaled finite values, we expect to have
    // log(onePlus: expMinusOne(q)) ≈ q
    var g = SystemRandomNumberGenerator()
    let values: [Quaternion<T>] = (0..<1000).map { _ in
      Quaternion(
        real: T.random(in: -2 ... 2, using: &g),
        imaginary:
          T.random(in: -.pi/2 ... .pi/2, using: &g),
          T.random(in: -.pi/2 ... .pi/2, using: &g),
          T.random(in: -.pi/2 ... .pi/2, using: &g)
      )
    }
    for q in values {
      XCTAssert(q.isApproximatelyEqual(to: .log(onePlus: .expMinusOne(q))))
    }
  }

  func testAcos<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    // acos(1) = 0
    XCTAssert(Quaternion<T>.acos(1).isZero)
    // acos(0) = π/2
    XCTAssert(Quaternion<T>.acos(0).real.isApproximatelyEqual(to: .pi/2))
    XCTAssertEqual(Quaternion<T>.acos(0).imaginary, .zero)
    // acos(-1) = π
    XCTAssert(Quaternion<T>.acos(-1).real.isApproximatelyEqual(to: .pi))
    XCTAssertEqual(Quaternion<T>.acos(-1).imaginary, .zero)
    // acos is the identity at infinity.
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:      .nan, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:     .zero, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real: .infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:-.infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real: .ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:-.ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:      .nan, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:     .zero, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real: .infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:-.infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real: .ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:-.ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:      .nan, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:-.infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real: .infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:      .nan, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:     .zero, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real: .infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:-.infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real: .ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:-.ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:      .nan, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:-.infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real: .infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:      .nan, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real:-.infinity, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.acos(Quaternion(real: .infinity, imaginary:-.ulpOfOne)).isFinite)
    // For randomly-chosen well-scaled finite values, we expect to have
    // cos(acos(q)) ≈ q and acos(q) ≈ π - acos(-q)
    var g = SystemRandomNumberGenerator()
    let values: [Quaternion<T>] = (0..<1000).map { _ in
      Quaternion(
        real: T.random(in: -2 ... 2, using: &g),
        imaginary:
          T.random(in: -.pi/2 ... .pi/2, using: &g),
          T.random(in: -.pi/2 ... .pi/2, using: &g),
          T.random(in: -.pi/2 ... .pi/2, using: &g)
      )
    }
    for q in values {
      let p = Quaternion.acos(q)
      XCTAssert(Quaternion.cos(p).isApproximatelyEqual(to: q))
      XCTAssert(p.isApproximatelyEqual(to: Quaternion(.pi) - .acos(-q)))
    }
  }

  func testAsin<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    // asin(1) = π/2
    XCTAssert(Quaternion<T>.asin(1).real.isApproximatelyEqual(to: .pi/2))
    XCTAssertEqual(Quaternion<T>.asin(1).imaginary, .zero)
    // asin(0) = 0
    XCTAssert(Quaternion<T>.asin(0).isZero)
    // asin(-1) = -π/2
    XCTAssert(Quaternion<T>.asin(-1).real.isApproximatelyEqual(to: -.pi/2))
    XCTAssertEqual(Quaternion<T>.asin(-1).imaginary, .zero)
    // asin is the identity at infinity.
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:      .nan, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:     .zero, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real: .infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:-.infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real: .ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:-.ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:      .nan, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:     .zero, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real: .infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:-.infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real: .ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:-.ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:      .nan, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:-.infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real: .infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:      .nan, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:     .zero, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real: .infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:-.infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real: .ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:-.ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:      .nan, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:-.infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real: .infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:      .nan, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real:-.infinity, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.asin(Quaternion(real: .infinity, imaginary:-.ulpOfOne)).isFinite)
    // For randomly-chosen well-scaled finite values, we expect to have
    // sin(asin(q)) ≈ q and asin(q) ≈ -asin(-q)
    var g = SystemRandomNumberGenerator()
    let values: [Quaternion<T>] = (0..<1000).map { _ in
      Quaternion(
        real: T.random(in: -2 ... 2, using: &g),
        imaginary:
          T.random(in: -.pi/2 ... .pi/2, using: &g),
          T.random(in: -.pi/2 ... .pi/2, using: &g),
          T.random(in: -.pi/2 ... .pi/2, using: &g)
      )
    }
    for q in values {
      let p = Quaternion.asin(q)
      XCTAssert(Quaternion.sin(p).isApproximatelyEqual(to: q))
      XCTAssert(p.isApproximatelyEqual(to: -.asin(-q)))
    }
  }

  func testAcosh<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    // acosh(1) = 0
    XCTAssertEqual(Quaternion<T>.acosh(1).imaginary, .zero)
    XCTAssert(Quaternion<T>.acosh(1).isZero)
    // acosh is the identity at infinity.
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:      .nan, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:     .zero, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real: .infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:-.infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real: .ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:-.ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:      .nan, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:     .zero, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real: .infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:-.infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real: .ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:-.ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:      .nan, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:-.infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real: .infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:      .nan, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:     .zero, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real: .infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:-.infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real: .ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:-.ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:      .nan, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:-.infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real: .infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:      .nan, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real:-.infinity, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.acosh(Quaternion(real: .infinity, imaginary:-.ulpOfOne)).isFinite)
    // For randomly-chosen well-scaled finite values, we expect to have
    // cosh(acosh(q)) ≈ q
    var g = SystemRandomNumberGenerator()
    let values: [Quaternion<T>] = (0..<1000).map { _ in
      Quaternion(
        real: T.random(in: -2 ... 2, using: &g),
        imaginary:
          T.random(in: -.pi/2 ... .pi/2, using: &g),
          T.random(in: -.pi/2 ... .pi/2, using: &g),
          T.random(in: -.pi/2 ... .pi/2, using: &g)
      )
    }
    for q in values {
      let r = Quaternion.acosh(q)
      let s = Quaternion.cosh(r)
      if !q.isApproximatelyEqual(to: s) {
        print("cosh(acosh()) was not close to identity at q = \(q).")
        print("acosh(\(q)) = \(r).")
        print("cosh(\(r)) = \(s).")
        XCTFail()
      }
    }
  }

  func testAsinh<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    // asinh(1) = π/2
    XCTAssert(Quaternion<T>.asin(1).real.isApproximatelyEqual(to: .pi/2))
    XCTAssertEqual(Quaternion<T>.asin(1).imaginary, SIMD3<T>(repeating: 0))
    // asinh(0) = 0
    XCTAssert(Quaternion<T>.asinh(0).isZero)
    // asinh(-1) = -π/2
    XCTAssert(Quaternion<T>.asin(-1).real.isApproximatelyEqual(to: -.pi/2))
    XCTAssertEqual(Quaternion<T>.asin(-1).imaginary, SIMD3<T>(repeating: 0))
    // asinh is the identity at infinity.
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:      .nan, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:     .zero, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real: .infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:-.infinity, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real: .ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:-.ulpOfOne, imaginary:      .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:      .nan, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:     .zero, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real: .infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:-.infinity, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real: .ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:-.ulpOfOne, imaginary:-.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:      .nan, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:-.infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real: .infinity, imaginary:     .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:      .nan, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:     .zero, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real: .infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:-.infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real: .ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:-.ulpOfOne, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:      .nan, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:-.infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real: .infinity, imaginary: .ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:      .nan, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real:-.infinity, imaginary:-.ulpOfOne)).isFinite)
    XCTAssertFalse(Quaternion<T>.asinh(Quaternion(real: .infinity, imaginary:-.ulpOfOne)).isFinite)
    // For randomly-chosen well-scaled finite values, we expect to have
    // sinh(asinh(z)) ≈ z
    var g = SystemRandomNumberGenerator()
    let values: [Quaternion<T>] = (0..<1000).map { _ in
      Quaternion(
        real: T.random(in: -2 ... 2, using: &g),
        imaginary:
          T.random(in: -.pi/2 ... .pi/2, using: &g),
          T.random(in: -.pi/2 ... .pi/2, using: &g),
          T.random(in: -.pi/2 ... .pi/2, using: &g)
      )
    }
    for q in values {
      let r = Quaternion.asinh(q)
      let s = Quaternion.sinh(r)
      if !q.isApproximatelyEqual(to: s) {
        print("sinh(asinh()) was not close to identity at q = \(q).")
        print("asinh(\(q)) = \(r).")
        print("sinh(\(r)) = \(s).")
        XCTFail()
      }
    }
  }

  func testAtanh<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    // For randomly-chosen well-scaled finite values, we expect to have
    // tanh(atanh(q)) ≈ q
    var g = SystemRandomNumberGenerator()
    let values: [Quaternion<T>] = (0..<1000).map { _ in
      Quaternion(
        real: T.random(in: -2 ... 2, using: &g),
        imaginary:
          T.random(in: -.pi/2 ... .pi/2, using: &g),
          T.random(in: -.pi/2 ... .pi/2, using: &g),
          T.random(in: -.pi/2 ... .pi/2, using: &g)
      )
    }
    for q in values {
      let r = Quaternion.atanh(q)
      let s = Quaternion.tanh(r)
      if !q.isApproximatelyEqual(to: s) {
        print("tanh(atanh()) was not close to identity at q = \(q).")
        print("atanh(\(q)) = \(r).")
        print("tanh(\(r)) = \(s).")
        XCTFail()
      }
    }
  }

  func testFloat() {
    testExp(Float32.self)
    testExpMinusOne(Float32.self)
    testCosh(Float32.self)
    testSinh(Float32.self)
    testCosSin(Float32.self)

    testLog(Float32.self)
    testLogOnePlus(Float32.self)
    testAcos(Float32.self)
    testAsin(Float32.self)
    testAcosh(Float32.self)
    testAsinh(Float32.self)
    testAtanh(Float32.self)
  }

  func testDouble() {
    testExp(Float64.self)
    testExpMinusOne(Float64.self)
    testCosh(Float64.self)
    testSinh(Float64.self)
    testCosSin(Float64.self)

    testLog(Float64.self)
    testLogOnePlus(Float64.self)
    testAcos(Float64.self)
    testAsin(Float64.self)
    testAcosh(Float64.self)
    testAsinh(Float64.self)
    testAtanh(Float64.self)
  }
}
