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

#if PERFORMANCE_TEST

private struct TestValues {
  fileprivate let int: [BigInt]
  fileprivate let big: [BigInt]

  fileprivate var intBig: CartesianProduct<BigInt, BigInt> {
    return CartesianProduct(self.int, self.big)
  }

  fileprivate var bigBig: CartesianProduct<BigInt, BigInt> {
    return CartesianProduct(self.big, self.big)
  }

  fileprivate init(count: Int) {
    self.int = generateInts(approximateCount: count).map(BigInt.init)
    self.big = generateBigInts(approximateCount: count, maxWordCount: maxWordCount).map { $0.create() }
  }
}

private let maxWordCount = 100 // Word = UInt64
private let stringValues = TestValues(count: 200)
private let unaryValues = TestValues(count: 50_000)
private let addSubValues = TestValues(count: 200)
private let mulDivValues = TestValues(count: 100)
private let andOrXorValues = TestValues(count: 200)
private let shiftValues = TestValues(count: 20_000)
private let shifts = [0, 7, 61, 67, 127] // Primes, but that does not matter

private let metrics: [XCTMetric] = [XCTClockMetric()] // XCTMemoryMetric()?
private let options = XCTMeasureOptions.default

#if os(Linux)
private class XCTMetric {}
private class XCTClockMetric: XCTMetric {}

private struct XCTMeasureOptions {
  fileprivate static let `default` = XCTMeasureOptions()
}

extension XCTestCase {
  fileprivate func measure(metrics: [XCTMetric], options: XCTMeasureOptions, fn: () -> ()) {
    // Create static values, fill cache, etc.
    fn()

    let clock = ContinuousClock()
    var results = [Duration]()

    for _ in 0..<10 {
      let elapsed = clock.measure(fn)
      results.append(elapsed)
    }

    let withoutExtremes = results.sorted().dropFirst().dropLast()
    let totalDuration = withoutExtremes.reduce(Duration.seconds(0), +)
    let averageDuration = totalDuration / withoutExtremes.count
    print("average: \(averageDuration), values: \(results)")
  }
}
#endif // #if os(Linux)

class PerformanceTests: XCTestCase {

  // MARK: - From String

  func test_string_fromRadix10() {
    let strings = stringValues.big.map { String($0, radix: 10, uppercase: false) }

    self.measure(metrics: metrics, options: options) {
      for s in strings {
        _ = BigInt(s, radix: 10)
      }
    }
  }

  func test_string_fromRadix16() {
    let strings = stringValues.big.map { String($0, radix: 16, uppercase: false) }

    self.measure(metrics: metrics, options: options) {
      for s in strings {
        _ = BigInt(s, radix: 16)
      }
    }
  }

  // MARK: - To string

  func test_string_toRadix10() {
    self.measure(metrics: metrics, options: options) {
      for n in stringValues.big {
        _ = String(n, radix: 10, uppercase: false)
      }
    }
  }

  func test_string_toRadix16() {
    self.measure(metrics: metrics, options: options) {
      for n in stringValues.big {
        _ = String(n, radix: 16, uppercase: false)
      }
    }
  }

  // MARK: - Plus

  func test_unary_plus_int() {
    self.measure(metrics: metrics, options: options) {
      for n in unaryValues.int {
        _ = +n
      }
    }
  }

  func test_unary_plus_big() {
    self.measure(metrics: metrics, options: options) {
      for n in unaryValues.big {
        _ = +n
      }
    }
  }

  // MARK: - Minus

  func test_unary_minus_int() {
    self.measure(metrics: metrics, options: options) {
      for n in unaryValues.int {
        _ = -n
      }
    }
  }

  func test_unary_minus_big() {
    self.measure(metrics: metrics, options: options) {
      for n in unaryValues.big {
        _ = -n
      }
    }
  }

  // MARK: - Invert

  func test_unary_invert_int() {
    self.measure(metrics: metrics, options: options) {
      for n in unaryValues.int {
        _ = ~n
      }
    }
  }

  func test_unary_invert_big() {
    self.measure(metrics: metrics, options: options) {
      for n in unaryValues.big {
        _ = ~n
      }
    }
  }

  // MARK: - Add

