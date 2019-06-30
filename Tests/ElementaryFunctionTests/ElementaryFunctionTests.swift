//===--- ElementaryFunctionTests.swift ------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import XCTest
import ElementaryFunctions

#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
typealias TestLiteralType = Float80
#else
typealias TestLiteralType = Double
#endif

func sanityCheck<T>(_ expected: TestLiteralType, _ actual: T,
                    ulps allowed: T = 16,
                    file: StaticString = #file, line: UInt = #line)
  where T: BinaryFloatingPoint {
  // Default tolerance is 16 ulps; It's OK to relax this as needed for new
  // platforms, as these tests are *not* intended to validate the math
  // library--they are only intended to check that the Swift bindings are
  // calling the right functions in the math library. It's important, however
  // not to relax the tolerance beyond a few hundred ulps, because these tests
  // need to detect errors where the *wrong function* is being called; e.g.
  // we need to flag an implentation that inadvertently called the C hypotf
  // function instead of hypot. This is especially important because the C
  // shims that we're calling through will allow silent type conversions.
  if actual == T(expected) || actual.isNaN && expected.isNaN {
    return
  }
  //  Compute error in ulp, compare to tolerance.
  let absoluteError = T(abs(TestLiteralType(actual) - expected))
  let ulpError = absoluteError / T(expected).ulp
  XCTAssert(ulpError <= allowed, "\(actual) != \(expected) as \(T.self)" +
            "\n  \(ulpError)-ulp error exceeds \(allowed)-ulp tolerance.",
            file: file, line: line)
}

internal extension ElementaryFunctions where Self: BinaryFloatingPoint {
  static func elementaryFunctionTests() {
    sanityCheck(1.1863995522992575361931268186727044683, Self.acos(0.375))
    sanityCheck(0.3843967744956390830381948729670469737, Self.asin(0.375))
    sanityCheck(0.3587706702705722203959200639264604997, Self.atan(0.375))
    sanityCheck(0.9305076219123142911494767922295555080, Self.cos(0.375))
    sanityCheck(0.3662725290860475613729093517162641571, Self.sin(0.375))
    sanityCheck(0.3936265759256327582294137871012180981, Self.tan(0.375))
    sanityCheck(0.4949329230945269058895630995767185785, Self.acosh(1.125))
    sanityCheck(0.9670596312833237113713762009167286709, Self.asinh(1.125))
    sanityCheck(0.7331685343967135223291211023213964500, Self.atanh(0.625))
    sanityCheck(1.0711403467045867672994980155670160493, Self.cosh(0.375))
    sanityCheck(0.3838510679136145687542956764205024589, Self.sinh(0.375))
    sanityCheck(0.3583573983507859463193602315531580424, Self.tanh(0.375))
    sanityCheck(1.4549914146182013360537936919875185083, Self.exp(0.375))
    sanityCheck(0.4549914146182013360537936919875185083, Self.expm1(0.375))
    sanityCheck(-0.980829253011726236856451127452003999, Self.log(0.375))
    sanityCheck(0.3184537311185346158102472135905995955, Self.log1p(0.375))
    sanityCheck(-0.7211247851537041911608191553900547941, Self.root(-0.375, 3))
    sanityCheck(0.6123724356957945245493210186764728479, Self.sqrt(0.375))
    sanityCheck(0.54171335479545025876069682133938570, Self.pow(0.375, 0.625))
    sanityCheck(-0.052734375, Self.pow(-0.375, 3))
  }
}

internal extension Real where Self: BinaryFloatingPoint {
  static func realFunctionTests() {
    sanityCheck(1.2968395546510096659337541177924511598, Self.exp2(0.375))
    sanityCheck(2.3713737056616552616517527574788898386, Self.exp10(0.375))
    sanityCheck(-1.415037499278843818546261056052183491, Self.log2(0.375))
    sanityCheck(-0.425968732272281148346188780918363771, Self.log10(0.375))
    sanityCheck(0.54041950027058415544357836460859991, Self.atan2(y: 0.375, x: 0.625))
    sanityCheck(0.72886898685566255885926910969319788, Self.hypot(0.375, 0.625))
    sanityCheck(0.4041169094348222983238250859191217675, Self.erf(0.375))
    sanityCheck(0.5958830905651777016761749140808782324, Self.erfc(0.375))
    sanityCheck(2.3704361844166009086464735041766525098, Self.gamma(0.375))
    #if !os(Windows)
    sanityCheck( -0.11775527074107877445136203331798850, Self.logGamma(1.375))
    XCTAssertEqual(.plus,  Self.signGamma(1.375))
    XCTAssertEqual(.minus, Self.signGamma(-2.375))
    #endif
  }
}

final class ElementaryFunctionTests: XCTestCase {
  
  func testFloat() {
    Float.elementaryFunctionTests()
    Float.realFunctionTests()
  }
  
  func testDouble() {
    Double.elementaryFunctionTests()
    Double.realFunctionTests()
  }
  
  
  #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
  func testFloat80() {
    Float80.elementaryFunctionTests()
    Float80.realFunctionTests()
  }
  
  static var allTests = [
    ("testFloat", testFloat),
    ("testDouble", testDouble),
    ("testFloat80", testFloat80),
  ]
  #else
  static var allTests = [
    ("testFloat", testFloat),
    ("testDouble", testDouble),
  ]
  #endif
}

#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
public func allTests() -> [XCTestCaseEntry] {
  return [
    testCase(ComplexTests.allTests),
  ]
}
#endif
