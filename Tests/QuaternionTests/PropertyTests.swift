//===--- PropertyTests.swift ----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import RealModule

@testable import QuaternionModule

final class PropertyTests: XCTestCase {

  func testProperties<T: Real & SIMDScalar>(_ type: T.Type) {
    // The real and imaginary parts of a non-finite value should be nan.
    XCTAssertTrue(Quaternion<T>.infinity.real.isNaN)
    XCTAssertTrue(Quaternion<T>.infinity.imaginary.x.isNaN)
    XCTAssertTrue(Quaternion<T>.infinity.imaginary.y.isNaN)
    XCTAssertTrue(Quaternion<T>.infinity.imaginary.z.isNaN)
    XCTAssertTrue(Quaternion<T>(real: .infinity, imaginary: .nan, .nan, .nan).real.isNaN)
    XCTAssertTrue(Quaternion<T>(real: .nan, imaginary: 0, 0, 0).imaginary.x.isNaN)
    XCTAssertTrue(Quaternion<T>(real: .nan, imaginary: 0, 0, 0).imaginary.y.isNaN)
    XCTAssertTrue(Quaternion<T>(real: .nan, imaginary: 0, 0, 0).imaginary.z.isNaN)
    // The length of a non-finite value should be infinity.
    XCTAssertEqual(Quaternion<T>.infinity.length, .infinity)
    XCTAssertEqual(Quaternion<T>(real: .infinity, imaginary: .nan, .nan, .nan).length, .infinity)
    XCTAssertEqual(Quaternion<T>(real: .nan, imaginary: 0, 0, 0).length, .infinity)
    // The length of a zero value should be zero.
    XCTAssertEqual(Quaternion<T>.zero.length, .zero)
    XCTAssertEqual(Quaternion<T>(.zero, -.zero).length, .zero)
    XCTAssertEqual(Quaternion<T>(-.zero, -.zero).length, .zero)
  }

  func testProperties() {
    testProperties(Float32.self)
    testProperties(Float64.self)
  }

