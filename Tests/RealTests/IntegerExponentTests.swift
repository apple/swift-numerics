//===--- IntegerExponentTests.swift ---------------------------*- swift -*-===//
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

internal extension Real where Self: FixedWidthFloatingPoint {
  
  static func testIntegerExponentCommon() {
    // TODO: replace with seedable generator, print seed.
    var g = SystemRandomNumberGenerator()
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
    // Generate some random test values that definitely overflow or
    // underflow; we want to be sure that we get the right ±0 or ±∞
    // result.
    for _ in 0 ..< 10 {
      let x = Self.random(in: 2 ..< 4, using: &g)
      let nLowerBound = 1 - Int(Self.leastNonzeroMagnitude.exponent)
      let n = Int.random(in: nLowerBound ..< .max, using: &g)
      let even = n & -2
      let odd = even | 1
      assertClose( .infinity, Self.pow(x, even))
      assertClose( .infinity, Self.pow(x, odd))
      assertClose( 0.0, Self.pow(1/x, even))
      assertClose( 0.0, Self.pow(1/x, odd))
      assertClose( .infinity, Self.pow(-x, even))
      assertClose(-.infinity, Self.pow(-x, odd))
      assertClose( 0.0, Self.pow(-1/x, even))
      assertClose(-0.0, Self.pow(-1/x, odd))
      assertClose( 0.0, Self.pow(x, -even))
      assertClose( 0.0, Self.pow(x, -odd))
      assertClose( .infinity, Self.pow(1/x, -even))
      assertClose( .infinity, Self.pow(1/x, -odd))
      assertClose( 0.0, Self.pow(-x, -even))
      assertClose(-0.0, Self.pow(-x, -odd))
      assertClose( .infinity, Self.pow(-1/x, -even))
      assertClose(-.infinity, Self.pow(-1/x, -odd))
    }
  }
  
  static func testIntegerExponentDoubleAndSmaller() {
    // max/min exponents, these always saturate, but this will reveal
    // errors in some implementations that one could try.
    let u = Self(1).nextUp
    let d = Self(1).nextDown
    assertClose( .infinity, Self.pow(-u,  Int.max - 1))
    assertClose( 0.0,       Self.pow(-d,  Int.max - 1))
    assertClose( 0.0,       Self.pow(-u, -Int.max + 1))
    assertClose( .infinity, Self.pow(-d, -Int.max + 1))
    assertClose(-.infinity, Self.pow(-u,  Int.max))
    assertClose(-0.0,       Self.pow(-d,  Int.max))
    assertClose(-0.0,       Self.pow(-u, -Int.max))
    assertClose(-.infinity, Self.pow(-d, -Int.max))
    assertClose( 0.0,       Self.pow(-u,  Int.min))
    assertClose( .infinity, Self.pow(-d,  Int.min))
  }
}

#if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension Float16 {
  static func testIntegerExponent() {
    testIntegerExponentCommon()
    testIntegerExponentDoubleAndSmaller()
    let u = Float16(1).nextUp
    let d = Float16(1).nextDown
    // Smallest exponents not exactly representable as Float16.
    assertClose(-7.3890572722436554354625993393835304, Float16.pow(-u, 0x801))
    assertClose(-0.3676100238077049750885141244927184, Float16.pow(-d, 0x801))
    // Exponents close to overflow boundary.
    assertClose( 65403.86633107, Float16.pow(-u, 11360))
    assertClose(-65467.73729429, Float16.pow(-u, 11361))
    assertClose( 65531.67063149, Float16.pow(-u, 11362))
    assertClose( 65487.96799785, Float16.pow(-d, -22706))
    assertClose(-65519.96016590, Float16.pow(-d, -22707))
    assertClose( 65551.96796276, Float16.pow(-d, -22708))
    // Exponents close to underflow boundary.
    assertClose( 5.966876499900e-8, Float16.pow(-u, -17042))
    assertClose(-5.961055156973e-8, Float16.pow(-u, -17043))
    assertClose( 5.955239493405e-8, Float16.pow(-u, -17044))
    assertClose( 5.964109628044e-8, Float16.pow(-d, 34060))
    assertClose(-5.961197465140e-8, Float16.pow(-d, 34061))
    assertClose( 5.958286724190e-8, Float16.pow(-d, 34062))
  }
}
#endif

