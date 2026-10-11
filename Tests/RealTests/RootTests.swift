//===--- RootTests.swift --------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule
import XCTest

/// `bⁿ` as an exact integer, or `nil` if it overflows.
private func exactPower(_ b: Int, _ n: Int) -> Int? {
  var result = 1
  for _ in 0..<n {
    let (next, overflow) = result.multipliedReportingOverflow(by: b)
    if overflow { return nil }
    result = next
  }
  return result
}

private let orders = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 17]

final class RootTests: XCTestCase {

  /// `root(bⁿ, n)` is `b` whenever `bⁿ` is exactly representable.
  func testExactIntegerPowersDouble() {
    let limit = 1 << 53
    for n in orders {
      for b in 2...200 {
        guard let power = exactPower(b, n), power <= limit else { continue }
        let x = Double(power)
        XCTAssertEqual(Double(b), Double.root(x, n), "root(\(power), \(n))")
        XCTAssertEqual(1/Double(b), Double.root(x, -n), "root(\(power), \(-n))")
      }
    }
  }

  func testExactIntegerPowersFloat() {
    let limit = 1 << 24
    for n in orders {
      for b in 2...200 {
        guard let power = exactPower(b, n), power <= limit else { continue }
        let x = Float(power)
        XCTAssertEqual(Float(b), Float.root(x, n), "root(\(power), \(n))")
        XCTAssertEqual(1/Float(b), Float.root(x, -n), "root(\(power), \(-n))")
      }
    }
  }

  func testExactIntegerPowersOfNegativeValues() {
    for n in orders where n % 2 == 1 {
      for b in 2...50 {
        guard let power = exactPower(b, n), power <= 1 << 53 else { continue }
        let x = -Double(power)
        XCTAssertEqual(-Double(b), Double.root(x, n), "root(\(-power), \(n))")
        XCTAssertEqual(-1/Double(b), Double.root(x, -n), "root(\(-power), \(-n))")
      }
    }
  }

  func testRootEdgeCases() {
    XCTAssert(Double.root(-4, 2).isNaN)
    XCTAssert(Double.root(-1, 4).isNaN)
    XCTAssert(Double.root(.nan, 3).isNaN)
    XCTAssertEqual(0, Double.root(0, 2))
    XCTAssertEqual(-0.0, Double.root(-0.0, 3))
    XCTAssert(Double.root(-0.0, 3).sign == .minus)
    XCTAssertEqual(.infinity, Double.root(.infinity, 2))
    XCTAssertEqual(-.infinity, Double.root(-.infinity, 3))
    // n == 0 keeps the pow behaviour it has always had.
    XCTAssertEqual(5, Double.root(5, 1))
    XCTAssertEqual(0.2, Double.root(5, -1))
    XCTAssertEqual(.infinity, Double.root(5, 0))
    // Above the correction window the uncorrected estimate stands.
    XCTAssertEqual(1 + Double.log(2)/0x1p20, Double.root(2, 1 << 20),
                   accuracy: 1e-12)
  }

  /// The correction must not cost accuracy on inputs that are not exact powers.
  func testRootIsAccurateOnNonExactInputs() {
    var state = UInt64(0x9E3779B97F4A7C15)
    func next() -> Double {
      state ^= state >> 12; state ^= state << 25; state ^= state >> 27
      return Double((state &* 0x2545F4914F6CDD1D) >> 11) * 0x1p-53
    }
    for _ in 0..<20000 {
      let x = 1 + next() * 1e6
      let n = 2 + Int(next() * 10)
      let y = Double.root(x, n)
      XCTAssertEqual(Double.pow(y, n), x, accuracy: x * 8 * .ulpOfOne,
                     "root(\(x), \(n)) == \(y)")
    }
  }
}
