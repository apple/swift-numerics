//===--- DivideTests.swift ------------------------------------*- swift -*-===//
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

final class IntegerUtilitiesDivideTests: XCTestCase {
  
  func divisionRuleHolds<T: BinaryInteger>(_ a: T, _ b: T, _ q: T, _ r: T) -> Bool {
    // Validate division rule holds: a = qb + r (have to be careful about
    // computing qb, though, to ensure it does not overflow due to
    // rounding of q; compute it in two pieces, subtracting the first from
    // a to avoid intermediate overflow).
    let b1 = b >> 1
    let b2 = b - b1
    let ref = a - q*b1 - q*b2
    if r != ref {
      XCTFail("""
      \(a).divided(by: \(b), rounding: .down) failed the division rule.
      a - qb was \(ref), but r is \(r).
      """)
      return false
    }
    if r.magnitude >= b.magnitude {
      XCTFail("""
      \(a).divided(by: \(b), rounding: .down) failed check on r.
      |remainder| must be smaller than |divisor|, but was \(r).
      """)
      return false
    }
    return true
  }
  
  func testDivideDown<T: SignedInteger & FixedWidthInteger>(_ values: [T]) {
    for a in values {
      for b in values where b != 0 {
        // Skip any SignedInt.min / -1 cases, because those will trap.
        if a == .min && b == -1 { continue }
        let (q, r) = a.divided(by: b, rounding: .down)
        if divisionRuleHolds(a, b, q, r) {
          // We know a = bq + r with |r| < |b|. Now validate sign(r) == sign(b).
          guard r == 0 || r.signum() == b.signum() else {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .down) failed check on r.
            remainder must match sign of divisor, but was \(r).
            """)
            return
          }
        }
      }
    }
  }
  
  func testDivideUp<T: SignedInteger & FixedWidthInteger>(_ values: [T]) {
    for a in values {
      for b in values where b != 0 {
        // Skip any SignedInt.min / -1 cases, because those will trap.
        if a == .min && b == -1 { continue }
        let (q, r) = a.divided(by: b, rounding: .up)
        if divisionRuleHolds(a, b, q, r) {
          // We know a = bq + r with |r| < |b|. Now validate sign(r) != sign(b).
          guard r == 0 || r.signum() != b.signum() else {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .up) failed check on r.
            remainder must oppose sign of divisor, but was \(r).
            """)
            return
          }
        }
      }
    }
  }
  
  func testDivideTowardZero<T: SignedInteger & FixedWidthInteger>(_ values: [T]) {
    for a in values {
      for b in values where b != 0 {
        // Skip any SignedInt.min / -1 cases, because those will trap.
        if a == .min && b == -1 { continue }
        let (q, r) = a.divided(by: b, rounding: .towardZero)
        if divisionRuleHolds(a, b, q, r) {
          // We know a = bq + r with |r| < |b|. Now validate sign(r) == sign(a).
          guard r == 0 || r.signum() == a.signum() else {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .towardZero) failed check on r.
            remainder must match sign of dividend, but was \(r).
            """)
            return
          }
        }
      }
    }
  }
  
  func testDivideAwayFromZero<T: SignedInteger & FixedWidthInteger>(_ values: [T]) {
    for a in values {
      for b in values where b != 0 {
        // Skip any SignedInt.min / -1 cases, because those will trap.
        if a == .min && b == -1 { continue }
        let (q, r) = a.divided(by: b, rounding: .awayFromZero)
        if divisionRuleHolds(a, b, q, r) {
          // We know a = bq + r with |r| < |b|. Now validate sign(r) != sign(a).
          guard r == 0 || r.signum() != a.signum() else {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .awayFromZero) failed check on r.
            remainder must oppose sign of dividend, but was \(r).
            """)
            return
          }
        }
      }
    }
  }
  
  func testDivideToOdd<T: SignedInteger & FixedWidthInteger>(_ values: [T]) {
    for a in values {
      for b in values where b != 0 {
        // Skip any SignedInt.min / -1 cases, because those will trap.
        if a == .min && b == -1 { continue }
        let (q, r) = a.divided(by: b, rounding: .toOdd)
        if divisionRuleHolds(a, b, q, r) {
          // We know a = bq + r with |r| < |b|. Now validate q is odd if r is
          // non-zero.
          guard r == 0 || q & 1 == 1 else {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .toOdd) failed check:
            quotient must be odd if remainder is non-zero, but quotient was \(q) and remainder was \(r).
            """)
            return
          }
        }
      }
    }
  }
  
  func testDivideToNearestOrAway<T: SignedInteger & FixedWidthInteger>(_ values: [T]) {
    for a in values {
      for b in values where b != 0 {
        // Skip any SignedInt.min / -1 cases, because those will trap.
        if a == .min && b == -1 { continue }
        let (q, r) = a.divided(by: b, rounding: .toNearestOrAwayFromZero)
        if divisionRuleHolds(a, b, q, r) {
          // We know a = bq + r with |r| < |b|. Now check |r| <= |b|/2
          // with equality only if sign(r) != sign(a).
          if 2*r.magnitude > b.magnitude {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .toNearestOrAwayFromZero) failed check:
            |remainder| must be less than or equal to |divisor|/2, but remainder was \(r).
            """)
            return
          }
          if 2*r.magnitude == b.magnitude && r.signum() == a.signum() {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .toNearestOrAwayFromZero) failed check:
            If |remainder| equals |divisor|/2, remainder must oppose sign of dividend, but was \(r).
            """)
            return
          }
        }
      }
    }
  }
  
  func testDivideToNearestOrEven<T: SignedInteger & FixedWidthInteger>(_ values: [T]) {
    for a in values {
      for b in values where b != 0 {
        // Skip any SignedInt.min / -1 cases, because those will trap.
        if a == .min && b == -1 { continue }
        let (q, r) = a.divided(by: b, rounding: .toNearestOrEven)
        if divisionRuleHolds(a, b, q, r) {
          // We know a = bq + r with |r| < |b|. Now check |r| <= |b|/2
          // with equality only if sign(r) != sign(a).
          if 2*r.magnitude > b.magnitude {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .toNearestOrEven) failed check:
            |remainder| must be less than or equal to |divisor|/2, but remainder was \(r).
            """)
            return
          }
          if 2*r.magnitude == b.magnitude && q & 1 == 1 {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .toNearestOrEven) failed check:
            If |remainder| equals |divisor|/2, quotient must be even, but quotient was \(q) and remainder was \(r).
            """)
            return
          }
        }
      }
    }
  }
  
  func testDivideStochastic<T: SignedInteger & FixedWidthInteger>(_ values: [T]) {
    for a in values {
      for b in values where b != 0 {
        // Skip any SignedInt.min / -1 cases, because those will trap.
        if a == .min && b == -1 { continue }
        let (q, r) = a.divided(by: b, rounding: .stochastically)
        let _ = divisionRuleHolds(a, b, q, r)
      }
    }
  }
  
  func testDivideExact<T: SignedInteger & FixedWidthInteger>(_ values: [T]) {
    for a in values {
      for b in values where b != 0 {
        // Skip any SignedInt.min / -1 cases, because those will trap.
        if a == .min && b == -1 { continue }
        // Skip any cases with a remainder (most of them!)
        if a % b != 0 { continue }
        // Test that division rule holds ignoring r for the cases that
        // make it through.
        let (q, _) = a.divided(by: b, rounding: .requireExact)
        let _ = divisionRuleHolds(a, b, q, 0)
      }
    }
  }
  
  func testDivideInt8() {
    let values = Array<Int8>(-128 ... 127)
    testDivideDown(values)
    testDivideUp(values)
    testDivideTowardZero(values)
    testDivideAwayFromZero(values)
    testDivideToOdd(values)
    testDivideToNearestOrAway(values)
    testDivideToNearestOrEven(values)
    testDivideStochastic(values)
    testDivideExact(values)
  }
  
  func testDivideInt() {
    var values = [Int](repeating: 0, count: 64)
    for i in 0 ..< values.count {
      while values[i] == 0 {
        values[i] = .random(in: .min ... .max)
      }
    }
    testDivideDown(values)
    testDivideUp(values)
    testDivideTowardZero(values)
    testDivideAwayFromZero(values)
    testDivideToOdd(values)
    testDivideToNearestOrAway(values)
    testDivideToNearestOrEven(values)
    testDivideStochastic(values)
    testDivideExact(values)
  }
  
  func divideUInt8(_ a: UInt8, _ b: UInt8, rounding rule: RoundingRule) {
    let expected = UInt8(Int16(a).divided(by: Int16(b), rounding: rule).quotient)
    let observed = a.divided(by: b, rounding: rule)
    guard expected == observed else {
      XCTFail("""
      \(a).divided(by: \(b), rounding: \(rule)) did not match expected result:
      Computed with Int16: \(expected)
      Computed with UInt8: \(observed)
      """)
      return
    }
  }
  
  func testDivideUInt8() {
    let values = Array<UInt8>(0 ... 255)
    for a in values {
      for b in values where b != 0 {
        divideUInt8(a, b, rounding: .down)
        divideUInt8(a, b, rounding: .up)
        divideUInt8(a, b, rounding: .towardZero)
        divideUInt8(a, b, rounding: .awayFromZero)
        divideUInt8(a, b, rounding: .toOdd)
        divideUInt8(a, b, rounding: .toNearestOrAwayFromZero)
        divideUInt8(a, b, rounding: .toNearestOrEven)
      }
    }
  }
  
  // stochastically rounding doesn't have a deterministic "expected" answer,
  // but we know that the result must be either the floor or the ceiling.
  // The above tests ensure that, but that's not a very strong guarantee;
  // an implementation could just implement it as self / other and pass
  // that test.
  //
  // Here we round the _same_ value many times, compute the average, and
  // check that it is acceptably close to the exact expected value; simple
  // use of any deterministic rounding rule will not achieve this.
  func testStochasticDivide<T: FixedWidthInteger>(_ a: T, _ b: T) -> Bool {
    let sum = (0..<1024).reduce(into: 0.0) { sum, _ in
      let rounded = a.divided(by: b, rounding: .stochastically)
      sum += Double(rounded)
    }
    let expected = 1024 * Double(a) / Double(b)
    let difference = abs(sum - expected)
    // Waving my hands slightly instead of giving a precise explanation
    // here, the expectation is that difference should be about
    // 1/2 sqrt(1024). If we're more than a couple standard deviations
    // off, we should flag that. This isn't _necessarily_ a problem,
    // but if you see a repeated failure, that's almost surely a real bug.
    //
    // TODO: precise justification of thresholds
    XCTAssertLessThanOrEqual(difference, 64,
                             "Accumulated error (\(difference)) was unexpectedly large in \(a).divided(by: \(b))"
    )
    return difference > 16
  }
  
  func testDivideStochasticInt8() {
    var values = [Int8](repeating: 0, count: 32)
    for i in 0 ..< values.count {
      while values[i] == 0 {
        values[i] = .random(in: .min ... .max)
      }
    }
    var fails = 0
    for a in values {
      for b in values {
        if a == .min && b == -1 { continue }
        fails += testStochasticDivide(a, b) ? 1 : 0
      }
    }
    XCTAssertLessThanOrEqual(fails, 32*16)
  }
  
  func testDivideStochasticUInt32() {
    var values = [UInt32](repeating: 0, count: 32)
    for i in 0 ..< values.count {
      while values[i] == 0 {
        values[i] = .random(in: .min ... .max)
      }
    }
    var fails = 0
    for a in values {
      for b in values {
        fails += testStochasticDivide(a, b) ? 1 : 0
      }
    }
    XCTAssertLessThanOrEqual(fails, 32*16)
  }
  
  func testRemainderByMinusOne() {
    // These would trap if implemented as a - bq or similar, even though
    // the remainder is well-defined.
    XCTAssertEqual(0, Int.min.remainder(dividingBy: -1))
    XCTAssertEqual(0, Int.min.remainder(dividingBy: -1, rounding: .up))
    XCTAssertEqual(0, Int.min.remainder(dividingBy: -1, rounding: .stochastically))
  }
}
