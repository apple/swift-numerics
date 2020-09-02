//===--- ElementaryFunctionTests.swift ------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
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
  
  func testFloat() {
    testExp(Float.self)
    testExpMinusOne(Float.self)
  }
  
  func testDouble() {
    testExp(Double.self)
    testExpMinusOne(Double.self)
  }
  
  #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
  func testFloat80() {
    testExp(Float80.self)
    testExpMinusOne(Float80.self)
  }
  #endif
}
