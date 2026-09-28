//===--- CompoundTests.swift ----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import RealModule
import _TestSupport

internal extension Real where Self: FixedWidthFloatingPoint {

  //  Edge cases that every conforming type must handle identically.
  static func testCompoundEdgeCases() {
    //  An exponent of zero is 1 (resp. 0) everywhere the operation is
    //  defined, including at infinity.
    XCTAssertEqual(Self.pow(onePlus: 0, 0), 1)
    XCTAssertEqual(Self.pow(onePlus: 0.375, 0), 1)
    XCTAssertEqual(Self.pow(onePlus: -1, 0), 1)
    XCTAssertEqual(Self.pow(onePlus: .infinity, 0), 1)
    XCTAssertEqual(Self.powMinusOne(onePlus: 0, 0), 0)
    XCTAssertEqual(Self.powMinusOne(onePlus: 0.375, 0), 0)
    XCTAssertEqual(Self.powMinusOne(onePlus: -1, 0), 0)
    XCTAssertEqual(Self.powMinusOne(onePlus: .infinity, 0), 0)

    //  x < -1 is a domain error, even for an exponent of zero, and NaN
    //  propagates.
    XCTAssertTrue(Self.pow(onePlus: -2, 0).isNaN)
    XCTAssertTrue(Self.pow(onePlus: -2, 2).isNaN)
    XCTAssertTrue(Self.pow(onePlus: -2, -2).isNaN)
    XCTAssertTrue(Self.pow(onePlus: -.infinity, 3).isNaN)
    XCTAssertTrue(Self.pow(onePlus: .nan, 0).isNaN)
    XCTAssertTrue(Self.pow(onePlus: .nan, 3).isNaN)
    XCTAssertTrue(Self.powMinusOne(onePlus: -2, 0).isNaN)
    XCTAssertTrue(Self.powMinusOne(onePlus: -2, 2).isNaN)
    XCTAssertTrue(Self.powMinusOne(onePlus: .nan, 3).isNaN)

    //  x == -1 means a base of zero: repeated multiplication gives +0,
    //  repeated division gives +infinity.
    XCTAssertEqual(Self.pow(onePlus: -1, 1), 0)
    XCTAssertEqual(Self.pow(onePlus: -1, 2), 0)
    XCTAssertEqual(Self.pow(onePlus: -1, 5), 0)
    XCTAssertEqual(Self.pow(onePlus: -1, .max), 0)
    XCTAssertEqual(Self.pow(onePlus: -1, -1), .infinity)
    XCTAssertEqual(Self.pow(onePlus: -1, -5), .infinity)
    XCTAssertEqual(Self.pow(onePlus: -1, .min), .infinity)
    //  The sign of the zero is positive, because the base is +0.
    XCTAssertFalse(Self.pow(onePlus: -1, 1).sign == .minus)
    XCTAssertEqual(Self.powMinusOne(onePlus: -1, 1), -1)
    XCTAssertEqual(Self.powMinusOne(onePlus: -1, 5), -1)
    XCTAssertEqual(Self.powMinusOne(onePlus: -1, -1), .infinity)

    //  A base of infinity.
    XCTAssertEqual(Self.pow(onePlus: .infinity, 1), .infinity)
    XCTAssertEqual(Self.pow(onePlus: .infinity, .max), .infinity)
    XCTAssertEqual(Self.pow(onePlus: .infinity, -1), 0)
    XCTAssertEqual(Self.pow(onePlus: .infinity, .min), 0)
    XCTAssertEqual(Self.powMinusOne(onePlus: .infinity, 1), .infinity)
    XCTAssertEqual(Self.powMinusOne(onePlus: .infinity, -1), -1)

    //  x == 0 means a base of exactly 1, which is 1 for every exponent,
    //  including exponents too large to be represented as Self.
    XCTAssertEqual(Self.pow(onePlus: 0, 1), 1)
    XCTAssertEqual(Self.pow(onePlus: 0, -1), 1)
    XCTAssertEqual(Self.pow(onePlus: 0, .max), 1)
    XCTAssertEqual(Self.pow(onePlus: 0, .min), 1)
    XCTAssertEqual(Self.powMinusOne(onePlus: 0, .max), 0)
    XCTAssertEqual(Self.powMinusOne(onePlus: 0, .min), 0)

    //  Exact small cases, which must be computed without any rounding error.
    XCTAssertEqual(Self.pow(onePlus: 1, 1), 2)
    XCTAssertEqual(Self.pow(onePlus: 1, 2), 4)
    XCTAssertEqual(Self.pow(onePlus: 1, 10), 1024)
    XCTAssertEqual(Self.pow(onePlus: 2, 3), 27)
    XCTAssertEqual(Self.powMinusOne(onePlus: 1, 10), 1023)
    XCTAssertEqual(Self.powMinusOne(onePlus: 2, 3), 26)
    XCTAssertEqual(Self.pow(onePlus: -0.5, 2), 0.25)
    XCTAssertEqual(Self.pow(onePlus: -0.5, -2), 4)

    //  Overflow and underflow must saturate to infinity and zero rather
    //  than producing NaN. Int.min and Int.max must not trap or wrap.
    let big = 2 - Int(Self.leastNonzeroMagnitude.exponent)
    XCTAssertEqual(Self.pow(onePlus: 1, big), .infinity)
    XCTAssertEqual(Self.pow(onePlus: 1, -big), 0)
    XCTAssertEqual(Self.pow(onePlus: 1, .max), .infinity)
    XCTAssertEqual(Self.pow(onePlus: 1, .min), 0)
    XCTAssertEqual(Self.pow(onePlus: -0.5, big), 0)
    XCTAssertEqual(Self.pow(onePlus: -0.5, -big), .infinity)
    //  powMinusOne must also saturate to infinity, not NaN; this is a case
    //  that a naive `pow(onePlus:) - 1` implementation gets wrong.
    XCTAssertEqual(Self.powMinusOne(onePlus: 1, big), .infinity)
    XCTAssertEqual(Self.powMinusOne(onePlus: 1, .max), .infinity)
    XCTAssertEqual(Self.powMinusOne(onePlus: -0.5, -big), .infinity)
    //  Underflow of the power gives -1, not NaN.
    XCTAssertEqual(Self.powMinusOne(onePlus: 1, -big), -1)
    XCTAssertEqual(Self.powMinusOne(onePlus: 1, .min), -1)

    //  A tiny rate with an enormous exponent still overflows to infinity.
    //  (glibc's compoundn had a bug that returned NaN for such inputs.)
    let tiny = Self.ulpOfOne
    XCTAssertEqual(Self.pow(onePlus: tiny, .max), .infinity)
    XCTAssertEqual(Self.pow(onePlus: tiny, .min), 0)
  }

