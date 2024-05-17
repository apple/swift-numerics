//===--- ArithmeticTests.swift --------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import ComplexModule
import RealModule

func ulpsFromInfinity<T: Real>(_ a: T) -> T {
  (.greatestFiniteMagnitude - a) / .greatestFiniteMagnitude.ulp + 1
}

// TODO: improve this to be a general-purpose complex comparison with tolerance
func relativeError<T>(_ a: Complex<T>, _ b: Complex<T>) -> T {
  if a == b { return 0 }
  if a.isFinite && b.isFinite {
    let scale = max(a.magnitude, b.magnitude, T.leastNormalMagnitude).ulp
    return (a - b).magnitude / scale
  } else {
    if a.isFinite {
      return ulpsFromInfinity(a.magnitude)
    } else {
      return ulpsFromInfinity(b.magnitude)
    }
  }
}

func closeEnough<T: Real>(_ a: T, _ b: T, ulps allowed: T) -> Bool {
  let scale = max(a.magnitude, b.magnitude, T.leastNormalMagnitude).ulp
  return (a - b).magnitude <= allowed * scale
}

func checkMultiply<T>(
  _ a: Complex<T>, _ b: Complex<T>, expected: Complex<T>, ulps allowed: T
) -> Bool {
  let observed = a*b
  if observed == expected { return false }
  // Even if the expected result is finite, we allow overflow if
  // the two-norm of the expected result overflows.
  if !observed.isFinite && !expected.length.isFinite { return false }
  let rel = relativeError(observed, expected)
  guard rel <= allowed else {
    print("Over-large error in \(a)*\(b)")
    print("Expected: \(expected)\nObserved: \(observed)")
    print("Relative error was \(rel) (tolerance: \(allowed)).")
    return true
  }
  return false
}

func checkDivide<T>(
  _ a: Complex<T>, _ b: Complex<T>, expected: Complex<T>, ulps allowed: T
) -> Bool {
  let observed = a/b
  if observed == expected { return false }
  // Even if the expected result is finite, we allow overflow if
  // the two-norm of the expected result overflows.
  if !observed.isFinite && !expected.length.isFinite { return false }
  let rel = relativeError(observed, expected)
  guard rel <= allowed else {
    print("Over-large error in \(a)/\(b)")
    print("Expected: \(expected)\nObserved: \(observed)")
    print("Relative error was \(rel) (tolerance: \(allowed)).")
    return true
  }
  return false
}

final class ArithmeticTests: XCTestCase {
  
  struct Polar<T: Real> {
    let length: T
    let phase: T
  }
  
  func testPolar<T>(_ type: T.Type)
  where T: BinaryFloatingPoint, T: Real,
        T.Exponent: FixedWidthInteger, T.RawSignificand: FixedWidthInteger {
    // In order to support round-tripping from rectangular to polar coordinate
    // systems, as a special case phase can be non-finite when length is
    // either zero or infinity.
    XCTAssertEqual(Complex<T>(length: .zero, phase: .infinity), .zero)
    XCTAssertEqual(Complex<T>(length: .zero, phase:-.infinity), .zero)
    XCTAssertEqual(Complex<T>(length: .zero, phase: .nan     ), .zero)
    XCTAssertEqual(Complex<T>(length: .infinity, phase: .infinity), .infinity)
    XCTAssertEqual(Complex<T>(length: .infinity, phase:-.infinity), .infinity)
    XCTAssertEqual(Complex<T>(length: .infinity, phase: .nan     ), .infinity)
    XCTAssertEqual(Complex<T>(length:-.infinity, phase: .infinity), .infinity)
    XCTAssertEqual(Complex<T>(length:-.infinity, phase:-.infinity), .infinity)
    XCTAssertEqual(Complex<T>(length:-.infinity, phase: .nan     ), .infinity)
    
    let exponentRange =
    T.leastNormalMagnitude.exponent ... T.greatestFiniteMagnitude.exponent
    let inputs = (0..<100).map { _ in
      Polar(length: T(
        sign: .plus,
        exponent: T.Exponent.random(in: exponentRange),
        significand: T.random(in: 1 ..< 2)
      ), phase: T.random(in: -.pi ... .pi))
    }
    for p in inputs {
      // first test that each value can round-trip between rectangular and
      // polar coordinates with reasonable accuracy. We'll probably need to
      // relax this for some platforms (currently we're using the default
      // RNG, which means we don't get the same sequence of values each time;
      // this is good--more test coverage!--and bad, because without tight
      // bounds on every platform's libm, we can't get tight bounds on the
      // accuracy of these operations, so we need to relax them gradually).
      let z = Complex(length: p.length, phase: p.phase)
      if !closeEnough(z.length, p.length, ulps: 16) {
        print("p = \(p)\nz = \(z)\nz.length = \(z.length)")
        XCTFail()
      }
      if !closeEnough(z.phase, p.phase, ulps: 16) {
        print("p = \(p)\nz = \(z)\nz.phase = \(z.phase)")
        XCTFail()
      }
      // Complex(length: -r, phase: θ) = -Complex(length: r, phase: θ).
      let w = Complex(length: -p.length, phase: p.phase)
      if w != -z {
        print("p = \(p)\nw = \(w)\nz = \(z)")
        XCTFail()
      }
      XCTAssertEqual(w, -z)
      // if length*length is normal, it should be lengthSquared, up
      // to small error.
      if (p.length*p.length).isNormal {
        if !closeEnough(z.lengthSquared, p.length*p.length, ulps: 16) {
          print("p = \(p)\nz = \(z)\nz.lengthSquared = \(z.lengthSquared)")
          XCTFail()
        }
      }
      // Test reciprocal and normalized:
      let r = Complex(length: 1/p.length, phase: -p.phase)
      if r.isNormal {
        if relativeError(r, z.reciprocal!) > 16 {
          print("p = \(p)\nz = \(z)\nz.reciprocal = \(r)")
          XCTFail()
        }
      } else { XCTAssertNil(z.reciprocal) }
      let n = Complex(length: 1, phase: p.phase)
      if relativeError(n, z.normalized!) > 16 {
        print("p = \(p)\nz = \(z)\nz.normalized = \(n)")
        XCTFail()
      }
      
      // Now test multiplication and division using the polar inputs:
      for q in inputs {
        let w = Complex(length: q.length, phase: q.phase)
        var product = Complex(length: p.length, phase: p.phase + q.phase)
        product.real *= q.length
        product.imaginary *= q.length
        if checkMultiply(z, w, expected: product, ulps: 16) { XCTFail() }
        var quotient = Complex(length: p.length, phase: p.phase - q.phase)
        quotient.real /= q.length
        quotient.imaginary /= q.length
        if checkDivide(z, w, expected: quotient, ulps: 16) { XCTFail() }
      }
    }
  }
  
