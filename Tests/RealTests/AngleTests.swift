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
    
    static func inverseTrigonometricFunctionChecks() {
        XCTAssertEqual(0, Angle<Self>.acos(1).degrees)
        XCTAssertEqual(30, Angle<Self>.acos(sqrt(3)/2).degrees)
        XCTAssertEqual(45, Angle<Self>.acos(sqrt(2)/2).degrees)
        XCTAssertEqual(60, Angle<Self>.acos(0.5).degrees)
        XCTAssertEqual(90, Angle<Self>.acos(0).degrees)
        XCTAssertEqual(120, Angle<Self>.acos(-0.5).degrees)
        XCTAssertEqual(135, Angle<Self>.acos(-sqrt(2)/2).degrees)
        XCTAssertEqual(150, Angle<Self>.acos(-sqrt(3)/2).degrees)
        XCTAssertEqual(180, Angle<Self>.acos(-1).degrees)
        
        XCTAssertEqual(-90, Angle<Self>.asin(-1).degrees)
        XCTAssertEqual(-60, Angle<Self>.asin(-sqrt(3)/2).degrees)
        XCTAssertEqual(-45, Angle<Self>.asin(-sqrt(2)/2).degrees)
        XCTAssertEqual(-30, Angle<Self>.asin(-0.5).degrees)
        XCTAssertEqual(0, Angle<Self>.asin(0).degrees)
        XCTAssertEqual(30, Angle<Self>.asin(0.5).degrees)
        XCTAssertEqual(45, Angle<Self>.asin(sqrt(2)/2).degrees)
        XCTAssertEqual(60, Angle<Self>.asin(sqrt(3)/2).degrees)
        XCTAssertEqual(90, Angle<Self>.asin(1).degrees)
        
        XCTAssertEqual(-90, Angle<Self>.atan(-.infinity).degrees)
        XCTAssertEqual(-60, Angle<Self>.atan(-sqrt(3)).degrees)
        XCTAssertEqual(-45, Angle<Self>.atan(-1).degrees)
        XCTAssertEqual(-30, Angle<Self>.atan(-sqrt(3)/3).degrees)
        XCTAssertEqual(0, Angle<Self>.atan(0).degrees)
        XCTAssertEqual(30, Angle<Self>.atan(sqrt(3)/3).degrees)
        XCTAssertEqual(45, Angle<Self>.atan(1).degrees)
        XCTAssertEqual(60, Angle<Self>.atan(sqrt(3)).degrees)
        XCTAssertEqual(90, Angle<Self>.atan(.infinity).degrees)
        
        XCTAssertEqual(-150, Angle<Self>.atan2(y:-sqrt(3), x:-3).degrees)
        XCTAssertEqual(-135, Angle<Self>.atan2(y:-1, x:-1).degrees)
        XCTAssertEqual(-120, Angle<Self>.atan2(y:-sqrt(3), x:-1).degrees)
        XCTAssertEqual(-90, Angle<Self>.atan2(y:-1, x:0).degrees)
        XCTAssertEqual(-60, Angle<Self>.atan2(y:-sqrt(3), x:1).degrees)
        XCTAssertEqual(-45, Angle<Self>.atan2(y:-1, x:1).degrees)
        XCTAssertEqual(-30, Angle<Self>.atan2(y:-sqrt(3), x:3).degrees)
        XCTAssertEqual(0, Angle<Self>.atan2(y:0, x:1).degrees)
        XCTAssertEqual(30, Angle<Self>.atan2(y:sqrt(3), x:3).degrees)
        XCTAssertEqual(45, Angle<Self>.atan2(y:1, x:1).degrees)
        XCTAssertEqual(60, Angle<Self>.atan2(y:sqrt(3), x:1).degrees)
        XCTAssertEqual(90, Angle<Self>.atan2(y:1, x:0).degrees)
        XCTAssertEqual(120, Angle<Self>.atan2(y:sqrt(3), x:-1).degrees)
        XCTAssertEqual(135, Angle<Self>.atan2(y:1, x:-1).degrees)
        XCTAssertEqual(150, Angle<Self>.atan2(y:sqrt(3), x:-3).degrees)
        XCTAssertEqual(180, Angle<Self>.atan2(y:0, x:-1).degrees)
        
        assertClose(1.1863995522992575361931268186727044683, Angle<Self>.acos(0.375).radians)
        assertClose(0.3843967744956390830381948729670469737, Angle<Self>.asin(0.375).radians)
        assertClose(0.3587706702705722203959200639264604997, Angle<Self>.atan(0.375).radians)
        assertClose(0.54041950027058415544357836460859991,   Angle<Self>.atan2(y: 0.375, x: 0.625).radians)
    }

    static func trigonometricFunctionChecks() {
        XCTAssertEqual(1, cos(Angle<Self>(degrees: -360)))
        XCTAssertEqual(0, cos(Angle<Self>(degrees: -270)))
        XCTAssertEqual(-1, cos(Angle<Self>(degrees: -180)))
        assertClose(-0.86602540378443864676372317075293618347, cos(Angle<Self>(degrees: -150)))
        assertClose(-0.70710678118654752440084436210484903929, cos(Angle<Self>(degrees: -135)))
        assertClose(-0.5, cos(Angle<Self>(degrees: -120)))
        XCTAssertEqual(0, cos(Angle<Self>(degrees: -90)))
        assertClose(0.5, cos(Angle<Self>(degrees: -60)))
        assertClose(0.70710678118654752440084436210484903929, cos(Angle<Self>(degrees: -45)))
        assertClose(0.86602540378443864676372317075293618347, cos(Angle<Self>(degrees: -30)))
        XCTAssertEqual(1, cos(Angle<Self>(degrees: 0)))
        assertClose(0.86602540378443864676372317075293618347, cos(Angle<Self>(degrees: 30)))
        assertClose(0.70710678118654752440084436210484903929, cos(Angle<Self>(degrees: 45)))
        assertClose(0.5, cos(Angle<Self>(degrees: 60)))
        XCTAssertEqual(0, cos(Angle<Self>(degrees: 90)))
        assertClose(-0.5, cos(Angle<Self>(degrees: 120)))
        assertClose(-0.70710678118654752440084436210484903929, cos(Angle<Self>(degrees: 135)))
        assertClose(-0.86602540378443864676372317075293618347, cos(Angle<Self>(degrees: 150)))
        XCTAssertEqual(-1, cos(Angle<Self>(degrees: 180)))
        XCTAssertEqual(0, cos(Angle<Self>(degrees: 270)))
        XCTAssertEqual(1, cos(Angle<Self>(degrees: 360)))

        XCTAssertEqual(0, sin(Angle<Self>(degrees: -360)))
        XCTAssertEqual(1, sin(Angle<Self>(degrees: -270)))
        XCTAssertEqual(0, sin(Angle<Self>(degrees: -180)))
        assertClose(-0.5, sin(Angle<Self>(degrees: -150)))
        assertClose(-0.70710678118654752440084436210484903929, sin(Angle<Self>(degrees: -135)))
        assertClose(-0.86602540378443864676372317075293618347, sin(Angle<Self>(degrees: -120)))
        XCTAssertEqual(-1, sin(Angle<Self>(degrees: -90)))
        assertClose(-0.86602540378443864676372317075293618347, sin(Angle<Self>(degrees: -60)))
        assertClose(-0.70710678118654752440084436210484903929, sin(Angle<Self>(degrees: -45)))
        assertClose(-0.5, sin(Angle<Self>(degrees: -30)))
        XCTAssertEqual(0, sin(Angle<Self>(degrees: 0)))
        assertClose(0.5, sin(Angle<Self>(degrees: 30)))
        assertClose(0.70710678118654752440084436210484903929, sin(Angle<Self>(degrees: 45)))
        assertClose(0.86602540378443864676372317075293618347, sin(Angle<Self>(degrees: 60)))
        XCTAssertEqual(1, sin(Angle<Self>(degrees: 90)))
        assertClose(0.86602540378443864676372317075293618347, sin(Angle<Self>(degrees: 120)))
        assertClose(0.70710678118654752440084436210484903929, sin(Angle<Self>(degrees: 135)))
        assertClose(0.5, sin(Angle<Self>(degrees: 150)))
        XCTAssertEqual(0, sin(Angle<Self>(degrees: 180)))
        XCTAssertEqual(-1, sin(Angle<Self>(degrees: 270)))
        XCTAssertEqual(0, sin(Angle<Self>(degrees: 360)))

        XCTAssertEqual(0, tan(Angle<Self>(degrees: -360)))
        XCTAssertEqual(.infinity, tan(Angle<Self>(degrees: -270)))
        XCTAssertEqual(0, tan(Angle<Self>(degrees: -180)))
        assertClose(0.57735026918962576450914878050195745565, tan(Angle<Self>(degrees: -150)))
        XCTAssertEqual(1, tan(Angle<Self>(degrees: -135)))
        assertClose(1.7320508075688772935274463415058723669, tan(Angle<Self>(degrees: -120)))
        XCTAssertEqual(-.infinity, tan(Angle<Self>(degrees: -90)))
        assertClose(-1.7320508075688772935274463415058723669, tan(Angle<Self>(degrees: -60)))
        XCTAssertEqual(-1, tan(Angle<Self>(degrees: -45)))
        assertClose(-0.57735026918962576450914878050195745565, tan(Angle<Self>(degrees: -30)))
        XCTAssertEqual(0, tan(Angle<Self>(degrees: 0)))
        assertClose(0.57735026918962576450914878050195745565, tan(Angle<Self>(degrees: 30)))
        XCTAssertEqual(1, tan(Angle<Self>(degrees: 45)))
        assertClose(1.7320508075688772935274463415058723669, tan(Angle<Self>(degrees: 60)))
        XCTAssertEqual(.infinity, tan(Angle<Self>(degrees: 90)))
        assertClose(-1.7320508075688772935274463415058723669, tan(Angle<Self>(degrees: 120)))
        XCTAssertEqual(-1, tan(Angle<Self>(degrees: 135)))
        assertClose(-0.57735026918962576450914878050195745565, tan(Angle<Self>(degrees: 150)))
        XCTAssertEqual(0, tan(Angle<Self>(degrees: 180)))
        XCTAssertEqual(-.infinity, tan(Angle<Self>(degrees: 270)))
        XCTAssertEqual(0, tan(Angle<Self>(degrees: 360)))
        
        assertClose(0.9305076219123142911494767922295555080, cos(Angle<Self>(radians: 0.375)))
        assertClose(0.3662725290860475613729093517162641571, sin(Angle<Self>(radians: 0.375)))
        assertClose(0.3936265759256327582294137871012180981, tan(Angle<Self>(radians: 0.375)))
    }

    static func additiveArithmeticTests() {
        let angle1 = Angle<Self>(degrees: 90)
        let angle2 = Angle<Self>(radians: .pi)
        let sum = angle1 + angle2
        XCTAssertEqual(270, sum.degrees)
        XCTAssertEqual(3 * .pi / 2, sum.radians)
        XCTAssertEqual(360, (sum + angle1).degrees)
        XCTAssertEqual(2 * .pi, (sum + angle1).radians)
        var angle = Angle(degrees: 30)
        assertClose(50, (angle + Angle(degrees: 20)).degrees)
        assertClose(10, (angle - Angle(degrees: 20)).degrees)
        XCTAssertEqual(Angle(degrees: 60), angle * 2)
        XCTAssertEqual(Angle(degrees: 60), 2 * angle)
        XCTAssertEqual(Angle(degrees: 15), angle / 2)
        angle += Angle(degrees: 10)
        XCTAssertEqual(Angle(degrees: 40), angle)
        angle -= Angle(degrees: 20)
        XCTAssertEqual(Angle(degrees: 20), angle)
        angle *= 3
        XCTAssertEqual(Angle(degrees: 60), angle)
        angle /= 6
        XCTAssertEqual(Angle(degrees: 10), angle)
    }
