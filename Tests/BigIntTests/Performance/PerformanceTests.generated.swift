//===--- PerformanceTests.generated.swift ---------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//
// Automatically generated. DO NOT EDIT!
// To regenerate:
// python3 PerformanceTests.generated.py > PerformanceTests.generated.swift
//===----------------------------------------------------------------------===//

import XCTest
@testable import BigIntModule

private let ints = generateInts(approximateCount: 400).map(BigInt.init)
private let bigs = generateBigInts(approximateCount: 400, maxWordCount: 20).map { $0.create() }
private let bigsForString = generateBigInts(approximateCount: 5000, maxWordCount: 20).map { $0.create() }
private let shifts = [0, 7, 61, 67, 127] // Primes, but that does not matter

private let intBig = CartesianProduct(ints, bigs)
private let bigBig = CartesianProduct(bigs, bigs)

private let metrics: [XCTMetric] = [XCTClockMetric()] // XCTMemoryMetric()?
private let options = XCTMeasureOptions.default

class PerformanceTests: XCTestCase {

  // MARK: - From String

  func test_fromString_radix10() {
    let strings = bigsForString.map { String($0, radix: 10, uppercase: false) }

    self.measure(metrics: metrics, options: options) {
      for s in strings {
        _ = BigInt(s, radix: 10)
      }
    }
  }

  func test_fromString_radix16() {
    let strings = bigsForString.map { String($0, radix: 16, uppercase: false) }

    self.measure(metrics: metrics, options: options) {
      for s in strings {
        _ = BigInt(s, radix: 16)
      }
    }
  }

  // MARK: - To string

  func test_toString_radix10() {
    self.measure(metrics: metrics, options: options) {
      for n in bigsForString {
        _ = String(n, radix: 10, uppercase: false)
      }
    }
  }

  func test_toString_radix16() {
    self.measure(metrics: metrics, options: options) {
      for n in bigsForString {
        _ = String(n, radix: 16, uppercase: false)
      }
    }
  }

  // MARK: - Plus

  func test_plus_int() {
    self.measure(metrics: metrics, options: options) {
      for n in ints {
        _ = +n
      }
    }
  }

  func test_plus_big() {
    self.measure(metrics: metrics, options: options) {
      for n in bigs {
        _ = +n
      }
    }
  }

  // MARK: - Minus

  func test_minus_int() {
    self.measure(metrics: metrics, options: options) {
      for n in ints {
        _ = -n
      }
    }
  }

  func test_minus_big() {
    self.measure(metrics: metrics, options: options) {
      for n in bigs {
        _ = -n
      }
    }
  }

  // MARK: - Add

  func test_add_int() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in intBig {
        _ = big + int
      }
    }
  }

  func test_add_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in intBig {
        var copy = big
        copy += int
      }
    }
  }

  func test_add_big() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in bigBig {
        _ = lhs + rhs
      }
    }
  }

  func test_add_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in bigBig {
        var copy = lhs
        copy += rhs
      }
    }
  }

  // MARK: - Sub

  func test_sub_int() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in intBig {
        _ = big - int
      }
    }
  }

  func test_sub_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in intBig {
        var copy = big
        copy -= int
      }
    }
  }

  func test_sub_big() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in bigBig {
        _ = lhs - rhs
      }
    }
  }

  func test_sub_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in bigBig {
        var copy = lhs
        copy -= rhs
      }
    }
  }

  // MARK: - Mul

  func test_mul_int() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in intBig {
        _ = big * int
      }
    }
  }

  func test_mul_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in intBig {
        var copy = big
        copy *= int
      }
    }
  }

  func test_mul_big() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in bigBig {
        _ = lhs * rhs
      }
    }
  }

  func test_mul_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in bigBig {
        var copy = lhs
        copy *= rhs
      }
    }
  }

  // MARK: - Div

  func test_div_int() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in intBig {
        if int == 0 { continue }
        _ = big / int
      }
    }
  }

  func test_div_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in intBig {
        if int == 0 { continue }
        var copy = big
        copy /= int
      }
    }
  }

  func test_div_big() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in bigBig {
        if rhs == 0 { continue }
        _ = lhs / rhs
      }
    }
  }

  func test_div_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in bigBig {
        if rhs == 0 { continue }
        var copy = lhs
        copy /= rhs
      }
    }
  }

  // MARK: - Mod

  func test_mod_int() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in intBig {
        if int == 0 { continue }
        _ = big % int
      }
    }
  }

  func test_mod_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in intBig {
        if int == 0 { continue }
        var copy = big
        copy %= int
      }
    }
  }

  func test_mod_big() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in bigBig {
        if rhs == 0 { continue }
        _ = lhs % rhs
      }
    }
  }

  func test_mod_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in bigBig {
        if rhs == 0 { continue }
        var copy = lhs
        copy %= rhs
      }
    }
  }

  // MARK: - Shift left

  func test_shiftLeft_int() {
    self.measure(metrics: metrics, options: options) {
      for n in ints {
        for shift in shifts {
          _ = n << shift
        }
      }
    }
  }

  func test_shiftLeft_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for n in ints {
        for shift in shifts {
          var copy = n
          copy <<= shift
        }
      }
    }
  }

  func test_shiftLeft_big() {
    self.measure(metrics: metrics, options: options) {
      for n in bigs {
        for shift in shifts {
          _ = n << shift
        }
      }
    }
  }

  func test_shiftLeft_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for n in bigs {
        for shift in shifts {
          var copy = n
          copy <<= shift
        }
      }
    }
  }

  // MARK: - Shift right

  func test_shiftRight_int() {
    self.measure(metrics: metrics, options: options) {
      for n in ints {
        for shift in shifts {
          _ = n >> shift
        }
      }
    }
  }

  func test_shiftRight_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for n in ints {
        for shift in shifts {
          var copy = n
          copy >>= shift
        }
      }
    }
  }

  func test_shiftRight_big() {
    self.measure(metrics: metrics, options: options) {
      for n in bigs {
        for shift in shifts {
          _ = n >> shift
        }
      }
    }
  }

  func test_shiftRight_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for n in bigs {
        for shift in shifts {
          var copy = n
          copy >>= shift
        }
      }
    }
  }
}