extension Float {
  static func testIntegerExponent() {
    testIntegerExponentCommon()
    testIntegerExponentDoubleAndSmaller()
    let u = Float(1).nextUp
    let d = Float(1).nextDown
    // Smallest exponents not exactly representable as Float.
    assertClose(-7.3890560989306677280287919329569359, Float.pow(-u, 0x1000001))
    assertClose(-0.3678794082804575860056608283059288, Float.pow(-d, 0x1000001))
    // Exponents close to overflow boundary.
    assertClose(-3.4028231352500001570898203463449749e38, Float.pow(-u, 744261161))
    assertClose( 3.4028235408981285772043562848249166e38, Float.pow(-u, 744261162))
    assertClose(-3.4028239465463053543440887892352174e38, Float.pow(-u, 744261163))
    assertClose( 3.4028233551634475284795244782720072e38, Float.pow(-d, -1488522190))
    assertClose(-3.4028235579875369356575053576685267e38, Float.pow(-d, -1488522191))
    assertClose( 3.4028237608116384320940078199368685e38, Float.pow(-d, -1488522192))
    // Exponents close to underflow boundary.
    assertClose( 7.0064936491761438872280296737844625e-46, Float.pow(-u, -872181048))
    assertClose(-7.0064928139371132951305928725186420e-46, Float.pow(-u, -872181049))
    assertClose( 7.0064919786981822712727285793333389e-46, Float.pow(-u, -872181050))
    assertClose(-7.0064924138100205091278464932003585e-46, Float.pow(-d, 1744361943))
    assertClose( 7.0064919961905290625123586120258840e-46, Float.pow(-d, 1744361944))
    assertClose(-7.0064915785710625079583096856510544e-46, Float.pow(-d, 1744361945))
  }
}

extension Double {
  static func testIntegerExponent() {
    testIntegerExponentCommon()
    // Following tests only make sense (and are only necessary) on 64b platforms.
#if arch(arm64) || arch(x86_64)
    testIntegerExponentDoubleAndSmaller()
    let u: Double = 1.nextUp
    let d: Double = 1.nextDown
    // Smallest exponent not exactly representable as Double.
    assertClose(-7.3890560989306502272304274605750685, Double.pow(-u, 0x20000000000001))
    assertClose(-0.1353352832366126918939994949724833, Double.pow(-u, -0x20000000000001))
    assertClose(-0.3678794411714422603312898889458068, Double.pow(-d, 0x20000000000001))
    assertClose(-2.7182818284590456880451484776630468, Double.pow(-d, -0x20000000000001))
    // Exponents close to overflow boundary.
#if os(Windows)
    // TODO: It appears that the Windows pow doesn't carry enough precision
    // through the computation of log(1.nextDown) to produce a good result
    // for these cases; we'll want to provide a better implementation at some
    // point in the future. It's acceptable in the short term, however.
    let tol: Double = 360
#else
    let tol: Double = 16
#endif
    assertClose( 1.7976931348623151738531864721534215e308, Double.pow(-u, 3196577161300664268), allowedError: tol)
    assertClose(-1.7976931348623155730212483790972209e308, Double.pow(-u, 3196577161300664269), allowedError: tol)
    assertClose( 1.7976931348623159721893102860411089e308, Double.pow(-u, 3196577161300664270), allowedError: tol)  // warning expected on non-x86
    assertClose( 1.7976931348623157075547244136070910e308, Double.pow(-d, -6393154322601327474), allowedError: tol)
    assertClose(-1.7976931348623159071387553670790721e308, Double.pow(-d, -6393154322601327475), allowedError: tol) // warning expected on non-x86
    assertClose( 1.7976931348623161067227863205510754e308, Double.pow(-d, -6393154322601327476), allowedError: tol) // warning expected on non-x86
    // Exponents close to underflow boundary.
    assertClose( 2.4703282292062334560337346683707907e-324, Double.pow(-u, -3355781687888880946))
    assertClose(-2.4703282292062329075106789791206172e-324, Double.pow(-u, -3355781687888880947))
    assertClose( 2.4703282292062323589876232898705654e-324, Double.pow(-u, -3355781687888880948))
    assertClose(-2.4703282292062332640976590913373022e-324, Double.pow(-d, 6711563375777760775))
    assertClose( 2.4703282292062329898361312467121758e-324, Double.pow(-d, 6711563375777760776))
    assertClose(-2.4703282292062327155746034020870799e-324, Double.pow(-d, 6711563375777760777))
#endif
  }
}

final class IntegerExponentTests: XCTestCase {
  
  #if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
  func testFloat16() {
    if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
      Float16.testIntegerExponent()
    }
  }
  #endif
  
  func testFloat() {
    Float.testIntegerExponent()
  }
  
  func testDouble() {
    Double.testIntegerExponent()
  }
  
  #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
  func testFloat80() {
    Float80.testIntegerExponentCommon()
  }
  #endif
}
