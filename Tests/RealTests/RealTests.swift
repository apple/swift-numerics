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
import Real

#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
typealias TestLiteralType = Float80
#else
typealias TestLiteralType = Double
#endif

func sanityCheck<T>(_ expected: TestLiteralType, _ actual: T,
                    ulps allowed: T = 16,
                    file: StaticString = #file, line: UInt = #line)
  where T: BinaryFloatingPoint {
  // Shortcut relative-error check if we got the sign wrong; it's OK to
  // underflow to zero a little bit early, but we don't want to allow going
  // right through zero to the other side.
  XCTAssert(actual.sign == expected.sign, "\(actual) != \(expected) as \(T.self)", file: file, line: line)
  // Default tolerance is 16 ulps; It's OK to relax this as needed for new
  // platforms, as these Checks are *not* intended to validate the math
  // library--they are only intended to check that the Swift bindings are
  // calling the right functions in the math library. It's important, however
  // not to relax the tolerance beyond a few hundred ulps, because these Checks
  // need to detect errors where the *wrong function* is being called; e.g.
  // we need to flag an implentation that inadvertently called the C hypotf
  // function instead of hypot. This is especially important because the C
  // shims that we're calling through will allow silent type conversions.
  if actual == T(expected) || actual.isNaN && expected.isNaN {
    return
  }
  // Special-case where expected or observed is infinity.
  // Artificially knock everything down a binade, treat actual infinity as
  // the base of the next binade up.
  if actual.isInfinite || T(expected).isInfinite {
    let scaledExpected = TestLiteralType(signOf: expected,
      magnitudeOf: expected.isInfinite ? TestLiteralType.greatestFiniteMagnitude.binade : 0.5 * expected
    )
    let scaledActual = T(signOf: actual,
      magnitudeOf: actual.isInfinite ? T.greatestFiniteMagnitude.binade : 0.5 * actual
    )
    return sanityCheck(scaledExpected, scaledActual, ulps: allowed, file: file, line: line)
  }
  // Compute error in ulp, compare to tolerance.
  let absoluteError = T(abs(TestLiteralType(actual) - expected)).magnitude
  let ulpError = absoluteError / max(T(expected).magnitude, T.leastNormalMagnitude).ulp
  XCTAssert(ulpError <= allowed, "\(actual) != \(expected) as \(T.self)\n\(ulpError)-ulp error exceeds \(allowed)-ulp tolerance.", file: file, line: line)
}

internal extension ElementaryFunctions where Self: BinaryFloatingPoint {
  static func elementaryFunctionChecks() {
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
    sanityCheck(0.4549914146182013360537936919875185083, Self.expMinusOne(0.375))
    sanityCheck(-0.980829253011726236856451127452003999, Self.log(0.375))
    sanityCheck(0.3184537311185346158102472135905995955, Self.log(onePlus: 0.375))
    sanityCheck(-0.7211247851537041911608191553900547941, Self.root(-0.375, 3))
    XCTAssertEqual(-10, Self.root(-1000, 3))
    sanityCheck(0.6123724356957945245493210186764728479, Self.sqrt(0.375))
    sanityCheck(0.54171335479545025876069682133938570, Self.pow(0.375, 0.625))
    sanityCheck(-0.052734375, Self.pow(-0.375, 3))
  }
}

internal extension Real where Self: BinaryFloatingPoint {
  static func realFunctionChecks() {
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
  
  static func testPownCommon() {
    // If x is -1, then the result is ±1 with sign chosen by parity of n.
    // Simply converting n to Real will flip parity when n is large, so
    // first check that we get those cases right.
    XCTAssertEqual(Self.pow(-1,  0),  1)
    XCTAssertEqual(Self.pow(-1,  1), -1)
    XCTAssertEqual(Self.pow(-1, -1), -1)
    XCTAssertEqual(Self.pow(-1,  2),  1)
    XCTAssertEqual(Self.pow(-1, -2),  1)
    XCTAssertEqual(Self.pow(-1,  Int.max - 1), 1)
    XCTAssertEqual(Self.pow(-1, -Int.max + 1), 1)
    XCTAssertEqual(Self.pow(-1,  Int.max), -1)
    XCTAssertEqual(Self.pow(-1, -Int.max), -1)
    XCTAssertEqual(Self.pow(-1,  Int.min),  1)
  }
}

extension Float {
  static func testPown() {
    testPownCommon()
    let u = Float(1).nextUp
    let d = Float(1).nextDown
    // Smallest exponents not exactly representable as Float.
    sanityCheck(-7.3890560989306677280287919329569359, Float.pow(-u, 0x1000001))
    sanityCheck(-0.3678794082804575860056608283059288, Float.pow(-d, 0x1000001))
    // Exponents close to overflow boundary.
    sanityCheck(-3.4028231352500001570898203463449749e38, Float.pow(-u, 744261161))
    sanityCheck( 3.4028235408981285772043562848249166e38, Float.pow(-u, 744261162))
    sanityCheck(-3.4028239465463053543440887892352174e38, Float.pow(-u, 744261163))
    sanityCheck( 3.4028233551634475284795244782720072e38, Float.pow(-d, -1488522190))
    sanityCheck(-3.4028235579875369356575053576685267e38, Float.pow(-d, -1488522191))
    sanityCheck( 3.4028237608116384320940078199368685e38, Float.pow(-d, -1488522192))
    // Exponents close to underflow boundary.
    sanityCheck( 7.0064936491761438872280296737844625e-46, Float.pow(-u, -872181048))
    sanityCheck(-7.0064928139371132951305928725186420e-46, Float.pow(-u, -872181049))
    sanityCheck( 7.0064919786981822712727285793333389e-46, Float.pow(-u, -872181050))
    sanityCheck(-7.0064924138100205091278464932003585e-46, Float.pow(-d, 1744361943))
    sanityCheck( 7.0064919961905290625123586120258840e-46, Float.pow(-d, 1744361944))
    sanityCheck(-7.0064915785710625079583096856510544e-46, Float.pow(-d, 1744361945))
  }
}

extension Double {
  static func testPown() {
    testPownCommon()
    let u: Double = 1.nextUp
    let d: Double = 1.nextDown
    // Smallest exponent not exactly representable as Double.
    sanityCheck(-7.3890560989306502272304274605750685, Double.pow(-u, 0x20000000000001))
    sanityCheck(-0.1353352832366126918939994949724833, Double.pow(-u, -0x20000000000001))
    sanityCheck(-0.3678794411714422603312898889458068, Double.pow(-d, 0x20000000000001))
    sanityCheck(-2.7182818284590456880451484776630468, Double.pow(-d, -0x20000000000001))
    // Exponents close to overflow boundary.
    sanityCheck( 1.7976931348623151738531864721534215e308, Double.pow(-u, 3196577161300664268))
    sanityCheck(-1.7976931348623155730212483790972209e308, Double.pow(-u, 3196577161300664269))
    sanityCheck( 1.7976931348623159721893102860411089e308, Double.pow(-u, 3196577161300664270))
    sanityCheck( 1.7976931348623157075547244136070910e308, Double.pow(-d, -6393154322601327474))
    sanityCheck(-1.7976931348623159071387553670790721e308, Double.pow(-d, -6393154322601327475))
    sanityCheck( 1.7976931348623161067227863205510754e308, Double.pow(-d, -6393154322601327476))
    // Exponents close to underflow boundary.
    sanityCheck( 2.4703282292062334560337346683707907e-324, Double.pow(-u, -3355781687888880946))
    sanityCheck(-2.4703282292062329075106789791206172e-324, Double.pow(-u, -3355781687888880947))
    sanityCheck( 2.4703282292062323589876232898705654e-324, Double.pow(-u, -3355781687888880948))
    sanityCheck(-2.4703282292062332640976590913373022e-324, Double.pow(-d, 6711563375777760775))
    sanityCheck( 2.4703282292062329898361312467121758e-324, Double.pow(-d, 6711563375777760776))
    sanityCheck(-2.4703282292062327155746034020870799e-324, Double.pow(-d, 6711563375777760777))
  }
}

final class ElementaryFunctionChecks: XCTestCase {
  
  func testFloat() {
    Float.elementaryFunctionChecks()
    Float.realFunctionChecks()
    Float.testPown()
  }
  
  func testDouble() {
    Double.elementaryFunctionChecks()
    Double.realFunctionChecks()
    Double.testPown()
  }
  
  #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
  func testFloat80() {
    Float80.elementaryFunctionChecks()
    Float80.realFunctionChecks()
  }
  #endif
}