  //  `pow(onePlus: x, n)` must agree with repeated multiplication for
  //  exponents small enough that repeated multiplication is itself accurate.
  static func testCompoundAgainstRepeatedMultiplication() {
    var g = SystemRandomNumberGenerator()
    for _ in 0 ..< 100 {
      let x = Self.random(in: -0.5 ..< 1, using: &g)
      var expected = Self(1)
      for n in 1 ... 12 {
        expected *= (1 + x)
        //  Repeated multiplication of n terms carries up to n/2 ulp of
        //  error, so allow a little more room as n grows.
        assertClose(
          TestLiteralType(expected),
          Self.pow(onePlus: x, n),
          allowedError: Self(n)
        )
      }
    }
  }

  //  The defining identity, checked where it is numerically meaningful.
  static func testCompoundReciprocalIdentity() {
    var g = SystemRandomNumberGenerator()
    for _ in 0 ..< 100 {
      let x = Self.random(in: -0.5 ..< 1, using: &g)
      for n in [1, 2, 3, 7, 12, 100] {
        let p = Self.pow(onePlus: x, n)
        let q = Self.pow(onePlus: x, -n)
        guard p.isNormal && q.isNormal else { continue }
        //  p and q are each within half an ulp of the true values, so their
        //  product is within about 1.5 ulp of 1.
        assertClose(1, p*q, allowedError: 4)
      }
    }
  }

  //  powMinusOne must be consistent with pow when no cancellation occurs.
  static func testCompoundMinusOneConsistency() {
    var g = SystemRandomNumberGenerator()
    for _ in 0 ..< 100 {
      let x = Self.random(in: 0.25 ..< 1, using: &g)
      for n in [1, 2, 3, 7, 12] {
        let a = Self.pow(onePlus: x, n)
        guard a.isNormal && a > 2 else { continue }
        //  When the result is comfortably larger than 1, subtracting one is
        //  well-conditioned and both spellings must agree closely.
        assertClose(
          TestLiteralType(a) - 1,
          Self.powMinusOne(onePlus: x, n),
          allowedError: 2
        )
      }
    }
  }
}

