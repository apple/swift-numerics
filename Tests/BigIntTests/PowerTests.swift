//===--- PowerTests.swift -------------------------------------*- swift -*-===//
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

class PowerTests: XCTestCase {

  // MARK: - Trivial base

  /// 0 ^ n = 0 (or sometimes 1)
  func test_base_zero() {
    let zero = BigInt(0)
    let one = BigInt(1)

    for int in generateInts(approximateCount: 100) {
      let exponentInt = int.magnitude
      let exponent = BigInt(exponentInt)
      let result = zero.power(exponent: exponent)

      // 0 ^ 0 = 1, otherwise 0
      let expected = exponentInt == 0 ? one : zero
      XCTAssertEqual(result, expected, "0 ^ \(exponentInt)")
    }
  }

  /// 1 ^ n = 1
  func test_base_one() {
    let one = BigInt(1)

    for int in generateInts(approximateCount: 100) {
      let exponentInt = int.magnitude
      let exponent = BigInt(exponentInt)
      let result = one.power(exponent: exponent)

      let expected = one
      XCTAssertEqual(result, expected, "1 ^ \(exponentInt)")
    }
  }

  /// (-1) ^ n = (-1) or 1
  func test_base_minusOne() {
    let plusOne = BigInt(1)
    let minusOne = BigInt(-1)

    for int in generateInts(approximateCount: 100) {
      let exponentInt = int.magnitude
      let exponent = BigInt(exponentInt)
      let result = minusOne.power(exponent: exponent)

      let expected = exponentInt.isMultiple(of: 2) ? plusOne : minusOne
      XCTAssertEqual(result, expected, "(-1) ^ \(exponentInt)")
    }
  }

  // MARK: - Trivial exponent

  /// n ^ 0 = 1
  func test_exponent_zero() {
    let zero = BigInt(0)
    let one = BigInt(1)

    for int in generateInts(approximateCount: 100) {
      let base = BigInt(int)
      let result = base.power(exponent: zero)

      let expected = one
      XCTAssertEqual(result, expected, "\(int) ^ 1")
    }
  }

  /// n ^ 1 = n
  func test_exponent_one() {
    let one = BigInt(1)

    for int in generateInts(approximateCount: 100) {
      let base = BigInt(int)
      let result = base.power(exponent: one)

      let expected = base
      XCTAssertEqual(result, expected, "\(int) ^ 1")
    }
  }

  func test_exponent_two() {
    let two = BigInt(2)

    for p in generateBigInts(approximateCount: 100) {
      let base = p.create()
      let result = base.power(exponent: two)

      let expected = base * base
      XCTAssertEqual(result, expected, "\(base) ^ 2")
    }
  }

  func test_exponent_three() {
    let three = BigInt(3)

    for p in generateBigInts(approximateCount: 100) {
      let base = p.create()
      let result = base.power(exponent: three)

      let expected = base * base * base
      XCTAssertEqual(result, expected, "\(base) ^ 3")
    }
  }

  // MARK: - Int

  func test_againstFoundationPow() {
    // THIS IS NOT A PERFECT TEST!
    // It is 'good enough' to be usable, but don't think about it too much!
    let mantissaCount = Double.significandBitCount // well… technically '+1'
    let maxExactlyRepresentable = UInt(pow(Double(2), Double(mantissaCount)))

    var values = generateInts(approximateCount: 20)
    for i in -10...10 {
      values.append(i)
    }

    for (baseInt, expIntSigned) in CartesianProduct(values) {
      let expInt = expIntSigned.magnitude

      guard let baseDouble = Double(exactly: baseInt),
            let expDouble = Double(exactly: expInt) else {
          continue
      }

      let expectedDouble = pow(baseDouble, expDouble)

      guard let expectedInt = Int(exactly: expectedDouble),
                expectedInt.magnitude < maxExactlyRepresentable else {
        continue
      }

      // Some tests will actually get here, not a lot, but some
      let base = BigInt(baseInt)
      let exp = BigInt(expInt)
      let result = base.power(exponent: exp)

      let expected = BigInt(expectedInt)
      XCTAssertEqual(result, expected, "\(baseInt) ^ \(expInt)")
    }
  }
}