//
//    static func rangeContainmentTests() {
//        let angle = Angle(degrees: 30)
//        XCTAssertTrue(angle.contained(in: Angle(degrees: 10)...Angle(degrees: 40)))
//        XCTAssertTrue(angle.contained(in: Angle(degrees: 10)...Angle(degrees: 30)))
//        XCTAssertTrue(angle.contained(in: Angle(degrees: 30)...Angle(degrees: 40)))
//        XCTAssertFalse(angle.contained(in: Angle(degrees: 10)...Angle(degrees: 20)))
//        XCTAssertFalse(angle.contained(in: Angle(degrees: 50)...Angle(degrees: 60)))
//        XCTAssertTrue(angle.contained(in: Angle(degrees: 30)..<Angle(degrees: 40)))
//        XCTAssertFalse(angle.contained(in: Angle(degrees: 10)..<Angle(degrees: 30)))
//        XCTAssertTrue(angle.contained(in: Angle(degrees: 10)..<Angle(degrees: 40)))
//    }
}

final class AngleTests: XCTestCase {
    private func execute<T: Real & BinaryFloatingPoint>(`for` Type: T.Type) {
        Type.conversionBetweenRadiansAndDegreesChecks()
        Type.inverseTrigonometricFunctionChecks()
        Type.trigonometricFunctionChecks()
        Type.additiveArithmeticTests()
//        Type.rangeContainmentTests()
    }
    
    
    #if swift(>=5.3) && !(os(macOS) || os(iOS) && targetEnvironment(macCatalyst))
    func testFloat16() {
        if #available(iOS 14.0, watchOS 14.0, tvOS 7.0, *) {
            execute(for: Float16.self)
        }
    }
    #endif
    
    func testFloat() {
        execute(for: Float.self)
    }
    
    func testDouble() {
        execute(for: Double.self)
    }
    
    #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    func testFloat80() {
        execute(for: Float80.self)
    }
    #endif
}
