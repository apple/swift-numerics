//===--- ShiftTests.swift -------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021-2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import IntegerUtilities
import XCTest
import _TestSupport

final class IntegerUtilitiesShiftTests: XCTestCase {
  
  func testRoundingShift<T, C>(
    _ value: T, _ count: C, rounding rule: RoundingRule
  ) where T: FixedWidthInteger, C: BinaryInteger {
    let floor = value >> count
    let lost = value &- floor << count
    let exact = count <= 0 || lost == 0
    let ceiling = exact ? floor : floor &+ 1
    let expected: T
    if exact { expected = floor }
    else {
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
      case .toNearestOrDown:
        let step = value.shifted(rightBy: count - 2, rounding: .toOdd)
        switch step & 0b11 {
        case 0b01: expected = floor
        case 0b10: expected = floor
        case 0b11: expected = ceiling
        default: preconditionFailure()
        }
      case .toNearestOrUp:
        let step = value.shifted(rightBy: count - 2, rounding: .toOdd)
        switch step & 0b11 {
        case 0b01: expected = floor
        case 0b10: expected = ceiling
        case 0b11: expected = ceiling
        default: preconditionFailure()
        }
      case .toNearestOrZero:
        let step = value.shifted(rightBy: count - 2, rounding: .toOdd)
        switch step & 0b11 {
        case 0b01: expected = floor
        case 0b10: expected = value > 0 ? floor : ceiling
        case 0b11: expected = ceiling
        default: preconditionFailure()
        }
      case .toNearestOrAway:
        let step = value.shifted(rightBy: count - 2, rounding: .toOdd)
        switch step & 0b11 {
        case 0b01: expected = floor
        case 0b10: expected = value > 0 ? ceiling : floor
        case 0b11: expected = ceiling
        default: preconditionFailure()
        }
      case .toNearestOrEven:
        let step = value.shifted(rightBy: count - 2, rounding: .toOdd)
        switch step & 0b11 {
        case 0b01: expected = floor
        case 0b10: expected = floor & 1 == 0 ? floor : ceiling
        case 0b11: expected = ceiling
        default: preconditionFailure()
        }
      case .requireExact:
        preconditionFailure()
      }
      let observed = value.shifted(rightBy: count, rounding: rule)
      if observed != expected {
        print("Error found in \(T.self).shifted(rightBy: \(count), rounding: \(rule)).")
        print("   Value: \(String(value, radix: 2))")
        print("Expected: \(String(expected, radix: 2))")
        print("Observed: \(String(observed, radix: 2))")
        XCTFail()
      }
    }
  }
    
    func testRoundingShift<T: FixedWidthInteger>(
      _ type: T.Type, rounding rule: RoundingRule
    ) {
      for count in -2*T.bitWidth ... 2*T.bitWidth {
        // zero shifted by anything is always zero
        XCTAssertEqual(0, (0 as T).shifted(rightBy: count, rounding: rule))
        for _ in 0 ..< 100 {
          testRoundingShift(T.random(in: .min ... .max), count, rounding: rule)
        }
      }
      
      for count in Int8.min ... .max {
        testRoundingShift(T.random(in: .min ... .max), count, rounding: rule)
      }
    }
    
    func testRoundingShifts() {
      testRoundingShift(Int8.self, rounding: .down)
      testRoundingShift(Int8.self, rounding: .up)
      testRoundingShift(Int8.self, rounding: .towardZero)
      testRoundingShift(Int8.self, rounding: .awayFromZero)
      testRoundingShift(Int8.self, rounding: .toNearestOrUp)
      testRoundingShift(Int8.self, rounding: .toNearestOrDown)
      testRoundingShift(Int8.self, rounding: .toNearestOrZero)
      testRoundingShift(Int8.self, rounding: .toNearestOrAway)
      testRoundingShift(Int8.self, rounding: .toNearestOrEven)
      testRoundingShift(Int8.self, rounding: .toOdd)
      
      testRoundingShift(UInt8.self, rounding: .down)
      testRoundingShift(UInt8.self, rounding: .up)
      testRoundingShift(UInt8.self, rounding: .towardZero)
      testRoundingShift(UInt8.self, rounding: .awayFromZero)
      testRoundingShift(UInt8.self, rounding: .toNearestOrUp)
      testRoundingShift(UInt8.self, rounding: .toNearestOrDown)
      testRoundingShift(UInt8.self, rounding: .toNearestOrZero)
      testRoundingShift(UInt8.self, rounding: .toNearestOrAway)
      testRoundingShift(UInt8.self, rounding: .toNearestOrEven)
      testRoundingShift(UInt8.self, rounding: .toOdd)
      
      testRoundingShift(Int.self, rounding: .down)
      testRoundingShift(Int.self, rounding: .up)
      testRoundingShift(Int.self, rounding: .towardZero)
      testRoundingShift(Int.self, rounding: .awayFromZero)
      testRoundingShift(Int.self, rounding: .toNearestOrUp)
      testRoundingShift(Int.self, rounding: .toNearestOrDown)
      testRoundingShift(Int.self, rounding: .toNearestOrZero)
      testRoundingShift(Int.self, rounding: .toNearestOrAway)
      testRoundingShift(Int.self, rounding: .toNearestOrEven)
      testRoundingShift(Int.self, rounding: .toOdd)
      
      testRoundingShift(UInt.self, rounding: .down)
      testRoundingShift(UInt.self, rounding: .up)
      testRoundingShift(UInt.self, rounding: .towardZero)
      testRoundingShift(UInt.self, rounding: .awayFromZero)
      testRoundingShift(UInt.self, rounding: .toNearestOrUp)
      testRoundingShift(UInt.self, rounding: .toNearestOrDown)
      testRoundingShift(UInt.self, rounding: .toNearestOrZero)
      testRoundingShift(UInt.self, rounding: .toNearestOrAway)
      testRoundingShift(UInt.self, rounding: .toNearestOrEven)
      testRoundingShift(UInt.self, rounding: .toOdd)
    }
  }
