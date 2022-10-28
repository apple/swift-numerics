//===--- PropertyTests.swift ----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import ComplexModule
import RealModule

final class PropertyTests: XCTestCase {
  
  func testProperties<T: Real>(_ type: T.Type) {
    // The real and imaginary parts of a non-finite value should be nan.
    XCTAssertTrue(Complex<T>.infinity.real.isNaN)
    XCTAssertTrue(Complex<T>.infinity.imaginary.isNaN)
    XCTAssertTrue(Complex<T>(.infinity, .nan).real.isNaN)
    XCTAssertTrue(Complex<T>(.nan, 0).imaginary.isNaN)
    // The length of a non-finite value should be infinity.
    XCTAssertEqual(Complex<T>.infinity.length, .infinity)
    XCTAssertEqual(Complex<T>(.infinity, .nan).length, .infinity)
    XCTAssertEqual(Complex<T>(.nan, 0).length, .infinity)
    // The phase of a non-finite value should be nan.
    XCTAssertTrue(Complex<T>.infinity.phase.isNaN)
    XCTAssertTrue(Complex<T>(.infinity, .nan).phase.isNaN)
    XCTAssertTrue(Complex<T>(.nan, 0).phase.isNaN)
    // The length of a zero value should be zero.
    XCTAssertEqual(Complex<T>.zero.length, .zero)
    XCTAssertEqual(Complex<T>(.zero, -.zero).length, .zero)
    XCTAssertEqual(Complex<T>(-.zero,-.zero).length, .zero)
    // The phase of a zero value should be nan.
    XCTAssertTrue(Complex<T>.zero.phase.isNaN)
    XCTAssertTrue(Complex<T>(.zero, -.zero).phase.isNaN)
    XCTAssertTrue(Complex<T>(-.zero,-.zero).phase.isNaN)
  }
  
  func testProperties() {
    testProperties(Float.self)
    testProperties(Double.self)
    #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    testProperties(Float80.self)
    #endif
  }
  
  func testEquatableHashable<T: Real>(_ type: T.Type) {
    // Validate that all zeros compare and hash equal, and all non-finites
    // do too.
    let zeros = [
      Complex<T>( .zero, .zero),
      Complex<T>(-.zero, .zero),
      Complex<T>(-.zero,-.zero),
      Complex<T>( .zero,-.zero)
    ]
    for z in zeros[1...] {
      XCTAssertEqual(zeros[0], z)
      XCTAssertEqual(zeros[0].hashValue, z.hashValue)
    }
    let infs = [
      Complex<T>( .nan,      .nan),
      Complex<T>(-.infinity, .nan),
      Complex<T>(-.ulpOfOne, .nan),
      Complex<T>( .zero,     .nan),
      Complex<T>( .pi,       .nan),
      Complex<T>( .infinity, .nan),
      Complex<T>( .nan,     -.infinity),
      Complex<T>(-.infinity,-.infinity),
      Complex<T>(-.ulpOfOne,-.infinity),
      Complex<T>( .zero,    -.infinity),
      Complex<T>( .pi,      -.infinity),
      Complex<T>( .infinity,-.infinity),
      Complex<T>( .nan,     -.ulpOfOne),
      Complex<T>(-.infinity,-.ulpOfOne),
      Complex<T>( .infinity,-.ulpOfOne),
      Complex<T>( .nan,      .zero),
      Complex<T>(-.infinity, .zero),
      Complex<T>( .infinity, .zero),
      Complex<T>( .nan,      .pi),
      Complex<T>(-.infinity, .pi),
      Complex<T>( .infinity, .pi),
      Complex<T>( .nan,      .infinity),
      Complex<T>(-.infinity, .infinity),
      Complex<T>(-.ulpOfOne, .infinity),
      Complex<T>( .zero,     .infinity),
      Complex<T>( .pi,       .infinity),
      Complex<T>( .infinity, .infinity),
    ]
    for i in infs[1...] {
      XCTAssertEqual(infs[0], i)
      XCTAssertEqual(infs[0].hashValue, i.hashValue)
    }
  }
  
  func testEquatableHashable() {
    testEquatableHashable(Float.self)
    testEquatableHashable(Double.self)
    #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    testEquatableHashable(Float80.self)
    #endif
  }

  func testCodable<T: Codable & Real>(_ type: T.Type) throws {
    let encoder = JSONEncoder()
    encoder.nonConformingFloatEncodingStrategy = .convertToString(
      positiveInfinity: "inf",
      negativeInfinity: "-inf",
      nan: "nan")

    let decoder = JSONDecoder()
    decoder.nonConformingFloatDecodingStrategy = .convertFromString(
      positiveInfinity: "inf",
      negativeInfinity: "-inf",
      nan: "nan")

    for expected: Complex<T> in [.zero, .one, .i, .infinity] {
      let data = try encoder.encode(expected)
      // print("*** \(String(decoding: data, as: Unicode.UTF8.self)) ***")
      let actual = try decoder.decode(Complex<T>.self, from: data)
      XCTAssertEqual(actual, expected)
    }
  }

  func testCodable() throws {
    try testCodable(Float32.self)
    try testCodable(Float64.self)
    // Float80 doesn't conform to Codable.
  }
}
