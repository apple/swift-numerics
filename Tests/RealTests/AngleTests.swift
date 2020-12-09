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
  
        assertClose(0.9305076219123142911494767922295555080, cos(Angle<Self>(radians: 0.375)))
        assertClose(0.3662725290860475613729093517162641571, sin(Angle<Self>(radians: 0.375)))
        assertClose(0.3936265759256327582294137871012180981, tan(Angle<Self>(radians: 0.375)))
    }
    
    static func specialDegreesTrigonometricFunctionChecks() {
        assertClose(1, cos(Angle<Self>(degrees: -360)))
        assertClose(0, cos(Angle<Self>(degrees: -270)))
        assertClose(-1, cos(Angle<Self>(degrees: -180)))
        assertClose(-0.86602540378443864676372317075293618347, cos(Angle<Self>(degrees: -150)))
        assertClose(-0.70710678118654752440084436210484903929, cos(Angle<Self>(degrees: -135)))
        assertClose(-0.5, cos(Angle<Self>(degrees: -120)))
        assertClose(0, cos(Angle<Self>(degrees: -90)))
        assertClose(0.5, cos(Angle<Self>(degrees: -60)))
        assertClose(0.70710678118654752440084436210484903929, cos(Angle<Self>(degrees: -45)))
        assertClose(0.86602540378443864676372317075293618347, cos(Angle<Self>(degrees: -30)))
        assertClose(1, cos(Angle<Self>(degrees: 0)))
        assertClose(0.86602540378443864676372317075293618347, cos(Angle<Self>(degrees: 30)))
        assertClose(0.70710678118654752440084436210484903929, cos(Angle<Self>(degrees: 45)))
        assertClose(0.5, cos(Angle<Self>(degrees: 60)))
        assertClose(0, cos(Angle<Self>(degrees: 90)))
        assertClose(-0.5, cos(Angle<Self>(degrees: 120)))
        assertClose(-0.70710678118654752440084436210484903929, cos(Angle<Self>(degrees: 135)))
        assertClose(-0.86602540378443864676372317075293618347, cos(Angle<Self>(degrees: 150)))
        assertClose(-1, cos(Angle<Self>(degrees: 180)))
        assertClose(0, cos(Angle<Self>(degrees: 270)))
        assertClose(1, cos(Angle<Self>(degrees: 360)))
        
        assertClose(0, sin(Angle<Self>(degrees: -360)))
        assertClose(1, sin(Angle<Self>(degrees: -270)))
        assertClose(0, sin(Angle<Self>(degrees: -180)))
        assertClose(-0.5, sin(Angle<Self>(degrees: -150)))
        assertClose(-0.70710678118654752440084436210484903929, sin(Angle<Self>(degrees: -135)))
        assertClose(-0.86602540378443864676372317075293618347, sin(Angle<Self>(degrees: -120)))
        assertClose(-1, sin(Angle<Self>(degrees: -90)))
        assertClose(-0.86602540378443864676372317075293618347, sin(Angle<Self>(degrees: -60)))
        assertClose(-0.70710678118654752440084436210484903929, sin(Angle<Self>(degrees: -45)))
        assertClose(-0.5, sin(Angle<Self>(degrees: -30)))
        assertClose(0, sin(Angle<Self>(degrees: 0)))
        assertClose(0.5, sin(Angle<Self>(degrees: 30)))
        assertClose(0.70710678118654752440084436210484903929, sin(Angle<Self>(degrees: 45)))
        assertClose(0.86602540378443864676372317075293618347, sin(Angle<Self>(degrees: 60)))
        assertClose(1, sin(Angle<Self>(degrees: 90)))
        assertClose(0.86602540378443864676372317075293618347, sin(Angle<Self>(degrees: 120)))
        assertClose(0.70710678118654752440084436210484903929, sin(Angle<Self>(degrees: 135)))
        assertClose(0.5, sin(Angle<Self>(degrees: 150)))
        assertClose(0, sin(Angle<Self>(degrees: 180)))
        assertClose(-1, sin(Angle<Self>(degrees: 270)))
        assertClose(0, sin(Angle<Self>(degrees: 360)))

//        let t = Self.tan(.pi/2)
//        let isInfinite = t.isInfinite
//        assertClose(0, tan(Angle<Self>(degrees: -360)))
//        assertClose(0, tan(Angle<Self>(degrees: -180)))
//        assertClose(0, tan(Angle<Self>(degrees: 0)))
//        assertClose(0.57735026918962576450914878050195745565, tan(Angle<Self>(degrees: 30)))
//        assertClose(1, tan(Angle<Self>(degrees: 45)))
//        assertClose(1.7320508075688772935274463415058723669, tan(Angle<Self>(degrees: 60)))
//        assertClose(-1.7320508075688772935274463415058723669, tan(Angle<Self>(degrees: 120)))
//        assertClose(-1, tan(Angle<Self>(degrees: 135)))
//        assertClose(-0.57735026918962576450914878050195745565, tan(Angle<Self>(degrees: 150)))
//        assertClose(0, tan(Angle<Self>(degrees: 180)))
//        assertClose(0, tan(Angle<Self>(degrees: 360)))
        
    }
}

final class AngleTests: XCTestCase {
    #if swift(>=5.3) && !(os(macOS) || os(iOS) && targetEnvironment(macCatalyst))
    func testFloat16() {
        if #available(iOS 14.0, watchOS 14.0, tvOS 7.0, *) {
            Float16.conversionBetweenRadiansAndDegreesChecks()
            Float16.trigonometricFunctionChecks()
            Float16.specialDegreesTrigonometricFunctionChecks()
        }
    }
    #endif
    
    func testFloat() {
        Float.conversionBetweenRadiansAndDegreesChecks()
        Float.trigonometricFunctionChecks()
        Float.specialDegreesTrigonometricFunctionChecks()
    }
    
    func testDouble() {
        Double.conversionBetweenRadiansAndDegreesChecks()
        Double.trigonometricFunctionChecks()
        Double.specialDegreesTrigonometricFunctionChecks()
    }
    
    #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    func testFloat80() {
        Float80.conversionBetweenRadiansAndDegreesChecks()
        Float80.trigonometricFunctionChecks()
        Float80.specialDegreesTrigonometricFunctionChecks()
    }
    #endif
}
