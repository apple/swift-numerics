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

INT_COUNT = 400
BIG_COUNT = 400
BIG_STRING_COUNT = 5000

def print_string_parse_tests():
  print()
  print('  // MARK: - From String')

  for radix in (10, 16):
    print(f'''
  func test_fromString_radix{radix}() {{
    let strings = bigsForString.map {{ String($0, radix: {radix}, uppercase: false) }}

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

  for radix in (10, 16):
    print(f'''
  func test_toString_radix{radix}() {{
    self.measure(metrics: metrics, options: options) {{
      for n in bigsForString {{
        _ = String(n, radix: {radix}, uppercase: false)
      }}
    }}
  }}\
''')

def print_unary_tests(name: str, operator: str):
    name_lower = name.lower()
    print(f'''
  // MARK: - {name}

  func test_{name_lower}_int() {{
    self.measure(metrics: metrics, options: options) {{
      for n in ints {{
        _ = {operator}n
      }}
    }}
  }}

  func test_{name_lower}_big() {{
    self.measure(metrics: metrics, options: options) {{
      for n in bigs {{
        _ = {operator}n
      }}
    }}
  }}\
''')

def print_binary_tests(name: str, operator: str, is_div: bool = False):
    name_lower = name.lower()
    avoid_div_0_int = '\n        if int == 0 { continue }' if is_div else ''
    avoid_div_0_big = '\n        if rhs == 0 { continue }' if is_div else ''

    print(f'''
  // MARK: - {name}

  func test_{name_lower}_int() {{
    self.measure(metrics: metrics, options: options) {{
      for (int, big) in intBig {{{avoid_div_0_int}
        _ = big {operator} int
      }}
    }}
  }}

  func test_{name_lower}_int_inout() {{
    self.measure(metrics: metrics, options: options) {{
      for (int, big) in intBig {{{avoid_div_0_int}
        var copy = big
        copy {operator}= int
      }}
    }}
  }}

  func test_{name_lower}_big() {{
    self.measure(metrics: metrics, options: options) {{
      for (lhs, rhs) in bigBig {{{avoid_div_0_big}
        _ = lhs {operator} rhs
      }}
    }}
  }}

  func test_{name_lower}_big_inout() {{
    self.measure(metrics: metrics, options: options) {{
      for (lhs, rhs) in bigBig {{{avoid_div_0_big}
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
      for n in ints {{
        for shift in shifts {{
          _ = n {operator} shift
        }}
      }}
    }}
  }}

  func test_shift{direction}_int_inout() {{
    self.measure(metrics: metrics, options: options) {{
      for n in ints {{
        for shift in shifts {{
          var copy = n
          copy {operator}= shift
        }}
      }}
    }}
  }}

  func test_shift{direction}_big() {{
    self.measure(metrics: metrics, options: options) {{
      for n in bigs {{
        for shift in shifts {{
          _ = n {operator} shift
        }}
      }}
    }}
  }}

  func test_shift{direction}_big_inout() {{
    self.measure(metrics: metrics, options: options) {{
      for n in bigs {{
        for shift in shifts {{
          var copy = n
          copy {operator}= shift
        }}
      }}
    }}
  }}\
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
@testable import BigIntModule

private let ints = generateInts(approximateCount: {INT_COUNT}).map(BigInt.init)
private let bigs = generateBigInts(approximateCount: {BIG_COUNT}, maxWordCount: 20).map {{ $0.create() }}
private let bigsForString = generateBigInts(approximateCount: {BIG_STRING_COUNT}, maxWordCount: 20).map {{ $0.create() }}
private let shifts = [0, 7, 61, 67, 127] // Primes, but that does not matter

private let intBig = CartesianProduct(ints, bigs)
private let bigBig = CartesianProduct(bigs, bigs)

private let metrics: [XCTMetric] = [XCTClockMetric()] // XCTMemoryMetric()?
private let options = XCTMeasureOptions.default

class PerformanceTests: XCTestCase {{\
''')

    print_string_parse_tests()
    print_to_string_tests()

    print_unary_tests('Plus', '+')
    print_unary_tests('Minus', '-')

    print_binary_tests('Add', '+'),
    print_binary_tests('Sub', '-'),
    print_binary_tests('Mul', '*'),
    print_binary_tests('Div', '/', True),
    print_binary_tests('Mod', '%', True),

    print_shift_tests('Left', '<<')
    print_shift_tests('Right', '>>')

    print('}')

if __name__ == '__main__':
    main()
