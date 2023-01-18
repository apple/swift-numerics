//===--- AppleBigIntTests.swift -------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import BigIntModule

// Tests were partially copied from:
// https://github.com/apple/swift/blob/master/test/Prototypes/BigInt.swift

class AppleBigIntTests: XCTestCase {

  // MARK: - Initialization

  func test_initialization() {
    let x = BigInt(1_000_000 as Int)
    XCTAssertEqual(x, 1_000_000)

    let y = BigInt(1_000 as UInt16)
    XCTAssertEqual(y, 1_000)

    let z = BigInt(-1_000_000 as Int)
    XCTAssertEqual(z, -1_000_000)
    XCTAssertTrue(z < 0)
  }

  // MARK: - Identity/Fixed point

  func test_identity_fixedPoint() {
    let x = BigInt(Int.max)
    let y = -x

    XCTAssertEqual(x / x, 1)
    XCTAssertEqual(x / y, -1)
    XCTAssertEqual(y / x, -1)
    XCTAssertEqual(y / y, 1)
    XCTAssertEqual(x % x, 0)
    XCTAssertEqual(x % y, 0)
    XCTAssertEqual(y % x, 0)
    XCTAssertEqual(y % y, 0)

    XCTAssertEqual(x * 1, x)
    XCTAssertEqual(y * 1, y)
    XCTAssertEqual(x * -1, y)
    XCTAssertEqual(y * -1, x)
    XCTAssertEqual(-x, y)
    XCTAssertEqual(-y, x)

    XCTAssertEqual(x + 0, x)
    XCTAssertEqual(y + 0, y)
    XCTAssertEqual(x - 0, x)
    XCTAssertEqual(y - 0, y)

    XCTAssertEqual(x - x, 0)
    XCTAssertEqual(y - y, 0)
  }

  // MARK: - Zero arithmetic

  func test_zeroArithmetic() {
    let x: BigInt = 1
    XCTAssertEqual(x - x, 0)

    let y: BigInt = -1
    XCTAssertEqual(y - y, 0)

    XCTAssertEqual(x * 0, 0)
  }

  // MARK: - Conformances

  func test_conformances() {
    // Comparable
    let x = BigInt(Int16.max)
    let y = x * x * x
    XCTAssertLessThan(y, y + 1)
    XCTAssertGreaterThan(y, y - 1)
    XCTAssertGreaterThan(y, 0)

    let z = -y
    XCTAssertLessThan(z, z + 1)
    XCTAssertGreaterThan(z, z - 1)
    XCTAssertLessThan(z, 0)

    XCTAssertEqual(-z, y)
    XCTAssertEqual(y + z, 0)

    // Hashable
    XCTAssertNotEqual(x.hashValue, y.hashValue)
    XCTAssertNotEqual(y.hashValue, z.hashValue)

    let set = Set([x, y, z])
    XCTAssertTrue(set.contains(x))
    XCTAssertTrue(set.contains(y))
    XCTAssertTrue(set.contains(z))
    XCTAssertFalse(set.contains(-x))
  }

  // MARK: - BinaryInteger interop

  func test_binaryInteger_interop() {
    let x: BigInt = 100
    let xComp = UInt8(x)
    XCTAssertTrue(x == xComp)
    XCTAssertTrue(x < xComp + 1)
    XCTAssertFalse(xComp + 1 < x)

    let y: BigInt = -100
    let yComp = Int8(y)
    XCTAssertTrue(y == yComp)
    XCTAssertTrue(y < yComp + 1)
    XCTAssertFalse(yComp + 1 < y)

    let zComp = Int.min + 1
    let z = BigInt(zComp)
    XCTAssertTrue(z == zComp)
    XCTAssertTrue(zComp == z)
    XCTAssertFalse(zComp + 1 < z)
    XCTAssertTrue(z < zComp + 1)

    let w = BigInt(UInt32.max)
    let wComp = UInt(truncatingIfNeeded: w)
    XCTAssertTrue(w == wComp)
    XCTAssertTrue(wComp == w)
    XCTAssertTrue(wComp - 1 < w)
    XCTAssertFalse(w < wComp - 1)
  }

  // MARK: - Huge

  func test_huge() {
    let x = BigInt(1_000_000)
    XCTAssertGreaterThan(x, x - 1)
    let y = -x
    XCTAssertGreaterThan(y, y - 1)
  }

  // MARK: - Strings

  // cSpell:ignore wtkgm UNIZHA

