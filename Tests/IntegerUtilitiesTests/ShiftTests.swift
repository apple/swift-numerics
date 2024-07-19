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
      case .stochastically:
        // Just test that it's floor if exact, otherwise either floor
        // or ceiling.
        let observed = value.shifted(rightBy: count, rounding: rule)
        if observed != floor && observed != ceiling {
          print("Error found in \(T.self).shifted(rightBy: \(count), rounding: \(rule)).")
          print("   Value: \(String(value, radix: 2))")
          print("Expected: \(String(floor, radix: 2)) or \(String(ceiling, radix: 2))")
          print("Observed: \(String(observed, radix: 2))")
          XCTFail()
        }
        return
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
      testRoundingShift(Int8.self, rounding: .stochastically)
      
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
      testRoundingShift(UInt8.self, rounding: .stochastically)
      
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
      testRoundingShift(Int.self, rounding: .stochastically)
      
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
      testRoundingShift(UInt.self, rounding: .stochastically)
      
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        testRoundingShift(Int128.self, rounding: .down)
        testRoundingShift(Int128.self, rounding: .up)
        testRoundingShift(Int128.self, rounding: .towardZero)
        testRoundingShift(Int128.self, rounding: .awayFromZero)
        testRoundingShift(Int128.self, rounding: .toNearestOrUp)
        testRoundingShift(Int128.self, rounding: .toNearestOrDown)
        testRoundingShift(Int128.self, rounding: .toNearestOrZero)
        testRoundingShift(Int128.self, rounding: .toNearestOrAway)
        testRoundingShift(Int128.self, rounding: .toNearestOrEven)
        testRoundingShift(Int128.self, rounding: .toOdd)
        testRoundingShift(Int128.self, rounding: .stochastically)
        
        testRoundingShift(UInt128.self, rounding: .down)
        testRoundingShift(UInt128.self, rounding: .up)
        testRoundingShift(UInt128.self, rounding: .towardZero)
        testRoundingShift(UInt128.self, rounding: .awayFromZero)
        testRoundingShift(UInt128.self, rounding: .toNearestOrUp)
        testRoundingShift(UInt128.self, rounding: .toNearestOrDown)
        testRoundingShift(UInt128.self, rounding: .toNearestOrZero)
        testRoundingShift(UInt128.self, rounding: .toNearestOrAway)
        testRoundingShift(UInt128.self, rounding: .toNearestOrEven)
        testRoundingShift(UInt128.self, rounding: .toOdd)
        testRoundingShift(UInt128.self, rounding: .stochastically)
      }
    }
    
    // Stochastic rounding doesn't have a deterministic "expected" answer,
    // but we know that the result must be either the floor or the ceiling.
    // The above tests ensure that, but that's not a very strong guarantee;
    // an implementation could just implement it as self >> count and pass
    // that test.
    //
    // Here we round the _same_ value many times, compute the average, and
    // check that it is acceptably close to the exact expected value; simple
    // use of any deterministic rounding rule will not achieve this.
    func testStochasticAverage<T: FixedWidthInteger>(_ value: T) {
      var fails = 0
      for count in 1 ... T.bitWidth {
        let sum = (0..<256).reduce(into: DoubleWidth<T>.zero) { sum, _ in
          let rounded = value.shifted(rightBy: count, rounding: .stochastically)
          sum += DoubleWidth(rounded)
        }
        let expected = DoubleWidth<T>(value) << (8 - count)
        let difference = sum >= expected ? sum - expected : expected - sum
        // Waving my hands slightly instead of giving a precise explanation
        // here, the expectation is that difference should be about
        // 1/2 sqrt(256). If it's repeatedly bigger than that, we _may_
        // have a problem, but it's OK for this to fail occasionally.
        //
        // TODO: precise justification of thresholds
        if difference > 8 { fails += 1 }
        // On the other hand, if we're more than a couple standard deviations
        // off, we should flag that. This still isn't _necessarily_ a problem,
        // but if you see a repeated failure for a given shift count, that's
        // almost surely a real bug.
        XCTAssertLessThanOrEqual(difference, 32,
                                 "Accumulated error (\(difference)) was unexpectedly large in \(value).shifted(rightBy: \(count))"
        )
      }
      // Threshold chosen so that this is expected to _usually_ pass, but
      // it will fail sporadically even with a correct implementation. This is
      // not a great fit for CI workflows, sorry. Basically ignore one-off
      // failures, but a repeated failure here is an indication that a bug
      // exists.
      XCTAssertLessThanOrEqual(fails, T.bitWidth/2,
                               "Accumulated error was large more often than expected for \(value).shifted(rightBy:)"
      )
    }
    
    func testStochasticShifts() {
      testStochasticAverage(Int8.random(in: .min ... .max))
      testStochasticAverage(Int16.random(in: .min ... .max))
      testStochasticAverage(Int32.random(in: .min ... .max))
      testStochasticAverage(UInt8.random(in: .min ... .max))
      testStochasticAverage(UInt16.random(in: .min ... .max))
      testStochasticAverage(UInt32.random(in: .min ... .max))
      testStochasticAverage(Int64.random(in: .min ... .max))
      testStochasticAverage(UInt64.random(in: .min ... .max))
      if #available(macOS 15, iOS 18, tvOS 18, watchOS 11, visionOS 2, *) {
        testStochasticAverage(Int128.random(in: .min ... .max))
        testStochasticAverage(UInt128.random(in: .min ... .max))
      }
      testStochasticAverage(DoubleWidth<Int64>.random(in: .min ... .max))
      testStochasticAverage(DoubleWidth<UInt64>.random(in: .min ... .max))
    }
  }
