#===--- PerformanceTests.generated.py --------------------------*- swift -*-===#
#
# This source file is part of the Swift Numerics open source project
#
# Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information
#
#===------------------------------------------------------------------------===#

STRING_RADIXES = (8, 10, 16)


def print_string_parse_tests():
    print()
    print('  // MARK: - From String')

    for radix in STRING_RADIXES:
        print(f'''
  func test_string_fromRadix{radix}() {{
    let strings = stringValues.big.map {{ String($0, radix: {radix}, uppercase: false) }}

    self.measure(metrics: metrics, options: options) {{
      for s in strings {{
        _ = BigInt(s, radix: {radix})
      }}
    }}
  }}\
''')


def print_to_string_tests():
    print()
    print('  // MARK: - To string')

    for radix in STRING_RADIXES:
        print(f'''
  func test_string_toRadix{radix}() {{
    self.measure(metrics: metrics, options: options) {{
      for n in stringValues.big {{
        _ = String(n, radix: {radix}, uppercase: false)
      }}
    }}
  }}\
''')


def print_equatable_tests():
    print(f'''
  // MARK: - Equatable

  func test_equatable_int() {{
    self.measure(metrics: metrics, options: options) {{
      for (int, big) in equatableComparableValues.intBig {{
        _ = big == int
      }}
    }}
  }}

  func test_equatable_big() {{
    self.measure(metrics: metrics, options: options) {{
      for (lhs, rhs) in equatableComparableValues.bigBig {{
        _ = lhs == rhs
      }}
    }}
  }}\
''')


def print_comparable_tests():
    print(f'''
  // MARK: - Comparable

  func test_comparable_int() {{
    self.measure(metrics: metrics, options: options) {{
      for (int, big) in equatableComparableValues.intBig {{
        _ = big < int
      }}
    }}
  }}

  func test_comparable_big() {{
    self.measure(metrics: metrics, options: options) {{
      for (lhs, rhs) in equatableComparableValues.bigBig {{
        _ = lhs < rhs
      }}
    }}
  }}\
''')


def print_unary_tests(name: str, operator: str):
    name_lower = name.lower()
    print(f'''
  // MARK: - {name}

  func test_unary_{name_lower}_int() {{
    self.measure(metrics: metrics, options: options) {{
      for n in unaryValues.int {{
        _ = {operator}n
      }}
    }}
  }}

  func test_unary_{name_lower}_big() {{
    self.measure(metrics: metrics, options: options) {{
      for n in unaryValues.big {{
        _ = {operator}n
      }}
    }}
  }}\
''')


def print_binary_tests(name: str, operator: str, *, is_mul: bool = False, is_div: bool = False, is_bit: bool = False):
    name_lower = name.lower()
    avoid_div_0_int = '\n        if int == 0 { continue }' if is_div else ''
    avoid_div_0_big = '\n        if rhs == 0 { continue }' if is_div else ''
    values = \
        'mulDivValues' if (is_mul or is_div) else \
        'andOrXorValues' if is_bit else \
        'addSubValues'

    print(f'''
  // MARK: - {name}

  func test_binary_{name_lower}_int() {{
    self.measure(metrics: metrics, options: options) {{
      for (int, big) in {values}.intBig {{{avoid_div_0_int}
        _ = big {operator} int
      }}
    }}
  }}

  func test_binary_{name_lower}_int_inout() {{
    self.measure(metrics: metrics, options: options) {{
      for (int, big) in {values}.intBig {{{avoid_div_0_int}
        var copy = big
        copy {operator}= int
      }}
    }}
  }}

  func test_binary_{name_lower}_big() {{
    self.measure(metrics: metrics, options: options) {{
      for (lhs, rhs) in {values}.bigBig {{{avoid_div_0_big}
        _ = lhs {operator} rhs
      }}
    }}
  }}

  func test_binary_{name_lower}_big_inout() {{
    self.measure(metrics: metrics, options: options) {{
      for (lhs, rhs) in {values}.bigBig {{{avoid_div_0_big}
        var copy = lhs
        copy {operator}= rhs
      }}
    }}
  }}\
''')


def print_shift_tests(direction: str, operator: str):
    direction_lower = direction.lower()

    print(f'''
  // MARK: - Shift {direction_lower}

  func test_shift{direction}_int() {{
    self.measure(metrics: metrics, options: options) {{
      for n in shiftValues.int {{
        for shift in shifts {{
          _ = n {operator} shift
        }}
      }}
    }}
  }}

  func test_shift{direction}_int_inout() {{
    self.measure(metrics: metrics, options: options) {{
      for n in shiftValues.int {{
        for shift in shifts {{
          var copy = n
          copy {operator}= shift
        }}
      }}
    }}
  }}

  func test_shift{direction}_big() {{
    self.measure(metrics: metrics, options: options) {{
      for n in shiftValues.big {{
        for shift in shifts {{
          _ = n {operator} shift
        }}
      }}
    }}
  }}

  func test_shift{direction}_big_inout() {{
    self.measure(metrics: metrics, options: options) {{
      for n in shiftValues.big {{
        for shift in shifts {{
          var copy = n
          copy {operator}= shift
        }}
      }}
    }}
  }}\
''')


