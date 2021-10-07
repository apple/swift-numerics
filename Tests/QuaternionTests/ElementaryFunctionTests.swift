//===--- ElementaryFunctionTests.swift ------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2021 Apple Inc. and the Swift Numerics project authors
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

  func testExp<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    // exp(0) = 1
    XCTAssertEqual(1, Quaternion<T>.exp(Quaternion(real: 0, imaginary: 0, 0, 0)))
    XCTAssertEqual(1, Quaternion<T>.exp(Quaternion(real:-0, imaginary: 0, 0, 0)))
    XCTAssertEqual(1, Quaternion<T>.exp(Quaternion(real:-0, imaginary:-0,-0,-0)))
    XCTAssertEqual(1, Quaternion<T>.exp(Quaternion(real: 0, imaginary:-0,-0,-0)))
    // In general, exp(Quaternion(r, 0, 0, 0)) should be exp(r), but that breaks
    // down when r is infinity or NaN, because we want all non-finite
    // quaternions to be semantically a single point at infinity. This is fine
    // for most inputs, but exp(Quaternion(-.infinity, 0, 0, 0)) would produce
    // 0 if we evaluated it in the usual way.
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:  .infinity, imaginary: .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:  .infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:          0, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real: -.infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real: -.infinity, imaginary: .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real: -.infinity, imaginary: -.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:          0, imaginary: -.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:  .infinity, imaginary: -.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:       .nan, imaginary: .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:  .infinity, imaginary: .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:       .nan, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real: -.infinity, imaginary: .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.exp(Quaternion(real:       .nan, imaginary: -.infinity)).isFinite)
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

  func testFloat() {
    testExp(Float32.self)
  }

  func testDouble() {
    testExp(Float64.self)
  }
}
