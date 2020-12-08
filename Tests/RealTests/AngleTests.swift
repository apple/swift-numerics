//===--- AngleTests.swift -------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import RealModule
import XCTest
import _TestSupport

internal extension Real
where Self: BinaryFloatingPoint {
    static func conversionBetweenRadiansAndDegreesChecks() {
        let angleFromRadians = Angle<Self>(radians: Self.pi / 3)
        assertClose(60, angleFromRadians.degrees)
        
        let angleFromDegrees = Angle<Self>(degrees: 120)
        // the compiler complains with the following line
        // assertClose(2 * Self.pi / 3, angleFromDegrees.radians)
        assertClose(2 * Double(Self.pi) / 3, angleFromDegrees.radians)
    }
    
    static func trigonometricFunctionChecks() {
        assertClose(1.1863995522992575361931268186727044683, Angle<Self>.acos(0.375).radians)
        assertClose(0.3843967744956390830381948729670469737, Angle<Self>.asin(0.375).radians)
        assertClose(0.3587706702705722203959200639264604997, Angle<Self>.atan(0.375).radians)
        assertClose(0.54041950027058415544357836460859991,   Angle<Self>.atan2(y: 0.375, x: 0.625).radians)
        
        assertClose(0.9305076219123142911494767922295555080, Angle<Self>(radians: 0.375).cos)
        assertClose(0.3662725290860475613729093517162641571, Angle<Self>(radians: 0.375).sin)
        assertClose(0.3936265759256327582294137871012180981, Angle<Self>(radians: 0.375).tan)
    }
    
    static func hyperbolicTrigonometricFunctionChecks() {
        assertClose(0.4949329230945269058895630995767185785, Angle<Self>.acosh(1.125).radians)
        assertClose(0.9670596312833237113713762009167286709, Angle<Self>.asinh(1.125).radians)
        assertClose(0.7331685343967135223291211023213964500, Angle<Self>.atanh(0.625).radians)
        assertClose(1.0711403467045867672994980155670160493, Angle<Self>(radians: 0.375).cosh)
        assertClose(0.3838510679136145687542956764205024589, Angle<Self>(radians: 0.375).sinh)
        assertClose(0.3583573983507859463193602315531580424, Angle<Self>(radians: 0.375).tanh)
    }
}

final class AngleTests: XCTestCase {
    #if swift(>=5.3) && !(os(macOS) || os(iOS) && targetEnvironment(macCatalyst))
    func testFloat16() {
        if #available(iOS 14.0, watchOS 14.0, tvOS 7.0, *) {
            Float16.conversionBetweenRadiansAndDegreesChecks()
            Float16.trigonometricFunctionChecks()
            Float16.hyperbolicTrigonometricFunctionChecks()
        }
    }
    #endif
    
    func testFloat() {
        Float.conversionBetweenRadiansAndDegreesChecks()
        Float.trigonometricFunctionChecks()
        Float.hyperbolicTrigonometricFunctionChecks()
    }
    
    func testDouble() {
        Double.conversionBetweenRadiansAndDegreesChecks()
        Double.trigonometricFunctionChecks()
        Double.hyperbolicTrigonometricFunctionChecks()
    }
    
    #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    func testFloat80() {
        Float80.conversionBetweenRadiansAndDegreesChecks()
        Float80.trigonometricFunctionChecks()
        Float80.hyperbolicTrigonometricFunctionChecks()
    }
    #endif
}
