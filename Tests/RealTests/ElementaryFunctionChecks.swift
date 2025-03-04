//===--- ElementaryFunctionChecks.swift ------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import RealModule
import _TestSupport

#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
public typealias TestLiteralType = Float80
#else
public typealias TestLiteralType = Double
#endif

@discardableResult
internal func assertClose<T>(
  _ expected: TestLiteralType,
  _ observed: T,
  allowedError: T = 16,
  file: StaticString = #file,
  line: UInt = #line
) -> T where T: BinaryFloatingPoint {
  // Shortcut relative-error check if we got the sign wrong; it's OK to
  // underflow to zero, but we do not want to allow going right through
  // zero and getting the sign wrong.
  guard observed.sign == expected.sign else {
    print("Sign was wrong: expected \(expected) but saw \(observed).")
    XCTFail(file: file, line: line)
    return .infinity
  }
  if observed.isNaN && expected.isNaN { return 0 }
  // If T(expected) is zero or infinite, and matches observed, the error
  // is zero.
  let expectedT = T(expected)
  if observed.isZero && expectedT.isZero { return 0 }
  if observed.isInfinite && expectedT.isInfinite { return 0 }
  // Special-case where only one of expectedT or observed is infinity.
  // Artificially knock everything down a binade, treat actual infinity as
  // the base of the next binade up.
  func topBinade(signOf x: T) -> T {
    T(signOf: x, magnitudeOf: T.greatestFiniteMagnitude.binade)
  }
  if observed.isInfinite {
    return assertClose(
      expected/2, topBinade(signOf: observed),
      allowedError: allowedError, file: file, line: line
    )
  }
  if expectedT.isInfinite {
    return assertClose(
      TestLiteralType(topBinade(signOf: expectedT)), observed/2,
      allowedError: allowedError, file: file, line: line
    )
  }
  // Compute error in ulp, compare to tolerance.
  let absoluteError = (TestLiteralType(observed) - expected).magnitude
  let scale = max(expectedT.magnitude, T.leastNormalMagnitude).ulp
  let ulps = T(absoluteError/TestLiteralType(scale))
  if ulps > allowedError {
    print("ULP error was unacceptably large: expected \(expected) but saw \(observed) (\(ulps)-ulp error).")
    XCTFail(file: file, line: line)
  }
  return ulps
}

internal func assertClose<T>(
  _ expected: TestLiteralType,
  _ observed: T,
  allowedError: T = 16,
  worstError: inout T,
  file: StaticString = #file,
  line: UInt = #line
) where T: BinaryFloatingPoint {
  worstError = max(worstError, assertClose(
    expected, observed, allowedError: allowedError, file: file, line: line
  ))
}

internal extension ElementaryFunctions where Self: BinaryFloatingPoint {
  static func elementaryFunctionChecks() {
    assertClose(1.1863995522992575361931268186727044683, Self.acos(0.375))
    assertClose(0.3843967744956390830381948729670469737, Self.asin(0.375))
    assertClose(0.3587706702705722203959200639264604997, Self.atan(0.375))
    assertClose(0.9305076219123142911494767922295555080, Self.cos(0.375))
    assertClose(0.3662725290860475613729093517162641571, Self.sin(0.375))
    assertClose(0.3936265759256327582294137871012180981, Self.tan(0.375))
    assertClose(0.4949329230945269058895630995767185785, Self.acosh(1.125))
    assertClose(0.9670596312833237113713762009167286709, Self.asinh(1.125))
    assertClose(0.7331685343967135223291211023213964500, Self.atanh(0.625))
    assertClose(1.0711403467045867672994980155670160493, Self.cosh(0.375))
    assertClose(0.3838510679136145687542956764205024589, Self.sinh(0.375))
    assertClose(0.3583573983507859463193602315531580424, Self.tanh(0.375))
    assertClose(1.4549914146182013360537936919875185083, Self.exp(0.375))
    assertClose(0.4549914146182013360537936919875185083, Self.expMinusOne(0.375))
    assertClose(-0.980829253011726236856451127452003999, Self.log(0.375))
    assertClose(0.3184537311185346158102472135905995955, Self.log(onePlus: 0.375))
    assertClose(-0.7211247851537041911608191553900547941, Self.root(-0.375, 3))
    XCTAssertEqual(-10, Self.root(-1000, 3))
    assertClose(0.6123724356957945245493210186764728479, Self.sqrt(0.375))
    assertClose(0.54171335479545025876069682133938570, Self.pow(0.375, 0.625))
    assertClose(-0.052734375, Self.pow(-0.375, 3))
  }
}

internal extension Real where Self: BinaryFloatingPoint {
  static func realFunctionChecks() {
    assertClose(1.2968395546510096659337541177924511598, Self.exp2(0.375))
    assertClose(2.3713737056616552616517527574788898386, Self.exp10(0.375))
    assertClose(-1.415037499278843818546261056052183491, Self.log2(0.375))
    assertClose(-0.425968732272281148346188780918363771, Self.log10(0.375))
    assertClose(0.54041950027058415544357836460859991, Self.atan2(y: 0.375, x: 0.625))
    assertClose(0.72886898685566255885926910969319788, Self.hypot(0.375, 0.625))
    assertClose(0.4041169094348222983238250859191217675, Self.erf(0.375))
    assertClose(0.5958830905651777016761749140808782324, Self.erfc(0.375))
    assertClose(2.3704361844166009086464735041766525098, Self.gamma(0.375))
#if !os(Windows)
    assertClose( -0.11775527074107877445136203331798850, Self.logGamma(1.375))
    XCTAssertEqual(.plus,  Self.signGamma(1.375))
    XCTAssertEqual(.minus, Self.signGamma(-2.375))
#endif
  }
}

extension Real {
  static func powZeroChecks() {
    // pow(_:Self,_:Self) is defined by exp(y log(x)) and has edge-cases to
    // match. In particular, if x is zero, log(x) is -infinity, so pow(0,0)
    // is exp(0 * -infinity) = exp(nan) = nan.
    XCTAssertEqual(pow(0, -1 as Self), infinity)
    XCTAssert(pow(0, 0 as Self).isNaN)
    XCTAssertEqual(pow(0,  1 as Self), zero)
    // pow(_:Self,_:Int) is defined by repeated multiplication or division,
    // and hence pow(0, 0) is 1.
    XCTAssertEqual(pow(0, -1), infinity)
    XCTAssertEqual(pow(0,  0), 1)
    XCTAssertEqual(pow(0,  1), zero)
  }
}

final class ElementaryFunctionChecks: XCTestCase {
  
#if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
  func testFloat16() {
    if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
      Float16.elementaryFunctionChecks()
      Float16.realFunctionChecks()
      Float16.powZeroChecks()
    }
  }
#endif
  
  func testFloat() {
    Float.elementaryFunctionChecks()
    Float.realFunctionChecks()
    Float.powZeroChecks()
  }
  
  func testDouble() {
    Double.elementaryFunctionChecks()
    Double.realFunctionChecks()
    Double.powZeroChecks()
  }
  
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
  func testFloat80() {
    Float80.elementaryFunctionChecks()
    Float80.realFunctionChecks()
    Float80.powZeroChecks()
  }
#endif
}