  func testEquatableHashable<T: Real & SIMDScalar>(_ type: T.Type) {
    // Validate that all zeros compare and hash equal, and all non-finites
    // do too.
    let zeros = [
        Quaternion<T>(real:  .zero, imaginary:  .zero,  .zero,  .zero),
        Quaternion<T>(real:  .zero, imaginary: -.zero,  .zero,  .zero),
        Quaternion<T>(real:  .zero, imaginary:  .zero, -.zero,  .zero),
        Quaternion<T>(real:  .zero, imaginary:  .zero,  .zero, -.zero),
        Quaternion<T>(real:  .zero, imaginary: -.zero, -.zero,  .zero),
        Quaternion<T>(real:  .zero, imaginary: -.zero,  .zero, -.zero),
        Quaternion<T>(real:  .zero, imaginary:  .zero, -.zero, -.zero),
        Quaternion<T>(real:  .zero, imaginary: -.zero, -.zero, -.zero),

        Quaternion<T>(real: -.zero, imaginary:  .zero,  .zero,  .zero),
        Quaternion<T>(real: -.zero, imaginary: -.zero,  .zero,  .zero),
        Quaternion<T>(real: -.zero, imaginary:  .zero, -.zero,  .zero),
        Quaternion<T>(real: -.zero, imaginary:  .zero,  .zero, -.zero),
        Quaternion<T>(real: -.zero, imaginary: -.zero, -.zero,  .zero),
        Quaternion<T>(real: -.zero, imaginary: -.zero,  .zero, -.zero),
        Quaternion<T>(real: -.zero, imaginary:  .zero, -.zero, -.zero),
        Quaternion<T>(real: -.zero, imaginary: -.zero, -.zero, -.zero)
    ]
    for z in zeros[1...] {
      XCTAssertEqual(zeros[0], z)
      XCTAssertEqual(zeros[0].hashValue, z.hashValue)
    }
    let infs = [
      Quaternion<T>(real:  .nan,      imaginary: .nan, .nan, .nan),
      Quaternion<T>(real: -.infinity, imaginary: .nan, .nan, .nan),
      Quaternion<T>(real: -.ulpOfOne, imaginary: .nan, .nan, .nan),
      Quaternion<T>(real:  .zero,     imaginary: .nan, .nan, .nan),
      Quaternion<T>(real:  .pi,       imaginary: .nan, .nan, .nan),
      Quaternion<T>(real:  .infinity, imaginary: .nan, .nan, .nan),
      Quaternion<T>(real:  .nan,      imaginary: -.infinity, -.infinity, -.infinity),
      Quaternion<T>(real: -.infinity, imaginary: -.infinity, -.infinity, -.infinity),
      Quaternion<T>(real: -.ulpOfOne, imaginary: -.infinity, -.infinity, -.infinity),
      Quaternion<T>(real:  .zero,     imaginary: -.infinity, -.infinity, -.infinity),
      Quaternion<T>(real:  .pi,       imaginary: -.infinity, -.infinity, -.infinity),
      Quaternion<T>(real:  .infinity, imaginary: -.infinity, -.infinity, -.infinity),
      Quaternion<T>(real:  .nan,      imaginary: -.ulpOfOne, -.ulpOfOne, -.ulpOfOne),
      Quaternion<T>(real: -.infinity, imaginary: -.ulpOfOne, -.ulpOfOne, -.ulpOfOne),
      Quaternion<T>(real:  .infinity, imaginary: -.ulpOfOne, -.ulpOfOne, -.ulpOfOne),
      Quaternion<T>(real:  .nan,      imaginary: .zero, .zero, .zero),
      Quaternion<T>(real: -.infinity, imaginary: .zero, .zero, .zero),
      Quaternion<T>(real:  .infinity, imaginary: .zero, .zero, .zero),
      Quaternion<T>(real:  .nan,      imaginary: .pi, .pi, .pi),
      Quaternion<T>(real: -.infinity, imaginary: .pi, .pi, .pi),
      Quaternion<T>(real:  .infinity, imaginary: .pi, .pi, .pi),
      Quaternion<T>(real:  .nan,      imaginary: .infinity, .infinity, .infinity),
      Quaternion<T>(real: -.infinity, imaginary: .infinity, .infinity, .infinity),
      Quaternion<T>(real: -.ulpOfOne, imaginary: .infinity, .infinity, .infinity),
      Quaternion<T>(real:  .zero,     imaginary: .infinity, .infinity, .infinity),
      Quaternion<T>(real:  .pi,       imaginary: .infinity, .infinity, .infinity),
      Quaternion<T>(real:  .infinity, imaginary: .infinity, .infinity, .infinity),
    ]
    for i in infs[1...] {
      XCTAssertEqual(infs[0], i)
      XCTAssertEqual(infs[0].hashValue, i.hashValue)
    }
    // Validate that all *normal* values hash their absolute components, so
    // that rotations in *R³* of `q` and `-q` will hash to same value.
    let pairs: [(lhs: Quaternion<T>, rhs: Quaternion<T>)] = [
      (
        Quaternion<T>(real: -.pi, imaginary:  .pi,  .pi,  .pi),
        Quaternion<T>(real:  .pi, imaginary: -.pi, -.pi, -.pi)
      ), (
        Quaternion<T>(real:  .pi, imaginary: -.pi,  .pi,  .pi),
        Quaternion<T>(real: -.pi, imaginary:  .pi, -.pi, -.pi)
      ), (
        Quaternion<T>(real:  .pi, imaginary:  .pi, -.pi,  .pi),
        Quaternion<T>(real: -.pi, imaginary: -.pi,  .pi, -.pi)
      ), (
        Quaternion<T>(real:  .pi, imaginary:  .pi,  .pi, -.pi),
        Quaternion<T>(real: -.pi, imaginary: -.pi, -.pi,  .pi)
      ), (
        Quaternion<T>(real: -.pi, imaginary: -.pi,  .pi,  .pi),
        Quaternion<T>(real:  .pi, imaginary:  .pi, -.pi, -.pi)
      ), (
        Quaternion<T>(real:  .pi, imaginary: -.pi, -.pi,  .pi),
        Quaternion<T>(real: -.pi, imaginary:  .pi,  .pi, -.pi)
      ), (
        Quaternion<T>(real:  .pi, imaginary:  .pi, -.pi, -.pi),
        Quaternion<T>(real: -.pi, imaginary: -.pi,  .pi,  .pi)
      ), (
        Quaternion<T>(real:  .pi, imaginary:  .pi,  .pi,  .pi),
        Quaternion<T>(real: -.pi, imaginary: -.pi, -.pi, -.pi)
      )
    ]
    for pair in pairs {
      XCTAssertEqual(pair.lhs.hashValue, pair.rhs.hashValue)
    }
  }