def print_pi_tests():

    print()
    print('  // MARK: - π')

    for n in (500, 1_000, 5_000):
        print(f'''
  func test_pi_{n}() {{
    self.measure(metrics: metrics, options: options) {{
      self.π(count: {n})
    }}
  }}\
''')

    print('''
  // Adapted from:
  // https://github.com/apple/swift-numerics/pull/120 by Xiaodi Wu (xwu)
  func π(count: Int) {
    var acc: BigInt = 0
    var num: BigInt = 1
    var den: BigInt = 1

    func extractDigit(_ n: UInt) -> UInt {
      var tmp = num * BigInt(n)
      tmp += acc
      tmp /= den
      return tmp.words[0]
    }

    func eliminateDigit(_ d: UInt) {
      acc -= den * BigInt(d)
      acc *= 10
      num *= 10
    }

    func nextTerm(_ k: UInt) {
      let k2 = BigInt(k * 2 + 1)
      acc += num * 2
      acc *= k2
      den *= k2
      num *= BigInt(k)
    }

    var i = 0
    var k = 0 as UInt
    var string = ""
    while i < count {
      k += 1
      nextTerm(k)
      if num > acc { continue }
      let d = extractDigit(3)
      if d != extractDigit(4) { continue }
      string.append("\(d)")
      i += 1
      if i.isMultiple(of: 10) {
        print("\(string)\\t:\(i)")
        string = ""
      }
      eliminateDigit(d)
    }
  }\
''')


def main():
    print(f'''\
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
import Foundation
@testable import BigIntModule

// swiftlint:disable line_length
// swiftlint:disable file_length
// swiftlint:disable function_body_length
// swiftlint:disable force_unwrapping
// swiftlint:disable convenience_type

#if PERFORMANCE_TEST

private struct TestValues {{
  fileprivate let int: [BigInt]
  fileprivate let big: [BigInt]

  fileprivate var intBig: CartesianProduct<BigInt, BigInt> {{
    return CartesianProduct(self.int, self.big)
  }}

  fileprivate var bigBig: CartesianProduct<BigInt, BigInt> {{
    return CartesianProduct(self.big, self.big)
  }}

  /// Please note that the 'count' parameter is ultra approximate.
  /// The actual count of the generated numbers is different
  /// (but not too far from `count`).
  fileprivate init(count: Int) {{
    self.int = generateInts(approximateCount: count).map {{ BigInt($0) }}
    self.big = generateBigInts(approximateCount: count, maxWordCount: maxWordCount).map {{ $0.create() }}
  }}
}}

private let maxWordCount = 100 // Word = UInt64
private let stringValues = TestValues(count: 1000)
private let equatableComparableValues = TestValues(count: 1000)
private let unaryValues = TestValues(count: 100_000)
private let addSubValues = TestValues(count: 200)
private let mulDivValues = TestValues(count: 100)
private let andOrXorValues = TestValues(count: 200)
private let shiftValues = TestValues(count: 20_000)
private let shifts = [0, 7, 61, 67, 127] // Primes, but that does not matter

private let metrics: [XCTMetric] = [XCTClockMetric()] // XCTMemoryMetric()?
private let options = XCTMeasureOptions.default

#if os(Linux)
#if swift(<5.7)
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
private typealias Duration = Float80
#else
private typealias Duration = Double
#endif

extension Duration {{
  fileprivate static func seconds(_ n: Int) -> Duration {{
    return Duration(exactly: n)!
  }}

  fileprivate static func / (lhs: Duration, rhs: Int) -> Duration {{
    let r = Duration(exactly: rhs)!
    return lhs / r
  }}
}}

private struct ContinuousClock {{
  fileprivate func measure(_ fn: () -> Void) -> Duration {{
    let start = DispatchTime.now()
    fn()
    let end = DispatchTime.now()
    let nano = end.uptimeNanoseconds - start.uptimeNanoseconds
    let nanoDuration = Duration(exactly: nano)!
    return nanoDuration / 1_000_000_000.0
  }}
}}
#endif // #if swift(<5.7)

private class XCTMetric {{}}
private class XCTClockMetric: XCTMetric {{}}

private struct XCTMeasureOptions {{
  fileprivate static let `default` = XCTMeasureOptions()
}}

extension XCTestCase {{
  fileprivate func measure(
    metrics: [XCTMetric],
    options: XCTMeasureOptions,
    fn: () -> Void
  ) {{
    // Create static values, fill cache, etc.
    fn()

    let clock = ContinuousClock()
    var results = [Duration]()

    for _ in 0..<10 {{
      let elapsed = clock.measure(fn)
      results.append(elapsed)
    }}

    let withoutExtremes = results.sorted().dropFirst().dropLast()
    let totalDuration = withoutExtremes.reduce(Duration.seconds(0), +)
    let averageDuration = totalDuration / withoutExtremes.count
    print("average: \(averageDuration), values: \(results)")
  }}
}}
#endif // #if os(Linux)

class PerformanceTests: XCTestCase {{\
''')

    print_string_parse_tests()
    print_to_string_tests()

    print_equatable_tests()
    print_comparable_tests()

    print_unary_tests('Plus', '+')
    print_unary_tests('Minus', '-')
    print_unary_tests('Invert', '~')

    print_binary_tests('Add', '+')
    print_binary_tests('Sub', '-')
    print_binary_tests('Mul', '*', is_mul=True)
    print_binary_tests('Div', '/', is_div=True)
    print_binary_tests('Mod', '%', is_div=True)
    print_binary_tests('And', '&', is_bit=True)
    print_binary_tests('Or', '|', is_bit=True)
    print_binary_tests('Xor', '^', is_bit=True)

    print_shift_tests('Left', '<<')
    print_shift_tests('Right', '>>')

    print_pi_tests()

    print('}')
    print()
    print('#endif // #if PERFORMANCE_TEST')


if __name__ == '__main__':
    main()
