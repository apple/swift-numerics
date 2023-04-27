//===--- SaturatingArithmeticTests.swift ----------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import IntegerUtilities
import XCTest
import _TestSupport

final class IntegerUtilitiesSaturatingTests: XCTestCase {
  
  func testSaturatingAddSigned() {
    for a in Int8.min ... Int8.max {
      for b in Int8.min ... Int8.max {
        let expected = Int8(clamping: Int16(a) + Int16(b))
        let observed = a.addingWithSaturation(b)
        if expected != observed {
          print("Error found in (\(a)).addingWithSaturation(\(b)).")
          print("Expected: \(String(expected, radix: 16))")
          print("Observed: \(String(observed, radix: 16))")
          XCTFail()
          return
        }
      }
    }
  }
  
  func testSaturatingSubtractSigned() {
    for a in Int8.min ... Int8.max {
      for b in Int8.min ... Int8.max {
        let expected = Int8(clamping: Int16(a) - Int16(b))
        let observed = a.subtractingWithSaturation(b)
        if expected != observed {
          print("Error found in (\(a)).subtractingWithSaturation(\(b)).")
          print("Expected: \(String(expected, radix: 16))")
          print("Observed: \(String(observed, radix: 16))")
          XCTFail()
          return
        }
      }
    }
  }
  
  func testSaturatingNegation() {
    for a in Int8.min ... Int8.max {
      let expected = Int8(clamping: 0 - Int16(a))
      let observed = a.negatedWithSaturation()
      if expected != observed {
        print("Error found in (\(a)).negatedWithSaturation().")
        print("Expected: \(String(expected, radix: 16))")
        print("Observed: \(String(observed, radix: 16))")
        XCTFail()
        return
      }
    }
  }
  
  func testSaturatingMultiplicationSigned() {
    for a in Int8.min ... Int8.max {
      for b in Int8.min ... Int8.max {
        let expected = Int8(clamping: Int16(a) * Int16(b))
        let observed = a.multipliedWithSaturation(by: b)
        if expected != observed {
          print("Error found in (\(a)).multipliedWithSaturation(by: \(b)).")
          print("Expected: \(String(expected, radix: 16))")
          print("Observed: \(String(observed, radix: 16))")
          XCTFail()
          return
        }
      }
    }
  }
  
  func testSaturatingAddUnsigned() {
    for a in UInt8.min ... UInt8.max {
      for b in UInt8.min ... UInt8.max {
        let expected = UInt8(clamping: UInt16(a) + UInt16(b))
        let observed = a.addingWithSaturation(b)
        if expected != observed {
          print("Error found in (\(a)).addingWithSaturation(\(b)).")
          print("Expected: \(String(expected, radix: 16))")
          print("Observed: \(String(observed, radix: 16))")
          XCTFail()
          return
        }
      }
    }
  }
  
  func testSaturatingSubtractUnsigned() {
    for a in UInt8.min ... UInt8.max {
      for b in UInt8.min ... UInt8.max {
        let expected = UInt8(clamping: Int16(a) - Int16(b))
        let observed = a.subtractingWithSaturation(b)
        if expected != observed {
          print("Error found in (\(a)).subtractingWithSaturation(\(b)).")
          print("Expected: \(String(expected, radix: 16))")
          print("Observed: \(String(observed, radix: 16))")
          XCTFail()
          return
        }
      }
    }
  }
  
  func testSaturatingMultiplicationUnsigned() {
    for a in UInt8.min ... UInt8.max {
      for b in UInt8.min ... UInt8.max {
        let expected = UInt8(clamping: UInt16(a) * UInt16(b))
        let observed = a.multipliedWithSaturation(by: b)
        if expected != observed {
          print("Error found in (\(a)).multipliedWithSaturation(by: \(b)).")
          print("Expected: \(String(expected, radix: 16))")
          print("Observed: \(String(observed, radix: 16))")
          XCTFail()
        }
      }
    }
  }
  
  func testSaturatingShift<T, C>(
    _ value: T, _ count: C, rounding rule: RoundingRule
  ) where T: FixedWidthInteger, C: FixedWidthInteger {
    let observed = value.shiftedWithSaturation(leftBy: count, rounding: rule)
    var expected: T = 0
    if count <= 0 {
      expected = value.shifted(rightBy: -Int64(count), rounding: rule)
    } else {
      let multiplier: T = 1 << count
      if multiplier <= 0 {
        expected = value == 0 ? 0 :
        value  < 0 ? .min : .max
      } else {
        expected = value.multipliedWithSaturation(by: multiplier)
      }
    }
    if observed != expected {
      print("Error found in \(T.self).shiftedWithSaturation(leftBy: \(count), rounding: \(rule)).")
      print("   Value: \(String(value, radix: 16))")
      print("Expected: \(String(expected, radix: 16))")
      print("Observed: \(String(observed, radix: 16))")
      XCTFail()
      return
    }
  }
  
  func testSaturatingShift<T: FixedWidthInteger>(
    _ type: T.Type, rounding rule: RoundingRule
  ) {
    for count in Int8.min ... .max {
      testSaturatingShift(0, count, rounding: rule)
      for bits in 0 ..< T.bitWidth {
        let msb: T.Magnitude = 1 << bits
        let value = T(truncatingIfNeeded: msb) | .random(in: 0 ... T(msb-1))
        testSaturatingShift(value, count, rounding: rule)
        testSaturatingShift(0 &- value, count, rounding: rule)
      }
    }
  }
  
  func testSaturatingShifts() {
    testSaturatingShift(Int8.self, rounding: .toOdd)
    testSaturatingShift(UInt8.self, rounding: .toOdd)
    testSaturatingShift(Int.self, rounding: .toOdd)
    testSaturatingShift(UInt.self, rounding: .toOdd)
  }
  
  func testEdgeCaseForNegativeCount() {
    XCTAssertEqual(1.shiftedWithSaturation(leftBy: Int.min), 0)
  }
  
}
