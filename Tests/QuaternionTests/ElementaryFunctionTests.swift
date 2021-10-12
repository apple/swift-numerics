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
    // In general, exp(Quaternion(r,0,0,0)) should be exp(r), but that breaks
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

  func testExpMinusOne<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    // expMinusOne(0) = 0
    XCTAssertEqual(0, Quaternion<T>.expMinusOne(Quaternion(real: 0, imaginary: 0, 0, 0)))
    XCTAssertEqual(0, Quaternion<T>.expMinusOne(Quaternion(real:-0, imaginary: 0, 0, 0)))
    XCTAssertEqual(0, Quaternion<T>.expMinusOne(Quaternion(real:-0, imaginary:-0,-0,-0)))
    XCTAssertEqual(0, Quaternion<T>.expMinusOne(Quaternion(real: 0, imaginary:-0,-0,-0)))
    // In general, expMinusOne(Quaternion(r,0,0,0)) should be expMinusOne(r),
    // but that breaks down when r is infinity or NaN, because we want all non-
    // finite Quaternion values to be semantically a single point at infinity.
    // This is fine for most inputs, but expMinusOne(Quaternion(-.infinity,0,0,0))
    // would produce 0 if we evaluated it in the usual way.
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:  .infinity, imaginary: .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:  .infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:          0, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real: -.infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real: -.infinity, imaginary: .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real: -.infinity, imaginary: -.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:          0, imaginary: -.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:  .infinity, imaginary: -.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:       .nan, imaginary: .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:  .infinity, imaginary: .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:       .nan, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real: -.infinity, imaginary: .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.expMinusOne(Quaternion(real:       .nan, imaginary: -.infinity)).isFinite)
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
        imaginary: SIMD3(repeating: T.random(in: -small ... small, using: &g))
      )
      XCTAssert(q.isApproximatelyEqual(to: Quaternion.expMinusOne(q), relativeTolerance: 16 * .ulpOfOne))
    }
  }

  func testCosh<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    // cosh(0) = 1
    XCTAssertEqual(1, Quaternion<T>.cosh(Quaternion(real: 0, imaginary: 0, 0, 0)))
    XCTAssertEqual(1, Quaternion<T>.cosh(Quaternion(real:-0, imaginary: 0, 0, 0)))
    XCTAssertEqual(1, Quaternion<T>.cosh(Quaternion(real:-0, imaginary:-0,-0,-0)))
    XCTAssertEqual(1, Quaternion<T>.cosh(Quaternion(real: 0, imaginary:-0,-0,-0)))
    // cosh is the identity at infinity.
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:  .infinity, imaginary: .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:  .infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:          0, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real: -.infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real: -.infinity, imaginary: .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real: -.infinity, imaginary: -.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:          0, imaginary: -.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:  .infinity, imaginary: -.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:       .nan, imaginary: .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:  .infinity, imaginary: .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:       .nan, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real: -.infinity, imaginary: .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.cosh(Quaternion(real:       .nan, imaginary: -.infinity)).isFinite)
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
    XCTAssertEqual(0, Quaternion<T>.sinh(Quaternion(real: 0, imaginary: 0, 0, 0)))
    XCTAssertEqual(0, Quaternion<T>.sinh(Quaternion(real:-0, imaginary: 0, 0, 0)))
    XCTAssertEqual(0, Quaternion<T>.sinh(Quaternion(real:-0, imaginary:-0,-0,-0)))
    XCTAssertEqual(0, Quaternion<T>.sinh(Quaternion(real: 0, imaginary:-0,-0,-0)))
    // sinh is the identity at infinity.
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:  .infinity, imaginary: .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:  .infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:          0, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real: -.infinity, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real: -.infinity, imaginary: .zero)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real: -.infinity, imaginary: -.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:          0, imaginary: -.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:  .infinity, imaginary: -.infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:       .nan, imaginary: .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:  .infinity, imaginary: .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:       .nan, imaginary: .infinity)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real: -.infinity, imaginary: .nan)).isFinite)
    XCTAssertFalse(Quaternion<T>.sinh(Quaternion(real:       .nan, imaginary: -.infinity)).isFinite)
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
          T.random(in: -2 ... 2, using: &g) / 3,
          T.random(in: -2 ... 2, using: &g) / 3,
          T.random(in: -2 ... 2, using: &g) / 3
      )
    }
    for q in values {
      let c = Quaternion.cosh(q)
      let s = Quaternion.sinh(q)
      XCTAssert((c*c - s*s).isApproximatelyEqual(to: .one))
    }
  }

  func testLog<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    // log(0) = undefined/infinity
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real: 0, imaginary: 0, 0, 0)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:-0, imaginary: 0, 0, 0)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real:-0, imaginary:-0,-0,-0)).isFinite)
    XCTAssertFalse(Quaternion<T>.log(Quaternion(real: 0, imaginary:-0,-0,-0)).isFinite)

    var g = SystemRandomNumberGenerator()
    let values: [Quaternion<T>] = (0..<100).map { _ in
      Quaternion(
        real: T.random(in: -1 ... 1, using: &g),
        imaginary: SIMD3(repeating: T.random(in: -.pi ... .pi, using: &g) / 3))
    }
    for q in values {
      XCTAssertTrue(q.isApproximatelyEqual(to: .log(.exp(q))))
    }
  }

  func testCos<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    var g = SystemRandomNumberGenerator()
    let values: [Quaternion<T>] = (0..<1000).map { _ in
      Quaternion(
        real: T.random(in: -2 ... 2, using: &g),
        imaginary:
          T.random(in: -2 ... 2, using: &g) / 3,
          T.random(in: -2 ... 2, using: &g) / 3,
          T.random(in: -2 ... 2, using: &g) / 3
      )
    }
    for q in values {
      let c = Quaternion.cos(q)

      // For randomly-chosen well-scaled finite values, we expect to have
      // cos ≈ (e^(q*||v||)+e^(-q*||v||)) / 2
      let p = Quaternion(imaginary: q.imaginary / q.imaginary.length)
      let e = (.exp(p * q) + .exp(-p * q)) / 2
      XCTAssert(c.isApproximatelyEqual(to: e))
    }
  }

  func testSin<T: Real & FixedWidthFloatingPoint & SIMDScalar>(_ type: T.Type) {
    var g = SystemRandomNumberGenerator()
    let values: [Quaternion<T>] = (0..<1000).map { _ in
      Quaternion(
        real: T.random(in: -2 ... 2, using: &g),
        imaginary:
          T.random(in: -2 ... 2, using: &g) / 3,
          T.random(in: -2 ... 2, using: &g) / 3,
          T.random(in: -2 ... 2, using: &g) / 3
      )
    }
    for q in values {
      let s = Quaternion.sin(q)

      // For randomly-chosen well-scaled finite values, we expect to have
      // cos ≈ (e^(q*||v||)+e^(-q*||v||)) / 2
      let p = Quaternion(imaginary: q.imaginary / q.imaginary.length)
      let e = (.exp(p * q) - .exp(-p * q)) / (p * 2)
      XCTAssert(s.isApproximatelyEqual(to: e))

      // For randomly-chosen well-scaled finite values, we expect to have
      // cos² + sin² ≈ 1
      let c = Quaternion.cos(q)
      XCTAssert((c*c + s*s).isApproximatelyEqual(to: .one))
    }
  }

  func testFloat() {
    testExp(Float32.self)
    testExpMinusOne(Float32.self)
    testCosh(Float32.self)
    testSinh(Float32.self)
    testCos(Float32.self)
    testSin(Float32.self)

    testLog(Float32.self)
  }

  func testDouble() {
    testExp(Float64.self)
    testExpMinusOne(Float64.self)
    testCosh(Float64.self)
    testSinh(Float64.self)
    testCos(Float64.self)
    testSin(Float64.self)

    testLog(Float64.self)
  }
}