internal extension Real where Self: BinaryFloatingPoint {
  //  Reference values computed with 60 significant decimal digits.
  static func testCompoundKnownValues() {
    assertClose(2.599609375, Self.pow(onePlus: 0.375, 3))
    assertClose(9.292207241058349609375, Self.pow(onePlus: 0.375, 7))
    assertClose(0.3846731780616078136739293764087152516905,
                Self.pow(onePlus: 0.375, -3))
    assertClose(11.330963134765625, Self.pow(onePlus: 0.625, 5))
    assertClose(0.152587890625, Self.pow(onePlus: -0.375, 4))
    assertClose(0.244140625, Self.pow(onePlus: -0.375, 3))
    assertClose(4.109890672858455218374729156494140625,
                Self.pow(onePlus: 0.125, 12))

    assertClose(1.599609375, Self.powMinusOne(onePlus: 0.375, 3))
    assertClose(8.292207241058349609375, Self.powMinusOne(onePlus: 0.375, 7))
    assertClose(-0.6153268219383921863260706235912847483095,
                Self.powMinusOne(onePlus: 0.375, -3))
    assertClose(10.330963134765625, Self.powMinusOne(onePlus: 0.625, 5))
    assertClose(-0.847412109375, Self.powMinusOne(onePlus: -0.375, 4))
    assertClose(-0.755859375, Self.powMinusOne(onePlus: -0.375, 3))
  }
}

extension Double {
  static func testCompound() {
    testCompoundEdgeCases()
    testCompoundKnownValues()
    testCompoundAgainstRepeatedMultiplication()
    testCompoundReciprocalIdentity()
    testCompoundMinusOneConsistency()

    //  The whole point of the operation: x so small that 1+x rounds to 1,
    //  so `pow(1+x, n)` loses every digit of x but `pow(onePlus: x, n)`
    //  does not.
    let x = 0x1.0p-60
    XCTAssertEqual(Double.pow(1+x, 3650), 1)
    assertClose(1.000000000000003165870343657677957296301,
                Double.pow(onePlus: x, 3650))
    assertClose(3.165870343657677957296301202361186061099e-15,
                Double.powMinusOne(onePlus: x, 3650))
    //  Likewise, powMinusOne survives cancellation that defeats
    //  `pow(onePlus: x, n) - 1`.
    XCTAssertEqual(Double.pow(onePlus: x, 8) - 1, 0)
    assertClose(6.938893903907228398712556692303019132466e-18,
                Double.powMinusOne(onePlus: x, 8))

    //  x = ulpOfOne, where 1+x is exactly representable.
    let u = 0x1.0p-52
    assertClose(1.000000000000222044604925055935336111204,
                Double.pow(onePlus: u, 1000))
    assertClose(2.220446049250559353361112038996014624127e-13,
                Double.powMinusOne(onePlus: u, 1000))
    assertClose(0.9999999999997779553950749933684704651093,
                Double.pow(onePlus: u, -1000))
    assertClose(-2.220446049250066315295348906727108736297e-13,
                Double.powMinusOne(onePlus: u, -1000))

    //  Compound interest: 5% annual, compounded daily for ten years.
    assertClose(1.648664813765471830213999421196829576774,
                Double.pow(onePlus: 0.05/365, 3650))
    assertClose(0.6486648137654718302139994211968295767744,
                Double.powMinusOne(onePlus: 0.05/365, 3650))
    //  One basis point, compounded daily for a year.
    assertClose(1.037172411302551929902028017056328631244,
                Double.pow(onePlus: 0.0001, 365))
    assertClose(0.03717241130255192990202801705632863124371,
                Double.powMinusOne(onePlus: 0.0001, 365))

    //  Just below the overflow boundary.
    assertClose(8.988465674311579538646525953945123668090e307,
                Double.pow(onePlus: 1, 1023))
    assertClose(8.988465674311579538646525953945123668090e307,
                Double.pow(onePlus: -0.5, -1023))
  }
}

extension Float {
  static func testCompound() {
    testCompoundEdgeCases()
    testCompoundKnownValues()
    testCompoundAgainstRepeatedMultiplication()
    testCompoundReciprocalIdentity()
    testCompoundMinusOneConsistency()

    //  Small-x behavior at Float precision.
    let x: Float = 0x1.0p-30
    XCTAssertEqual(Float.pow(1+x, 365), 1)
    assertClose(1.000000339932797353496405842244828746964,
                Float.pow(onePlus: x, 365))
    assertClose(3.399327973534964058422448287469638269507e-7,
                Float.powMinusOne(onePlus: x, 365))
  }
}

#if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension Float16 {
  static func testCompound() {
    testCompoundEdgeCases()
    testCompoundKnownValues()
    testCompoundAgainstRepeatedMultiplication()
    testCompoundReciprocalIdentity()
    testCompoundMinusOneConsistency()
  }
}
#endif

final class CompoundTests: XCTestCase {

  func testDouble() {
    Double.testCompound()
  }

  func testFloat() {
    Float.testCompound()
  }

  #if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
  func testFloat16() {
    if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
      Float16.testCompound()
    }
  }
  #endif
}