  func testEquatableHashable() {
    testEquatableHashable(Float32.self)
    testEquatableHashable(Float64.self)
  }

  func testTransformationEquals<T: Real & SIMDScalar>(_ type: T.Type) {
    let rotations: [(lhs: Quaternion<T>, rhs: Quaternion<T>)] = [
      (
        Quaternion<T>(real:  -.pi, imaginary:  -.pi,  -.pi,  -.pi),
        Quaternion<T>(real:   .pi, imaginary:   .pi,   .pi,   .pi)
      ), (
        Quaternion<T>(real:   .ulpOfOne, imaginary:   .ulpOfOne,   .ulpOfOne,   .ulpOfOne),
        Quaternion<T>(real:  -.ulpOfOne, imaginary:  -.ulpOfOne,  -.ulpOfOne,  -.ulpOfOne)
      ), (
        Quaternion<T>(real:   .pi, imaginary:  -.pi,   .pi,  -.pi),
        Quaternion<T>(real:  -.pi, imaginary:   .pi,  -.pi,   .pi)
      ), (
        Quaternion<T>(real:  -.ulpOfOne, imaginary:  -.ulpOfOne,   .ulpOfOne,   .ulpOfOne),
        Quaternion<T>(real:   .ulpOfOne, imaginary:   .ulpOfOne,  -.ulpOfOne,  -.ulpOfOne)
      ),

      // Zero and infinity must have equal rotations too
      (
         Quaternion<T>.zero,
        -Quaternion<T>.zero
      ), (
        -Quaternion<T>.infinity,
         Quaternion<T>.infinity
      ),
    ]
    for (lhs, rhs) in rotations {
      XCTAssertTrue(lhs.equals(as3DTransform: rhs))
    }

    let signDifferentAxis: [(lhs: Quaternion<T>, rhs: Quaternion<T>)] = [
      (
        Quaternion<T>(real:  -.pi, imaginary:  -.pi,  -.pi,  -.pi),
        Quaternion<T>(real:  -.pi, imaginary:   .pi,   .pi,   .pi)
      ), (
        Quaternion<T>(real:  -.ulpOfOne, imaginary:   .ulpOfOne,   .ulpOfOne,   .ulpOfOne),
        Quaternion<T>(real:  -.ulpOfOne, imaginary:  -.ulpOfOne,  -.ulpOfOne,  -.ulpOfOne)
      ), (
        Quaternion<T>(real:  -.pi, imaginary:  -.pi,   .pi,  -.pi),
        Quaternion<T>(real:  -.pi, imaginary:   .pi,  -.pi,   .pi)
      ), (
        Quaternion<T>(real:  -.ulpOfOne, imaginary:  -.ulpOfOne,   .ulpOfOne,   .ulpOfOne),
        Quaternion<T>(real:  -.ulpOfOne, imaginary:   .ulpOfOne,  -.ulpOfOne,  -.ulpOfOne)
      )
    ]
    for (lhs, rhs) in signDifferentAxis {
      XCTAssertFalse(lhs.equals(as3DTransform: rhs))
    }
  }

  func testTransformationEquals() {
    testTransformationEquals(Float32.self)
    testTransformationEquals(Float64.self)
  }

  func testCodable<T: Real & SIMDScalar>(_ type: T.Type) throws {
    let encoder = JSONEncoder()
    encoder.nonConformingFloatEncodingStrategy = .convertToString(
      positiveInfinity: "inf",
      negativeInfinity: "-inf",
      nan: "nan"
    )

    let decoder = JSONDecoder()
    decoder.nonConformingFloatDecodingStrategy = .convertFromString(
      positiveInfinity: "inf",
      negativeInfinity: "-inf",
      nan: "nan"
    )

    for expected: Quaternion<T> in [.zero, .one, .i, .infinity] {
      let data = try encoder.encode(expected)
      let actual = try decoder.decode(Quaternion<T>.self, from: data)
      XCTAssertEqual(actual, expected)
    }
  }

  func testCodable() throws {
    try testCodable(Float32.self)
    try testCodable(Float64.self)
  }
}
