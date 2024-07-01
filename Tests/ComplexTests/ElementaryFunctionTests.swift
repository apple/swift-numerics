//===--- ElementaryFunctionTests.swift ------------------------*- swift -*-===//
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

import XCTest
import ComplexModule
import RealModule
import _TestSupport

final class ElementaryFunctionTests: XCTestCase {
  
  func testExp<T: Real & FixedWidthFloatingPoint>(_ type: T.Type) {
    // exp(0) = 1
    XCTAssertEqual(1, Complex<T>.exp(Complex( 0, 0)))
    XCTAssertEqual(1, Complex<T>.exp(Complex(-0, 0)))
    XCTAssertEqual(1, Complex<T>.exp(Complex(-0,-0)))
    XCTAssertEqual(1, Complex<T>.exp(Complex( 0,-0)))
    // In general, exp(Complex(r,0)) should be exp(r), but that breaks down
    // when r is infinity or NaN, because we want all non-finite complex
    // values to be semantically a single point at infinity. This is fine
    // for most inputs, but exp(Complex(-.infinity, 0)) would produce
    // 0 if we evaluated it in the usual way.
    XCTAssertFalse(Complex<T>.exp(Complex( .infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.exp(Complex( .infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.exp(Complex(         0, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.exp(Complex(-.infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.exp(Complex(-.infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.exp(Complex(-.infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.exp(Complex(         0,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.exp(Complex( .infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.exp(Complex(      .nan, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.exp(Complex( .infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.exp(Complex(      .nan, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.exp(Complex(-.infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.exp(Complex(      .nan,-.infinity)).isFinite)
    // Find a value of x such that exp(x) just overflows. Then exp((x, π/4))
    // should not overflow, but will do so if it is not computed carefully.
    // The correct value is:
    //
    //   exp((log(gfm) + log(9/8), π/4) = exp((log(gfm*9/8), π/4))
    //                                  = gfm*9/8 * (1/sqrt(2), 1/(sqrt(2))
    let x = T.log(.greatestFiniteMagnitude) + T.log(9/8)
    let huge = Complex<T>.exp(Complex(x, .pi/4))
    let mag = T.greatestFiniteMagnitude/T.sqrt(2) * (9/8)
    XCTAssert(huge.real.isApproximatelyEqual(to: mag))
    XCTAssert(huge.imaginary.isApproximatelyEqual(to: mag))
    // For randomly-chosen well-scaled finite values, we expect to have the
    // usual identities:
    //
    //   exp(z + w) = exp(z) * exp(w)
    //   exp(z - w) = exp(z) / exp(w)
    var g = SystemRandomNumberGenerator()
    let values: [Complex<T>] = (0..<100).map { _ in
      Complex(T.random(in: -1 ... 1, using: &g),
              T.random(in: -.pi ... .pi, using: &g))
    }
    for z in values {
      for w in values {
        let p = Complex.exp(z) * Complex.exp(w)
        let q = Complex.exp(z) / Complex.exp(w)
        XCTAssert(Complex.exp(z + w).isApproximatelyEqual(to: p))
        XCTAssert(Complex.exp(z - w).isApproximatelyEqual(to: q))
      }
    }
  }
  
  func testExpMinusOne<T: Real & FixedWidthFloatingPoint>(_ type: T.Type) {
    // expMinusOne(0) = 0
    XCTAssertEqual(0, Complex<T>.expMinusOne(Complex( 0, 0)))
    XCTAssertEqual(0, Complex<T>.expMinusOne(Complex(-0, 0)))
    XCTAssertEqual(0, Complex<T>.expMinusOne(Complex(-0,-0)))
    XCTAssertEqual(0, Complex<T>.expMinusOne(Complex( 0,-0)))
    // In general, expMinusOne(Complex(r,0)) should be expMinusOne(r), but
    // that breaks down when r is infinity or NaN, because we want all non-
    // finite complex values to be semantically a single point at infinity.
    // This is fine for most inputs, but expMinusOne(Complex(-.infinity, 0))
    // would produce 0 if we evaluated it in the usual way.
    XCTAssertFalse(Complex<T>.expMinusOne(Complex( .infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.expMinusOne(Complex( .infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.expMinusOne(Complex(         0, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.expMinusOne(Complex(-.infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.expMinusOne(Complex(-.infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.expMinusOne(Complex(-.infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.expMinusOne(Complex(         0,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.expMinusOne(Complex( .infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.expMinusOne(Complex(      .nan, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.expMinusOne(Complex( .infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.expMinusOne(Complex(      .nan, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.expMinusOne(Complex(-.infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.expMinusOne(Complex(      .nan,-.infinity)).isFinite)
    // Near-overflow test, same as exp() above.
    let x = T.log(.greatestFiniteMagnitude) + T.log(9/8)
    let huge = Complex<T>.expMinusOne(Complex(x, .pi/4))
    let mag = T.greatestFiniteMagnitude/T.sqrt(2) * (9/8)
    XCTAssert(huge.real.isApproximatelyEqual(to: mag))
    XCTAssert(huge.imaginary.isApproximatelyEqual(to: mag))
    // For small values, expMinusOne should be approximately the identity.
    var g = SystemRandomNumberGenerator()
    let small = T.ulpOfOne
    for _ in 0 ..< 100 {
      let z = Complex<T>(T.random(in: -small ... small, using: &g),
                         T.random(in: -small ... small, using: &g))
      XCTAssert(z.isApproximatelyEqual(to: Complex.expMinusOne(z), relativeTolerance: 16 * .ulpOfOne))
    }
  }
  
  func testLogOnePlus<T: Real & FixedWidthFloatingPoint>(_ type: T.Type) {
    // log(onePlus: 0) = 0
    XCTAssertEqual(0, Complex<T>.log(onePlus: Complex( 0, 0)))
    XCTAssertEqual(0, Complex<T>.log(onePlus: Complex(-0, 0)))
    XCTAssertEqual(0, Complex<T>.log(onePlus: Complex(-0,-0)))
    XCTAssertEqual(0, Complex<T>.log(onePlus: Complex( 0,-0)))
    // log(onePlus:) is the identity at infinity.
    XCTAssertFalse(Complex<T>.log(onePlus: Complex( .infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.log(onePlus: Complex( .infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.log(onePlus: Complex(         0, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.log(onePlus: Complex(-.infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.log(onePlus: Complex(-.infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.log(onePlus: Complex(-.infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.log(onePlus: Complex(         0,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.log(onePlus: Complex( .infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.log(onePlus: Complex(      .nan, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.log(onePlus: Complex( .infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.log(onePlus: Complex(      .nan, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.log(onePlus: Complex(-.infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.log(onePlus: Complex(      .nan,-.infinity)).isFinite)
    // For randomly-chosen well-scaled finite values, we expect to have
    // log(onePlus: expMinusOne(z)) ≈ z
    var g = SystemRandomNumberGenerator()
    let values: [Complex<T>] = (0..<1000).map { _ in
      Complex(T.random(in: -2 ... 2, using: &g),
              T.random(in: -2 ... 2, using: &g))
    }
    for z in values {
      let w = Complex.expMinusOne(z)
      let u = Complex.log(onePlus: w)
      if !u.isApproximatelyEqual(to: z) {
        print("log(onePlus: expMinusOne()) was not close to identity at z = \(z).")
        print("expMinusOne(\(z)) = \(w).")
        print("long(onePlus: \(w)) = \(u).")
        XCTFail()
      }
    }
  }
  
  func testCosh<T: Real & FixedWidthFloatingPoint>(_ type: T.Type) {
    // cosh(0) = 1
    XCTAssertEqual(1, Complex<T>.cosh(Complex( 0, 0)))
    XCTAssertEqual(1, Complex<T>.cosh(Complex(-0, 0)))
    XCTAssertEqual(1, Complex<T>.cosh(Complex(-0,-0)))
    XCTAssertEqual(1, Complex<T>.cosh(Complex( 0,-0)))
    // cosh is the identity at infinity.
    XCTAssertFalse(Complex<T>.cosh(Complex( .infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.cosh(Complex( .infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.cosh(Complex(         0, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.cosh(Complex(-.infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.cosh(Complex(-.infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.cosh(Complex(-.infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.cosh(Complex(         0,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.cosh(Complex( .infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.cosh(Complex(      .nan, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.cosh(Complex( .infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.cosh(Complex(      .nan, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.cosh(Complex(-.infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.cosh(Complex(      .nan,-.infinity)).isFinite)
    // Near-overflow test, same as exp() above, but it happens later, because
    // for large x, cosh(x + iy) ~ exp(x + iy)/2.
    let x = T.log(.greatestFiniteMagnitude) + T.log(18/8)
    let mag = T.greatestFiniteMagnitude/T.sqrt(2) * (9/8)
    var huge = Complex<T>.cosh(Complex(x, .pi/4))
    XCTAssert(huge.real.isApproximatelyEqual(to: mag))
    XCTAssert(huge.imaginary.isApproximatelyEqual(to: mag))
    huge = Complex<T>.cosh(Complex(-x, .pi/4))
    XCTAssert(huge.real.isApproximatelyEqual(to: mag))
    XCTAssert(huge.imaginary.isApproximatelyEqual(to: mag))
  }
  
  func testSinh<T: Real & FixedWidthFloatingPoint>(_ type: T.Type) {
    // sinh(0) = 0
    XCTAssertEqual(0, Complex<T>.sinh(Complex( 0, 0)))
    XCTAssertEqual(0, Complex<T>.sinh(Complex(-0, 0)))
    XCTAssertEqual(0, Complex<T>.sinh(Complex(-0,-0)))
    XCTAssertEqual(0, Complex<T>.sinh(Complex( 0,-0)))
    // sinh is the identity at infinity.
    XCTAssertFalse(Complex<T>.sinh(Complex( .infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.sinh(Complex( .infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.sinh(Complex(         0, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.sinh(Complex(-.infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.sinh(Complex(-.infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.sinh(Complex(-.infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.sinh(Complex(         0,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.sinh(Complex( .infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.sinh(Complex(      .nan, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.sinh(Complex( .infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.sinh(Complex(      .nan, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.sinh(Complex(-.infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.sinh(Complex(      .nan,-.infinity)).isFinite)
    // Near-overflow test, same as exp() above, but it happens later, because
    // for large x, sinh(x + iy) ~ ±exp(x + iy)/2.
    let x = T.log(.greatestFiniteMagnitude) + T.log(18/8)
    let mag = T.greatestFiniteMagnitude/T.sqrt(2) * (9/8)
    var huge = Complex<T>.sinh(Complex(x, .pi/4))
    XCTAssert(huge.real.isApproximatelyEqual(to: mag))
    XCTAssert(huge.imaginary.isApproximatelyEqual(to: mag))
    huge = Complex<T>.sinh(Complex(-x, .pi/4))
    XCTAssert(huge.real.isApproximatelyEqual(to: -mag))
    XCTAssert(huge.imaginary.isApproximatelyEqual(to: -mag))
    // For randomly-chosen well-scaled finite values, we expect to have
    // cosh² - sinh² ≈ 1. Note that this test would break down due to
    // catastrophic cancellation as we get further away from the origin.
    var g = SystemRandomNumberGenerator()
    let values: [Complex<T>] = (0..<1000).map { _ in
      Complex(T.random(in: -2 ... 2, using: &g),
              T.random(in: -2 ... 2, using: &g))
    }
    for z in values {
      let c = Complex.cosh(z)
      let s = Complex.sinh(z)
      XCTAssert((c*c - s*s).isApproximatelyEqual(to: 1))
    }
  }
  
  func testAcos<T: Real & FixedWidthFloatingPoint>(_ type: T.Type) {
    // acos(1) = 0
    XCTAssertEqual(0, Complex<T>.acos(1))
    // acos(0) = π/2
    XCTAssert(Complex<T>.acos(0).real.isApproximatelyEqual(to: .pi/2))
    XCTAssertEqual(Complex<T>.acos(0).imaginary, 0)
    // acos(-1) = π
    XCTAssert(Complex<T>.acos(-1).real.isApproximatelyEqual(to: .pi))
    XCTAssertEqual(Complex<T>.acos(-1).imaginary, 0)
    // acos is the identity at infinity.
    XCTAssertFalse(Complex<T>.acos(Complex( .infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.acos(Complex( .infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.acos(Complex(         0, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.acos(Complex(-.infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.acos(Complex(-.infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.acos(Complex(-.infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.acos(Complex(         0,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.acos(Complex( .infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.acos(Complex(      .nan, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.acos(Complex( .infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.acos(Complex(      .nan, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.acos(Complex(-.infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.acos(Complex(      .nan,-.infinity)).isFinite)
    // For randomly-chosen well-scaled finite values, we expect to have
    // cos(acos(z)) ≈ z and acos(z) ≈ π - acos(-z)
    var g = SystemRandomNumberGenerator()
    let values: [Complex<T>] = (0..<1000).map { _ in
      Complex(T.random(in: -2 ... 2, using: &g),
              T.random(in: -2 ... 2, using: &g))
    }
    for z in values {
      let w = Complex.acos(z)
      XCTAssert(Complex.cos(w).isApproximatelyEqual(to: z))
      XCTAssert(w.isApproximatelyEqual(to: Complex(.pi) - .acos(-z)))
    }
  }
  
  func testAsin<T: Real & FixedWidthFloatingPoint>(_ type: T.Type) {
    // asin(1) = π/2
    XCTAssert(Complex<T>.asin(1).real.isApproximatelyEqual(to: .pi/2))
    XCTAssertEqual(Complex<T>.asin(1).imaginary, 0)
    // asin(0) = 0
    XCTAssertEqual(0, Complex<T>.asin(0))
    // asin(-1) = -π/2
    XCTAssert(Complex<T>.asin(-1).real.isApproximatelyEqual(to: -.pi/2))
    XCTAssertEqual(Complex<T>.asin(-1).imaginary, 0)
    // asin is the identity at infinity.
    XCTAssertFalse(Complex<T>.asin(Complex( .infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.asin(Complex( .infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.asin(Complex(         0, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.asin(Complex(-.infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.asin(Complex(-.infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.asin(Complex(-.infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.asin(Complex(         0,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.asin(Complex( .infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.asin(Complex(      .nan, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.asin(Complex( .infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.asin(Complex(      .nan, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.asin(Complex(-.infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.asin(Complex(      .nan,-.infinity)).isFinite)
    // For randomly-chosen well-scaled finite values, we expect to have
    // sin(asin(z)) ≈ z and asin(z) ≈ -asin(-z)
    var g = SystemRandomNumberGenerator()
    let values: [Complex<T>] = (0..<1000).map { _ in
      Complex(T.random(in: -2 ... 2, using: &g),
              T.random(in: -2 ... 2, using: &g))
    }
    for z in values {
      let w = Complex.asin(z)
      XCTAssert(Complex.sin(w).isApproximatelyEqual(to: z))
      XCTAssert(w.isApproximatelyEqual(to: -.asin(-z)))
    }
  }
  
  func testAcosh<T: Real & FixedWidthFloatingPoint>(_ type: T.Type) {
    // acosh(1) = 0
    XCTAssertEqual(0, Complex<T>.acosh(1))
    // acosh(0) = iπ/2
    XCTAssert(Complex<T>.acosh(0).imaginary.isApproximatelyEqual(to: .pi/2))
    XCTAssertEqual(Complex<T>.acosh(0).real, 0)
    // acosh(-1) = iπ
    XCTAssert(Complex<T>.acosh(-1).imaginary.isApproximatelyEqual(to: .pi))
    XCTAssertEqual(Complex<T>.acosh(-1).real, 0)
    // acosh is the identity at infinity.
    XCTAssertFalse(Complex<T>.acosh(Complex( .infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.acosh(Complex( .infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.acosh(Complex(         0, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.acosh(Complex(-.infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.acosh(Complex(-.infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.acosh(Complex(-.infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.acosh(Complex(         0,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.acosh(Complex( .infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.acosh(Complex(      .nan, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.acosh(Complex( .infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.acosh(Complex(      .nan, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.acosh(Complex(-.infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.acosh(Complex(      .nan,-.infinity)).isFinite)
    // For randomly-chosen well-scaled finite values, we expect to have
    // cosh(acosh(z)) ≈ z
    var g = SystemRandomNumberGenerator()
    let values: [Complex<T>] = (0..<1000).map { _ in
      Complex(T.random(in: -2 ... 2, using: &g),
              T.random(in: -2 ... 2, using: &g))
    }
    for z in values {
      let w = Complex.acosh(z)
      XCTAssert(Complex.cosh(w).isApproximatelyEqual(to: z))
    }
  }
  
  func testAsinh<T: Real & FixedWidthFloatingPoint>(_ type: T.Type) {
    // asinh(1) = π/2
    XCTAssert(Complex<T>.asin(1).real.isApproximatelyEqual(to: .pi/2))
    XCTAssertEqual(Complex<T>.asin(1).imaginary, 0)
    // asinh(0) = 0
    XCTAssertEqual(0, Complex<T>.asin(0))
    // asinh(-1) = -π/2
    XCTAssert(Complex<T>.asin(-1).real.isApproximatelyEqual(to: -.pi/2))
    XCTAssertEqual(Complex<T>.asin(-1).imaginary, 0)
    // asinh is the identity at infinity.
    XCTAssertFalse(Complex<T>.asinh(Complex( .infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.asinh(Complex( .infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.asinh(Complex(         0, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.asinh(Complex(-.infinity, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.asinh(Complex(-.infinity, 0)).isFinite)
    XCTAssertFalse(Complex<T>.asinh(Complex(-.infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.asinh(Complex(         0,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.asinh(Complex( .infinity,-.infinity)).isFinite)
    XCTAssertFalse(Complex<T>.asinh(Complex(      .nan, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.asinh(Complex( .infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.asinh(Complex(      .nan, .infinity)).isFinite)
    XCTAssertFalse(Complex<T>.asinh(Complex(-.infinity, .nan)).isFinite)
    XCTAssertFalse(Complex<T>.asinh(Complex(      .nan,-.infinity)).isFinite)
    // For randomly-chosen well-scaled finite values, we expect to have
    // sinh(asinh(z)) ≈ z
    var g = SystemRandomNumberGenerator()
    let values: [Complex<T>] = (0..<1000).map { _ in
      Complex(T.random(in: -2 ... 2, using: &g),
              T.random(in: -2 ... 2, using: &g))
    }
    for z in values {
      let w = Complex.asinh(z)
      let u = Complex.sinh(w)
      if !u.isApproximatelyEqual(to: z) {
        print("sinh(asinh()) was not close to identity at z = \(z).")
        print("asinh(\(z)) = \(w).")
        print("sinh(\(w)) = \(u).")
        XCTFail()
      }
    }
  }
  
  func testAtanh<T: Real & FixedWidthFloatingPoint>(_ type: T.Type) {
    // For randomly-chosen well-scaled finite values, we expect to have
    // atanh(tanh(z)) ≈ z
    var g = SystemRandomNumberGenerator()
    let values: [Complex<T>] = (0..<1000).map { _ in
      Complex(T.random(in: -2 ... 2, using: &g),
              T.random(in: -2 ... 2, using: &g))
    }
    for z in values {
      let w = Complex.atanh(z)
      let u = Complex.tanh(w)
      if !u.isApproximatelyEqual(to: z) {
        print("tanh(atanh()) was not close to identity at z = \(z).")
        print("atanh(\(z)) = \(w).")
        print("tanh(\(w)) = \(u).")
        XCTFail()
      }
    }
  }
  
  func testPowR<T: Real & FixedWidthFloatingPoint>(_ type: T.Type) {
    XCTAssertEqual(Complex<T>.pow(.zero, -.one),  .infinity)
    XCTAssertEqual(Complex<T>.pow(.zero,  .zero), .infinity)
    XCTAssertEqual(Complex<T>.pow(.zero, +.one),  .zero)
  }
  
  func testPowN<T: Real & FixedWidthFloatingPoint>(_ type: T.Type) {
    XCTAssertEqual(Complex<T>.pow(.zero, -1), .infinity)
    XCTAssertEqual(Complex<T>.pow(.zero,  0), .one)
    XCTAssertEqual(Complex<T>.pow(.zero, +1), .zero)
  }
  
  func testFloat() {
    testExp(Float.self)
    testExpMinusOne(Float.self)
    testLogOnePlus(Float.self)
    testCosh(Float.self)
    testSinh(Float.self)
    testAcos(Float.self)
    testAsin(Float.self)
    testAcosh(Float.self)
    testAsinh(Float.self)
    testAtanh(Float.self)
    testPowR(Float.self)
    testPowN(Float.self)
  }
  
  func testDouble() {
    testExp(Double.self)
    testExpMinusOne(Double.self)
    testLogOnePlus(Float.self)
    testCosh(Double.self)
    testSinh(Double.self)
    testAcos(Double.self)
    testAsin(Double.self)
    testAcosh(Double.self)
    testAsinh(Double.self)
    testAtanh(Double.self)
    testPowR(Double.self)
    testPowN(Double.self)
  }
  
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
  func testFloat80() {
    testExp(Float80.self)
    testExpMinusOne(Float80.self)
    testLogOnePlus(Float.self)
    testCosh(Float80.self)
    testSinh(Float80.self)
    testAcos(Float80.self)
    testAsin(Float80.self)
    testAcosh(Float80.self)
    testAsinh(Float80.self)
    testAtanh(Float80.self)
    testPowR(Float80.self)
    testPowN(Float80.self)
  }
#endif
}
