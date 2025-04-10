//===--- DivideTests.swift ------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import IntegerUtilities
import _TestSupport
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
      \(a).divided(by: \(b)) failed the division rule.
      a - qb was \(ref), but r is \(r).
      """)
      return false
    }
    if r.magnitude >= b.magnitude {
      XCTFail("""
      \(a).divided(by: \(b)) failed check on r.
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
        let justq = a.divided(by: b, rounding: .down)
        if q != justq {
          XCTFail("""
          \(a).divided(by: \(b), rounding: .down) failed check:
          BinaryInteger overload did not produce the same quotient as SignedInteger.
          BinaryInteger result was \(justq), but SignedInteger was \(q).
          """)
          return
        }
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
        let justq = a.divided(by: b, rounding: .up)
        if q != justq {
          XCTFail("""
          \(a).divided(by: \(b), rounding: .up) failed check:
          BinaryInteger overload did not produce the same quotient as SignedInteger.
          BinaryInteger result was \(justq), but SignedInteger was \(q).
          """)
          return
        }
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
        let justq = a.divided(by: b, rounding: .towardZero)
        if q != justq {
          XCTFail("""
          \(a).divided(by: \(b), rounding: .towardZero) failed check:
          BinaryInteger overload did not produce the same quotient as SignedInteger.
          BinaryInteger result was \(justq), but SignedInteger was \(q).
          """)
          return
        }
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
        let justq = a.divided(by: b, rounding: .awayFromZero)
        if q != justq {
          XCTFail("""
          \(a).divided(by: \(b), rounding: .awayFromZero) failed check:
          BinaryInteger overload did not produce the same quotient as SignedInteger.
          BinaryInteger result was \(justq), but SignedInteger was \(q).
          """)
          return
        }
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
  
  func testDivideToNearestOrDown<T: SignedInteger & FixedWidthInteger>(_ values: [T]) {
    for a in values {
      for b in values where b != 0 {
        // Skip any SignedInt.min / -1 cases, because those will trap.
        if a == .min && b == -1 { continue }
        let (q, r) = a.divided(by: b, rounding: .toNearestOrDown)
        let justq = a.divided(by: b, rounding: .toNearestOrDown)
        if q != justq {
          XCTFail("""
          \(a).divided(by: \(b), rounding: .toNearestOrDown) failed check:
          BinaryInteger overload did not produce the same quotient as SignedInteger.
          BinaryInteger result was \(justq), but SignedInteger was \(q).
          """)
          return
        }
        
        XCTAssertEqual(q, justq)
        if divisionRuleHolds(a, b, q, r) {
          // We know a = bq + r with |r| < |b|. Now check |r| <= |b|/2
          // with equality only if q rounded down.
          if 2*r.magnitude > b.magnitude {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .toNearestOrDown) failed check:
            |remainder| must be less than or equal to |divisor|/2, but remainder was \(r).
            """)
            return
          }
          if 2*r.magnitude == b.magnitude && r.signum() != b.signum() {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .toNearestOrDown) failed check:
            If |remainder| equals |divisor|/2, remainder must have same sign as divisor, but was \(r).
            """)
            return
          }
        }
      }
    }
  }
  
  func testDivideToNearestOrUp<T: SignedInteger & FixedWidthInteger>(_ values: [T]) {
    for a in values {
      for b in values where b != 0 {
        // Skip any SignedInt.min / -1 cases, because those will trap.
        if a == .min && b == -1 { continue }
        let (q, r) = a.divided(by: b, rounding: .toNearestOrUp)
        let justq = a.divided(by: b, rounding: .toNearestOrUp)
        if q != justq {
          XCTFail("""
          \(a).divided(by: \(b), rounding: .toNearestOrUp) failed check:
          BinaryInteger overload did not produce the same quotient as SignedInteger.
          BinaryInteger result was \(justq), but SignedInteger was \(q).
          """)
          return
        }
        if divisionRuleHolds(a, b, q, r) {
          // We know a = bq + r with |r| < |b|. Now check |r| <= |b|/2
          // with equality only if q rounded up.
          if 2*r.magnitude > b.magnitude {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .toNearestOrUp) failed check:
            |remainder| must be less than or equal to |divisor|/2, but remainder was \(r).
            """)
            return
          }
          if 2*r.magnitude == b.magnitude && r.signum() == b.signum() {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .toNearestOrUp) failed check:
            If |remainder| equals |divisor|/2, remainder must have opposite sign of divisor, but was \(r).
            """)
            return
          }
        }
      }
    }
  }
  
  func testDivideToNearestOrZero<T: SignedInteger & FixedWidthInteger>(_ values: [T]) {
    for a in values {
      for b in values where b != 0 {
        // Skip any SignedInt.min / -1 cases, because those will trap.
        if a == .min && b == -1 { continue }
        let (q, r) = a.divided(by: b, rounding: .toNearestOrZero)
        let justq = a.divided(by: b, rounding: .toNearestOrZero)
        if q != justq {
          XCTFail("""
          \(a).divided(by: \(b), rounding: .toNearestOrZero) failed check:
          BinaryInteger overload did not produce the same quotient as SignedInteger.
          BinaryInteger result was \(justq), but SignedInteger was \(q).
          """)
          return
        }
        if divisionRuleHolds(a, b, q, r) {
          // We know a = bq + r with |r| < |b|. Now check |r| <= |b|/2
          // with equality only if sign(r) == sign(a).
          if 2*r.magnitude > b.magnitude {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .toNearestOrZero) failed check:
            |remainder| must be less than or equal to |divisor|/2, but remainder was \(r).
            """)
            return
          }
          if 2*r.magnitude == b.magnitude && r.signum() != a.signum() {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .toNearestOrZero) failed check:
            If |remainder| equals |divisor|/2, remainder must match sign of dividend, but was \(r).
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
        let (q, r) = a.divided(by: b, rounding: .toNearestOrAway)
        let justq = a.divided(by: b, rounding: .toNearestOrAway)
        if q != justq {
          XCTFail("""
          \(a).divided(by: \(b), rounding: .toNearestOrAway) failed check:
          BinaryInteger overload did not produce the same quotient as SignedInteger.
          BinaryInteger result was \(justq), but SignedInteger was \(q).
          """)
          return
        }
        if divisionRuleHolds(a, b, q, r) {
          // We know a = bq + r with |r| < |b|. Now check |r| <= |b|/2
          // with equality only if sign(r) != sign(a).
          if 2*r.magnitude > b.magnitude {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .toNearestOrAway) failed check:
            |remainder| must be less than or equal to |divisor|/2, but remainder was \(r).
            """)
            return
          }
          if 2*r.magnitude == b.magnitude && r.signum() == a.signum() {
            XCTFail("""
            \(a).divided(by: \(b), rounding: .toNearestOrAway) failed check:
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
        let justq = a.divided(by: b, rounding: .toNearestOrEven)
        if q != justq {
          XCTFail("""
          \(a).divided(by: \(b), rounding: .toNearestOrEven) failed check:
          BinaryInteger overload did not produce the same quotient as SignedInteger.
          BinaryInteger result was \(justq), but SignedInteger was \(q).
          """)
          return
        }
        if divisionRuleHolds(a, b, q, r) {
          // We know a = bq + r with |r| < |b|. Now check |r| <= |b|/2
          // with equality only if q is even.
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
  
  func testDivideToOdd<T: SignedInteger & FixedWidthInteger>(_ values: [T]) {
    for a in values {
      for b in values where b != 0 {
        // Skip any SignedInt.min / -1 cases, because those will trap.
        if a == .min && b == -1 { continue }
        let (q, r) = a.divided(by: b, rounding: .toOdd)
        let justq = a.divided(by: b, rounding: .toOdd)
        if q != justq {
          XCTFail("""
          \(a).divided(by: \(b), rounding: .toOdd) failed check:
          BinaryInteger overload did not produce the same quotient as SignedInteger.
          BinaryInteger result was \(justq), but SignedInteger was \(q).
          """)
          return
        }
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
    testDivideToNearestOrDown(values)
    testDivideToNearestOrUp(values)
    testDivideToNearestOrZero(values)
    testDivideToNearestOrAway(values)
    testDivideToNearestOrEven(values)
    testDivideToOdd(values)
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
    testDivideToNearestOrDown(values)
    testDivideToNearestOrUp(values)
    testDivideToNearestOrZero(values)
    testDivideToNearestOrAway(values)
    testDivideToNearestOrEven(values)
    testDivideToOdd(values)
    testDivideExact(values)
  }

  func testDivideInt128() {
    var values = [DoubleWidth<Int64>](repeating: 0, count: 64)
    for i in 0 ..< values.count {
      while values[i] == 0 {
        values[i] = .random(in: .min ... .max)
      }
    }
    testDivideDown(values)
    testDivideUp(values)
    testDivideTowardZero(values)
    testDivideAwayFromZero(values)
    testDivideToNearestOrDown(values)
    testDivideToNearestOrUp(values)
    testDivideToNearestOrZero(values)
    testDivideToNearestOrAway(values)
    testDivideToNearestOrEven(values)
    testDivideToOdd(values)
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
        divideUInt8(a, b, rounding: .toNearestOrDown)
        divideUInt8(a, b, rounding: .toNearestOrUp)
        divideUInt8(a, b, rounding: .toNearestOrZero)
        divideUInt8(a, b, rounding: .toNearestOrAway)
        divideUInt8(a, b, rounding: .toNearestOrEven)
        divideUInt8(a, b, rounding: .toOdd)
      }
    }
  }
  
  func testRemainderByMinusOne() {
    // These would trap if implemented as a - bq or similar, even though
    // the remainder is well-defined.
    XCTAssertEqual(0, Int.min.remainder(dividingBy: -1))
    XCTAssertEqual(0, Int.min.remainder(dividingBy: -1, rounding: .up))
  }
}