  func test_strings() {
    guard let x = BigInt("-171usy24wtkgm", radix: 36) else {
      XCTFail("Parse failed")
      return
    }

    XCTAssertEqual(
      String(x, radix: 2, uppercase: false),
      "-100111010100011100000111111110111011001110110100101110011010110"
    )
    XCTAssertEqual(String(x, radix: 10, uppercase: false), "-5666517882467146966")
    XCTAssertEqual(String(x, radix: 16, uppercase: false), "-4ea383fdd9da5cd6")
    XCTAssertEqual(String(x, radix: 36, uppercase: false), "-171usy24wtkgm")

    XCTAssertTrue(BigInt("12345") == 12_345)
    XCTAssertTrue(BigInt("-12345") == -12_345)

    XCTAssertNil(BigInt("-3UNIZHA6PAL30Y", radix: 10))
    XCTAssertNil(BigInt("---"))
    XCTAssertNil(BigInt(" 123"))
  }

  private func toString(_ value: BigInt, base: Int) -> String {
    return String(value, radix: base, uppercase: false)
  }

  // MARK: - Bitshift

  func test_bitshift() {
    XCTAssertEqual(BigInt(255) << 1, 510)
    XCTAssertTrue(BigInt(UInt32.max) << 16 == UInt(UInt32.max) << 16)

    var (x, y) = (1 as BigInt, 1 as UInt64)
    for i in 0..<63 { // don't test 64-bit shift, UInt64 << 64 == 0
      XCTAssertTrue(x << i == y << i, "Iteration: \(i)")
    }

    x = BigInt(-1)
    let z = -1 as Int
    for i in 0..<64 {
      XCTAssertTrue(x << i == z << i, "Iteration: \(i)")
    }
  }

  // MARK: - Bitwise

  func test_bitwise() {
    let values = [
      BigInt(Int.max - 2),
      BigInt(255),
      BigInt(256),
      BigInt(UInt32.max)
    ]

    for value in values {
      for x in [value, -value] {
        XCTAssertTrue((x | 0) == x)
        XCTAssertTrue((x & 0) == 0)
        XCTAssertTrue((x & ~0) == x)
        XCTAssertTrue((x ^ 0) == x)
        XCTAssertTrue((x ^ ~0) == ~x)
        XCTAssertTrue(x == BigInt(Int(truncatingIfNeeded: x)))
        XCTAssertTrue(~x == BigInt(~Int(truncatingIfNeeded: x)))
      }
    }
  }

  // ==============================
  // ======== CUSTOM TESTS ========
  // ==============================

  // MARK: - Magnitude

  func test_magnitude() {
    let values: [Int64] = [.min, -1, 0, 1, .max]

    for value in values {
      let x = BigInt(value).magnitude
      let y = BigInt(value.magnitude)
      XCTAssertEqual(x, y, "Value: \(value)")
    }
  }

  // MARK: - MinRequiredWidth

/*
  // === NOT SUPPORTED by current implementation ===

  func test_minRequiredWidth() {
    XCTAssertEqual(BigInt(0).minRequiredWidth, 0)

    for shift in 0..<63 {
      // >>> int.bit_length(1 << 0) -> 1
      // >>> int.bit_length(1 << 1) -> 2
      // >>> int.bit_length(1 << 2) -> 3
      // >>> int.bit_length(1 << 63) -> 64
      let value = BigInt(1) << shift
      XCTAssertEqual(value.minRequiredWidth, shift + 1)
    }

    for shift in 0..<63 {
      // >>> int.bit_length(-1 << 0) -> 1
      // >>> int.bit_length(-1 << 1) -> 2
      // >>> int.bit_length(-1 << 2) -> 3
      // >>> int.bit_length(-1 << 63) -> 64
      let value = BigInt(-1) << shift
      XCTAssertEqual(value.minRequiredWidth, shift + 1)
    }
  }

  func minRequiredWidthHelper() {
    for plus in 0...15 {
      let value = -plus
      let str = abs(value) < 10 ? " -\(abs(value))" : value.description
      print(str, "|", terminator: "")

      withUnsafeBytes(of: value) { bufferPtr in
        for byte in bufferPtr {
          let hex = String(byte, radix: 2, uppercase: false)
          let hexPad = hex.padding(toLength: 8, withPad: "0", startingAt: 0)
          print(hexPad + " ", terminator: "")
        }
        print()
      }
    }
  }
*/
}
