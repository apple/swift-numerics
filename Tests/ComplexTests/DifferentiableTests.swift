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

#if canImport(_Differentiation)

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

    XCTAssertEqual(
      differential(at: Complex<Float>(5, 5), in: { $0.real * 2 })(Complex<Float>(1, 1)),
      2)
    XCTAssertEqual(
      differential(at: Complex<Float>(5, 5), in: { $0.imaginary * 2 })(Complex<Float>(1, 1)),
      2)
    XCTAssertEqual(
      differential(at: Complex<Float>(5, 5), in: { $0.real * 5 + $0.imaginary * 2 })(Complex<Float>(1, 1)),
      7)
  }

  func testConjugate() {
    let φ_pb = pullback(at: Complex<Float>(20, -4)) { x in x.conjugate }
    XCTAssertEqual(φ_pb(Complex(1, 0)), Complex(1, 0))
    XCTAssertEqual(φ_pb(Complex(0, 1)), Complex(0, -1))
    XCTAssertEqual(φ_pb(Complex(-1, 1)), Complex(-1, -1))

    let φ_df = differential(at: Complex<Float>(20, -4)) { x in x.conjugate }
    XCTAssertEqual(φ_df(Complex(1, 0)), Complex(1, 0))
    XCTAssertEqual(φ_df(Complex(0, 1)), Complex(0, -1))
    XCTAssertEqual(φ_df(Complex(-1, 1)), Complex(-1, -1))
  }

  func testArithmetics() {
    let φAdd_pb = pullback(at: Complex<Float>(2, 3)) { x in
      x + Complex(5, 6)
    }
    XCTAssertEqual(φAdd_pb(Complex(1, 1)), Complex(1, 1))

    let φAdd_df = differential(at: Complex<Float>(2, 3)) { x in
      x + Complex(5, 6)
    }
    XCTAssertEqual(φAdd_df(Complex(1, 1)), Complex(1, 1))

    let φSubtract_pb = pullback(at: Complex<Float>(2, 3)) { x in
      Complex(5, 6) - x
    }
    XCTAssertEqual(φSubtract_pb(Complex(1, 1)), Complex(-1, -1))

    let φSubtract_df = differential(at: Complex<Float>(2, 3)) { x in
      Complex(5, 6) - x
    }
    XCTAssertEqual(φSubtract_df(Complex(1, 1)), Complex(-1, -1))

    let φMultiply_pb = pullback(at: Complex<Float>(2, 3)) { x in x * x }
    XCTAssertEqual(φMultiply_pb(Complex(1, 0)), Complex(4, 6))
    XCTAssertEqual(φMultiply_pb(Complex(0, 1)), Complex(-6, 4))
    XCTAssertEqual(φMultiply_pb(Complex(1, 1)), Complex(-2, 10))

    let φMultiply_df = differential(at: Complex<Float>(2, 3)) { x in x * x }
    XCTAssertEqual(φMultiply_df(Complex(1, 1)), 2 * Complex<Float>(2, 3) * Complex(1, 1))
    XCTAssertEqual(φMultiply_df(Complex(0, 1)), 2 * Complex<Float>(2, 3) * Complex(0, 1))
    XCTAssertEqual(φMultiply_df(Complex(1, 0)), 2 * Complex<Float>(2, 3) * Complex(1, 0))

    let φDivide_pb = pullback(at: Complex<Float>(20, -4)) { x in
      x / Complex(2, 2)
    }
    XCTAssertEqual(φDivide_pb(Complex(1, 0)), Complex(0.25, -0.25))
    XCTAssertEqual(φDivide_pb(Complex(0, 1)), Complex(0.25, 0.25))

    let φDivide_df = differential(at: Complex<Float>(20, -4)) { x in
      x / Complex(2, 2)
    }
    XCTAssertEqual(φDivide_df(Complex(1, 1)), Complex(1, 1) / Complex(2, 2))
    XCTAssertEqual(φDivide_df(Complex(0, 1)), Complex(0, 1) / Complex(2, 2))
    XCTAssertEqual(φDivide_df(Complex(1, 0)), Complex(1, 0) / Complex(2, 2))
  }

  func testZeroTangentVectorInitializer() {
    XCTAssertEqual(Complex<Float>(-5, 5).zeroTangentVector, Complex(0, 0))
  }
}

#endif
