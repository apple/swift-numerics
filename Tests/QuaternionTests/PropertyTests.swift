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
    XCTAssertTrue(Quaternion<T>(.infinity, (.nan, .nan, .nan)).real.isNaN)
    XCTAssertTrue(Quaternion<T>(.nan, (0, 0, 0)).imaginary.x.isNaN)
    XCTAssertTrue(Quaternion<T>(.nan, (0, 0, 0)).imaginary.y.isNaN)
    XCTAssertTrue(Quaternion<T>(.nan, (0, 0, 0)).imaginary.z.isNaN)
    // The length of a non-finite value should be infinity.
    XCTAssertEqual(Quaternion<T>.infinity.length, .infinity)
    XCTAssertEqual(Quaternion<T>(.infinity, (.nan, .nan, .nan)).length, .infinity)
    XCTAssertEqual(Quaternion<T>(.nan, (0, 0, 0)).length, .infinity)
    // The length of a zero value should be zero.
    XCTAssertEqual(Quaternion<T>.zero.length, .zero)
    XCTAssertEqual(Quaternion<T>(.zero, -.zero).length, .zero)
    XCTAssertEqual(Quaternion<T>(-.zero,-.zero).length, .zero)
  }

  func testProperties() {
    testProperties(Float32.self)
    testProperties(Float64.self)
  }

  func testEquatableHashable<T: Real & SIMDScalar>(_ type: T.Type) {
    // Validate that all zeros compare and hash equal, and all non-finites
    // do too.
    let zeros = [
      Quaternion<T>( .zero, ( .zero,  .zero,  .zero)),
      Quaternion<T>( .zero, (-.zero,  .zero,  .zero)),
      Quaternion<T>( .zero, ( .zero, -.zero,  .zero)),
      Quaternion<T>( .zero, ( .zero,  .zero, -.zero)),
      Quaternion<T>( .zero, (-.zero, -.zero,  .zero)),
      Quaternion<T>( .zero, (-.zero,  .zero, -.zero)),
      Quaternion<T>( .zero, ( .zero, -.zero, -.zero)),
      Quaternion<T>( .zero, (-.zero, -.zero, -.zero)),

      Quaternion<T>(-.zero, ( .zero,  .zero,  .zero)),
      Quaternion<T>(-.zero, (-.zero,  .zero,  .zero)),
      Quaternion<T>(-.zero, ( .zero, -.zero,  .zero)),
      Quaternion<T>(-.zero, ( .zero,  .zero, -.zero)),
      Quaternion<T>(-.zero, (-.zero, -.zero,  .zero)),
      Quaternion<T>(-.zero, (-.zero,  .zero, -.zero)),
      Quaternion<T>(-.zero, ( .zero, -.zero, -.zero)),
      Quaternion<T>(-.zero, (-.zero, -.zero, -.zero))
    ]
    for z in zeros[1...] {
      XCTAssertEqual(zeros[0], z)
      XCTAssertEqual(zeros[0].hashValue, z.hashValue)
    }
    let infs = [
      Quaternion<T>( .nan,      (.nan, .nan, .nan)),
      Quaternion<T>(-.infinity, (.nan, .nan, .nan)),
      Quaternion<T>(-.ulpOfOne, (.nan, .nan, .nan)),
      Quaternion<T>( .zero,     (.nan, .nan, .nan)),
      Quaternion<T>( .pi,       (.nan, .nan, .nan)),
      Quaternion<T>( .infinity, (.nan, .nan, .nan)),
      Quaternion<T>( .nan,      (-.infinity, -.infinity, -.infinity)),
      Quaternion<T>(-.infinity, (-.infinity, -.infinity, -.infinity)),
      Quaternion<T>(-.ulpOfOne, (-.infinity, -.infinity, -.infinity)),
      Quaternion<T>( .zero,     (-.infinity, -.infinity, -.infinity)),
      Quaternion<T>( .pi,       (-.infinity, -.infinity, -.infinity)),
      Quaternion<T>( .infinity, (-.infinity, -.infinity, -.infinity)),
      Quaternion<T>( .nan,      (-.ulpOfOne, -.ulpOfOne, -.ulpOfOne)),
      Quaternion<T>(-.infinity, (-.ulpOfOne, -.ulpOfOne, -.ulpOfOne)),
      Quaternion<T>( .infinity, (-.ulpOfOne, -.ulpOfOne, -.ulpOfOne)),
      Quaternion<T>( .nan,      (.zero, .zero, .zero)),
      Quaternion<T>(-.infinity, (.zero, .zero, .zero)),
      Quaternion<T>( .infinity, (.zero, .zero, .zero)),
      Quaternion<T>( .nan,      (.pi, .pi, .pi)),
      Quaternion<T>(-.infinity, (.pi, .pi, .pi)),
      Quaternion<T>( .infinity, (.pi, .pi, .pi)),
      Quaternion<T>( .nan,      (.infinity, .infinity, .infinity)),
      Quaternion<T>(-.infinity, (.infinity, .infinity, .infinity)),
      Quaternion<T>(-.ulpOfOne, (.infinity, .infinity, .infinity)),
      Quaternion<T>( .zero,     (.infinity, .infinity, .infinity)),
      Quaternion<T>( .pi,       (.infinity, .infinity, .infinity)),
      Quaternion<T>( .infinity, (.infinity, .infinity, .infinity)),
    ]
    for i in infs[1...] {
      XCTAssertEqual(infs[0], i)
      XCTAssertEqual(infs[0].hashValue, i.hashValue)
    }
  }

  func testEquatableHashable() {
    testEquatableHashable(Float32.self)
    testEquatableHashable(Float64.self)
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
