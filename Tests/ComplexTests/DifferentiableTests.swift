//===--- DifferentiableTests.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

#if swift(>=5.3) && canImport(_Differentiation)

import XCTest
import ComplexModule
import _Differentiation

final class DifferentiableTests: XCTestCase {
  func testComponentGetter() {
    XCTAssertEqual(
      gradient(at: Complex<Float>(5, 5)) { $0.real * 2 },
      Complex(2, 0))
    XCTAssertEqual(
      gradient(at: Complex<Float>(5, 5)) { $0.imaginary * 2 },
      Complex(0, 2))
    XCTAssertEqual(
      gradient(at: Complex<Float>(5, 5)) { $0.real * 5 + $0.imaginary * 2 },
      Complex(5, 2))
  }

  func testInitializer() {
    let φ1 = pullback(at: 4, -3) { r, i in Complex<Float>(r, i) }
    let tan1 = φ1(Complex(-1, 2))
    XCTAssertEqual(tan1.0, -1)
    XCTAssertEqual(tan1.1, 2)

    let φ2 = pullback(at: 4, -3) { r, i in Complex<Float>(r * r, i + i) }
    let tan2 = φ2(Complex(-1, 1))
    XCTAssertEqual(tan2.0, -8)
    XCTAssertEqual(tan2.1, 2)
  }

  func testConjugate() {
    let φ = pullback(at: Complex<Float>(20, -4)) { x in x.conjugate }
    XCTAssertEqual(φ(Complex(1, 0)), Complex(1, 0))
    XCTAssertEqual(φ(Complex(0, 1)), Complex(0, -1))
    XCTAssertEqual(φ(Complex(-1, 1)), Complex(-1, -1))
  }

  func testArithmetics() {
    let φAdd = pullback(at: Complex<Float>(2, 3)) { x in
      x + Complex(5, 6)
    }
    XCTAssertEqual(φAdd(Complex(1, 1)), Complex(1, 1))

    let φSubtract = pullback(at: Complex<Float>(2, 3)) { x in
      Complex(5, 6) - x
    }
    XCTAssertEqual(φSubtract(Complex(1, 1)), Complex(-1, -1))

    let φMultiply = pullback(at: Complex<Float>(2, 3)) { x in x * x }
    XCTAssertEqual(φMultiply(Complex(1, 0)), Complex(4, 6))
    XCTAssertEqual(φMultiply(Complex(0, 1)), Complex(-6, 4))
    XCTAssertEqual(φMultiply(Complex(1, 1)), Complex(-2, 10))

    let φDivide = pullback(at: Complex<Float>(20, -4)) { x in
      x / Complex(2, 2)
    }
    XCTAssertEqual(φDivide(Complex(1, 0)), Complex(0.25, -0.25))
    XCTAssertEqual(φDivide(Complex(0, 1)), Complex(0.25, 0.25))
  }
}

#endif