  func testPolar() {
#if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64)) && LONG_TESTS
    if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
      testPolar(Float16.self)
    }
#endif
    testPolar(Float.self)
    testPolar(Double.self)
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    testPolar(Float80.self)
#endif
  }
  
  func testBaudinSmith() {
    // A struct representing a test case from Baudin & Smith's
    // "A Robust Complex Division in Scilab".
    //
    // Their paper tests only a/b == c. These are also interesting cases for
    // testing a/c == b and a == b*c, so we run all three of those.
    // Additionally, B&S expect these all to be exactly equal, but that's only
    // true for a division operation satisfying a (perhaps) unrealistically
    // high precision requirement (see discussion in Arithmetic.swift).
    struct BaudinSmithCase {
      let a: Complex<Double>
      let b: Complex<Double>
      let c: Complex<Double>
      init(_ a: Complex<Double>, _ b: Complex<Double>, _ c: Complex<Double>) {
        self.a = a
        self.b = b
        self.c = c
      }
    }
    // The ten test cases from Baudin & Smith's paper. These only apply to
    // Double.
    let vectors: [BaudinSmithCase] = [
      BaudinSmithCase(Complex(1,1), Complex(1, 0x1p1023), Complex(0x1p-1023, -0x1p-1023)),
      BaudinSmithCase(Complex(1,1), Complex(0x1p-1023, 0x1p-1023), Complex(0x1p1023)),
      BaudinSmithCase(Complex(0x1p1023, 0x1p-1023), Complex(0x1p677, 0x1p-677),
                      Complex(0x1p346, -0x1p-1008)),
      BaudinSmithCase(Complex(0x1p1023, 0x1p1023), Complex(1, 1), Complex(0x1p1023)),
      BaudinSmithCase(Complex(0x1p1020, 0x1p-844), Complex(0x1p656, 0x1p-780),
                      Complex(0x1p364, -0x1p-1072)),
      BaudinSmithCase(Complex(0x1p-71, 0x1p1021), Complex(0x1p1001, 0x1p-323),
                      Complex(0x1p-1072, 0x1p20)),
      BaudinSmithCase(Complex(0x1p-347, 0x1p-54), Complex(0x1p-1037, 0x1p-1058),
                      Complex(3.8981256045591133e289, 8.174961907852353577e295)),
      BaudinSmithCase(Complex(0x1p-1074, 0x1p-1074), Complex(0x1p-1073, 0x1p-1074), Complex(0.6, 0.2)),
      BaudinSmithCase(Complex(0x1p1015, 0x1p-989), Complex(0x1p1023, 0x1p1023), Complex(0.001953125, -0.001953125)),
      BaudinSmithCase(Complex(0x1p-622, 0x1p-1071), Complex(0x1p-343, 0x1p-798),
                      Complex(1.02951151789360578e-84, 6.97145987515076231e-220)),
    ]
    for test in vectors {
      if checkDivide(test.a, test.b, expected: test.c, ulps: 1.0) { XCTFail() }
      if checkDivide(test.a, test.c, expected: test.b, ulps: 1.0) { XCTFail() }
      if checkMultiply(test.b, test.c, expected: test.a, ulps: 1.0) { XCTFail() }
    }
  }
  
  func testDivisionByZero() {
    XCTAssertFalse((Complex(0, 0) / Complex(0, 0)).isFinite)
    XCTAssertFalse((Complex(1, 1) / Complex(0, 0)).isFinite)
    XCTAssertFalse((Complex.infinity / Complex(0, 0)).isFinite)
    XCTAssertFalse((Complex.i / Complex(0, 0)).isFinite)
    
  }
  
#if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64)) && LONG_TESTS
  @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
  func testFloat16DivisionSemiExhaustive() {
    func complex(bitPattern: UInt32) -> Complex<Float16> {
      Complex(
        Float16(bitPattern: UInt16(truncatingIfNeeded: bitPattern)),
        Float16(bitPattern: UInt16(truncatingIfNeeded: bitPattern >> 16))
      )
    }
    for bits in 0 ... UInt32.max {
      let a = complex(bitPattern: bits)
      if bits & 0xfffff == 0 { print(a) }
      let b = complex(bitPattern: UInt32.random(in: 0 ... .max))
      var q = Complex<Float>(a)/Complex<Float>(b)
      if checkDivide(a, b, expected: Complex<Float16>(q), ulps: 4) { XCTFail() }
      q = Complex<Float>(b)/Complex<Float>(a)
      if checkDivide(b, a, expected: Complex<Float16>(q), ulps: 4) { XCTFail() }
    }
  }
#endif
}