  func test_binary_add_int() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in addSubValues.intBig {
        _ = big + int
      }
    }
  }

  func test_binary_add_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in addSubValues.intBig {
        var copy = big
        copy += int
      }
    }
  }

  func test_binary_add_big() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in addSubValues.bigBig {
        _ = lhs + rhs
      }
    }
  }

  func test_binary_add_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in addSubValues.bigBig {
        var copy = lhs
        copy += rhs
      }
    }
  }

  // MARK: - Sub

  func test_binary_sub_int() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in addSubValues.intBig {
        _ = big - int
      }
    }
  }

  func test_binary_sub_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in addSubValues.intBig {
        var copy = big
        copy -= int
      }
    }
  }

  func test_binary_sub_big() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in addSubValues.bigBig {
        _ = lhs - rhs
      }
    }
  }

  func test_binary_sub_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in addSubValues.bigBig {
        var copy = lhs
        copy -= rhs
      }
    }
  }

  // MARK: - Mul

  func test_binary_mul_int() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in mulDivValues.intBig {
        _ = big * int
      }
    }
  }

  func test_binary_mul_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in mulDivValues.intBig {
        var copy = big
        copy *= int
      }
    }
  }

  func test_binary_mul_big() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in mulDivValues.bigBig {
        _ = lhs * rhs
      }
    }
  }

  func test_binary_mul_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in mulDivValues.bigBig {
        var copy = lhs
        copy *= rhs
      }
    }
  }

  // MARK: - Div

  func test_binary_div_int() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in mulDivValues.intBig {
        if int == 0 { continue }
        _ = big / int
      }
    }
  }

  func test_binary_div_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in mulDivValues.intBig {
        if int == 0 { continue }
        var copy = big
        copy /= int
      }
    }
  }

  func test_binary_div_big() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in mulDivValues.bigBig {
        if rhs == 0 { continue }
        _ = lhs / rhs
      }
    }
  }

  func test_binary_div_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in mulDivValues.bigBig {
        if rhs == 0 { continue }
        var copy = lhs
        copy /= rhs
      }
    }
  }

  // MARK: - Mod

  func test_binary_mod_int() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in mulDivValues.intBig {
        if int == 0 { continue }
        _ = big % int
      }
    }
  }

  func test_binary_mod_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in mulDivValues.intBig {
        if int == 0 { continue }
        var copy = big
        copy %= int
      }
    }
  }

  func test_binary_mod_big() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in mulDivValues.bigBig {
        if rhs == 0 { continue }
        _ = lhs % rhs
      }
    }
  }

  func test_binary_mod_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in mulDivValues.bigBig {
        if rhs == 0 { continue }
        var copy = lhs
        copy %= rhs
      }
    }
  }

  // MARK: - And

  func test_binary_and_int() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in andOrXorValues.intBig {
        _ = big & int
      }
    }
  }

  func test_binary_and_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in andOrXorValues.intBig {
        var copy = big
        copy &= int
      }
    }
  }

  func test_binary_and_big() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in andOrXorValues.bigBig {
        _ = lhs & rhs
      }
    }
  }

  func test_binary_and_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in andOrXorValues.bigBig {
        var copy = lhs
        copy &= rhs
      }
    }
  }

  // MARK: - Or

  func test_binary_or_int() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in andOrXorValues.intBig {
        _ = big | int
      }
    }
  }

  func test_binary_or_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in andOrXorValues.intBig {
        var copy = big
        copy |= int
      }
    }
  }

  func test_binary_or_big() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in andOrXorValues.bigBig {
        _ = lhs | rhs
      }
    }
  }

  func test_binary_or_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in andOrXorValues.bigBig {
        var copy = lhs
        copy |= rhs
      }
    }
  }

  // MARK: - Xor

  func test_binary_xor_int() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in andOrXorValues.intBig {
        _ = big ^ int
      }
    }
  }

  func test_binary_xor_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for (int, big) in andOrXorValues.intBig {
        var copy = big
        copy ^= int
      }
    }
  }

  func test_binary_xor_big() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in andOrXorValues.bigBig {
        _ = lhs ^ rhs
      }
    }
  }

  func test_binary_xor_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for (lhs, rhs) in andOrXorValues.bigBig {
        var copy = lhs
        copy ^= rhs
      }
    }
  }

  // MARK: - Shift left

  func test_shiftLeft_int() {
    self.measure(metrics: metrics, options: options) {
      for n in shiftValues.int {
        for shift in shifts {
          _ = n << shift
        }
      }
    }
  }

  func test_shiftLeft_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for n in shiftValues.int {
        for shift in shifts {
          var copy = n
          copy <<= shift
        }
      }
    }
  }

  func test_shiftLeft_big() {
    self.measure(metrics: metrics, options: options) {
      for n in shiftValues.big {
        for shift in shifts {
          _ = n << shift
        }
      }
    }
  }

  func test_shiftLeft_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for n in shiftValues.big {
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
      for n in shiftValues.int {
        for shift in shifts {
          _ = n >> shift
        }
      }
    }
  }

  func test_shiftRight_int_inout() {
    self.measure(metrics: metrics, options: options) {
      for n in shiftValues.int {
        for shift in shifts {
          var copy = n
          copy >>= shift
        }
      }
    }
  }

  func test_shiftRight_big() {
    self.measure(metrics: metrics, options: options) {
      for n in shiftValues.big {
        for shift in shifts {
          _ = n >> shift
        }
      }
    }
  }

  func test_shiftRight_big_inout() {
    self.measure(metrics: metrics, options: options) {
      for n in shiftValues.big {
        for shift in shifts {
          var copy = n
          copy >>= shift
        }
      }
    }
  }
}

#endif // #if PERFORMANCE_TEST
