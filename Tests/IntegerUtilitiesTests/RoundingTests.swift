//===--- RoundingTests.swift ----------------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import IntegerUtilities
import XCTest

final class RoundingTests: XCTestCase {
  
  func testRoundingShift<T: FixedWidthInteger>(
    _ value: T, _ count: Int, rounding rule: RoundingRule
  ) {
    let floor = value >> count
    let frac = value &- floor << count
    let exact = count <= 0 || frac == 0
    let ceiling = exact ? floor : floor &+ 1
    let expected: T
    switch rule {
    case .down:
      expected = floor
    case .up:
      expected = ceiling
    case .towardZero:
      expected = value < 0 ? ceiling : floor
    case .awayFromZero:
      expected = value > 0 ? ceiling : floor
    case .toOdd:
      expected = floor | (exact ? 0 : 1)
    case .toNearestOrAwayFromZero:
      if exact { expected = floor }
      else {
        let step = value.shifted(right: count - 2, rounding: .toOdd)
        switch step & 0b11 {
        case 0b01: expected = floor
        case 0b10: expected = value > 0 ? ceiling : floor
        case 0b11: expected = ceiling
        default: preconditionFailure()
        }
      }
    case .toNearestOrEven:
      if exact { expected = floor }
      else {
        let step = value.shifted(right: count - 2, rounding: .toOdd)
        switch step & 0b11 {
        case 0b01: expected = floor
        case 0b10: expected = floor & 1 == 0 ? floor : ceiling
        case 0b11: expected = ceiling
        default: preconditionFailure()
        }
      }
    case .stochastic:
      // Just test that it's floor if exact, otherwise either floor
      // or ceiling.
      if exact { expected = floor }
      else {
        let observed = value.shifted(right: count, rounding: rule)
        if observed != floor && observed != ceiling {
          print("Error found in \(T.self).shifted(right: \(count), rounding: \(rule)).")
          print("   Value: \(String(value, radix: 16))")
          print("Expected: \(String(floor, radix: 16)) or \(String(ceiling, radix: 16))")
          print("Observed: \(String(observed, radix: 16))")
          XCTFail()
        }
        return
      }
    case .trap:
      preconditionFailure()
    }
    let observed = value.shifted(right: count, rounding: rule)
    if observed != expected {
      print("Error found in \(T.self).shifted(right: \(count), rounding: \(rule)).")
      print("   Value: \(String(value, radix: 16))")
      print("Expected: \(String(expected, radix: 16))")
      print("Observed: \(String(observed, radix: 16))")
      XCTFail()
    }
  }
  
  func testRoundingShift<T: FixedWidthInteger>(
    _ type: T.Type, rounding rule: RoundingRule
  ) {
    for count in -2*T.bitWidth ... 2*T.bitWidth {
      // zero shifted by anything is always zero
      XCTAssertEqual(0, (0 as T).shifted(right: count, rounding: rule))
      for _ in 0 ..< 100 {
        testRoundingShift(T.random(in: .min ... .max), count, rounding: rule)
      }
    }
  }
  
  func testRoundingShift() {
    testRoundingShift(Int8.self, rounding: .down)
    testRoundingShift(Int8.self, rounding: .up)
    testRoundingShift(Int8.self, rounding: .towardZero)
    testRoundingShift(Int8.self, rounding: .awayFromZero)
    testRoundingShift(Int8.self, rounding: .toOdd)
    testRoundingShift(Int8.self, rounding: .toNearestOrAwayFromZero)
    testRoundingShift(Int8.self, rounding: .toNearestOrEven)
    testRoundingShift(Int8.self, rounding: .stochastic)
    
    testRoundingShift(UInt8.self, rounding: .down)
    testRoundingShift(UInt8.self, rounding: .up)
    testRoundingShift(UInt8.self, rounding: .towardZero)
    testRoundingShift(UInt8.self, rounding: .awayFromZero)
    testRoundingShift(UInt8.self, rounding: .toOdd)
    testRoundingShift(UInt8.self, rounding: .toNearestOrAwayFromZero)
    testRoundingShift(UInt8.self, rounding: .toNearestOrEven)
    testRoundingShift(UInt8.self, rounding: .stochastic)
    
    testRoundingShift(Int.self, rounding: .down)
    testRoundingShift(Int.self, rounding: .up)
    testRoundingShift(Int.self, rounding: .towardZero)
    testRoundingShift(Int.self, rounding: .awayFromZero)
    testRoundingShift(Int.self, rounding: .toOdd)
    testRoundingShift(Int.self, rounding: .toNearestOrAwayFromZero)
    testRoundingShift(Int.self, rounding: .toNearestOrEven)
    testRoundingShift(Int.self, rounding: .stochastic)
    
    testRoundingShift(UInt.self, rounding: .down)
    testRoundingShift(UInt.self, rounding: .up)
    testRoundingShift(UInt.self, rounding: .towardZero)
    testRoundingShift(UInt.self, rounding: .awayFromZero)
    testRoundingShift(UInt.self, rounding: .toOdd)
    testRoundingShift(UInt.self, rounding: .toNearestOrAwayFromZero)
    testRoundingShift(UInt.self, rounding: .toNearestOrEven)
    testRoundingShift(UInt.self, rounding: .stochastic)
  }
}
