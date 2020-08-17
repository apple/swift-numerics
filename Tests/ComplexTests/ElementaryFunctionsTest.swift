//===--- ElementaryFunctionsTest.swift -------------------------*- swift -*-===//
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
import ComplexModule
import RealModule
import _CComplex

func == (_ lhs: Complex<Double>, _ rhs:_CCD) -> Bool {
    return lhs == Complex<Double>(rhs.real, rhs.imag);
}
func == (_ lhs: _CCD, _ rhs: Complex<Double>) -> Bool {
    return Complex<Double>(lhs.real, lhs.imag) == rhs;
}
func == (_ lhs: Complex<Float>, _ rhs:_CCF) -> Bool {
    return lhs == Complex<Float>(rhs.real, rhs.imag);
}
func == (_ lhs: _CCF, _ rhs: Complex<Float>) -> Bool {
    return Complex<Float>(lhs.real, lhs.imag) == rhs;
}

final class ElementaryFunctionsTests: XCTestCase {
    //
    // MARK: test Double
    //
    let dmin = Double.leastNonzeroMagnitude
    let dmax = Double.greatestFiniteMagnitude
    let doubles = ({
        // -0.0 and -.infinifty are not included because
        // > The Swift Numerics Complex type does not assign
        // any semantic meaning to the sign of zero and infinity
        ($0 + $0.map{ -$0 } + [0, .infinity, .nan]).sorted()
    })([
        Double.leastNonzeroMagnitude, Double.greatestFiniteMagnitude,
        0.0.nextUp, 0.25, 0.5, 1.0.nextDown, 1.0, 1.0.nextUp, 2.0, 4.0,
    ])
    typealias CD = Complex<Double>
    func testSC(_ S:(CD)->CD, _ C:(_CCD)->_CCD,
                _ skip:(Double,Double)->Bool = {_,_ in false} ){
        for r in doubles {
            for i in doubles {
                if skip(r, i) { continue }
                let lhs = S(Complex(r, i))
                let rhs = C(_CCD(real:r, imag:i))
                if lhs == rhs {
                    XCTAssert(true, "(\(r), \(i))")
                } else {
                    if rhs.real.isNaN || rhs.imag.isNaN {
                        XCTAssert(lhs.isZero, "(\(r), \(i)), \(lhs), \(rhs)")
                    } else if lhs.length.isInfinite {
                        XCTAssert(lhs.length.isInfinite, "(\(r), \(i)), \(lhs), \(rhs))")
                    } else {
                        let err = relativeError(lhs, Complex(rhs.real, rhs.imag))
                        XCTAssert(err <= 16, "(\(r), \(i)), \(err), \(lhs), \(rhs)")
                    }
                }
            }
        }
    }
    // {fn($0)} to disambiguate
    func testExp()  { testSC({CD.exp($0)},     _cexp) }
    func testExpM1()  {   // C99 does not have cexpm1 so we define one
        testSC({CD.expMinusOne($0)}, {
                let e = _cexp(_CCD(real:$0.real,imag:$0.imag))
                return _CCD(real:e.real-1.0, imag:e.imag)
        })
    }
    func testLog()  { testSC({CD.log($0)},     _clog) { r,_ in r <= .ulpOfOne } }
    func testLog1p() {   // C99 does not have clog1p so we define one
        testSC({CD.log(onePlus:$0)},
               { _clog(_CCD(real:$0.real+1.0, imag:$0.imag)) })
    }
    func testSqrt() { testSC({CD.sqrt($0)},   _csqrt) { r,_ in r <= .ulpOfOne } }
    func testSin()  { testSC({CD.sin($0)},     _csin) }
    func testCos()  { testSC({CD.cos($0)},     _ccos) }
    func testTan()  { testSC({CD.tan($0)},     _ctan) { _,i in dmax <= abs(i) } }
    func testAsin() { testSC({CD.asin($0)},   _casin) { r,_ in 1.0 <= abs(r)  } }
    func testAcos() { testSC({CD.acos($0)},   _cacos) { r,_ in 1.0 <= abs(r)  } }
    func testAtan() { testSC({CD.atan($0)},   _catan) { r,_ in r == 0 } }
    func testSinh() { testSC({CD.sinh($0)},   _csinh) }
    func testCosh() { testSC({CD.cosh($0)},   _ccosh) }
    func testTanh() { testSC({CD.tanh($0)},   _ctanh) { r,_ in dmax <= abs(r) } }
    func testAsinh(){ testSC({CD.asinh($0)}, _casinh) { r,_ in r == 0 } }
    func testAcosh(){ testSC({CD.acosh($0)}, _cacosh) { r,_ in r <= 1.0.nextUp } }
    func testAtanh(){ testSC({CD.atanh($0)}, _catanh) { r,_ in 1.0 <= abs(r) } }
    //
    // MARK: test Float
    //
    typealias CF = Complex<Float>
    let fmin = Float.leastNonzeroMagnitude
    let fmax = Float.greatestFiniteMagnitude
    let floats = ({
        ($0 + $0.map{ -$0 } + [0, .infinity, .nan]).sorted()
    })([
        Float.leastNonzeroMagnitude, Float.greatestFiniteMagnitude,
        Float(0.0).nextUp, 0.25, 0.5,
        Float(1.0).nextDown, 1.0, Float(1.0).nextUp,
        2.0, 4.0
    ] as [Float])
    func testSCF(_ S:(CF)->CF, _ C:(_CCF)->_CCF,
                _ skip:(Float,Float)->Bool = {_,_ in false} ){

        for r in floats {
            for i in floats {
                if skip(r, i) { continue }
                let lhs = S(Complex(r, i))
                let rhs = C(_CCF(real:r, imag:i))
                if lhs == rhs {
                    XCTAssert(true, "(\(r), \(i))")
                } else {
                    if rhs.real.isNaN || rhs.imag.isNaN {
                        XCTAssert(lhs.isZero, "(\(r), \(i)), \(lhs), \(rhs)")
                    } else if lhs.length.isInfinite {
                        XCTAssert(lhs.length.isInfinite, "(\(r), \(i)), \(lhs), \(rhs))")
                    } else {
                        let err = relativeError(lhs, Complex(rhs.real, rhs.imag))
                        XCTAssert(err <= 32, "(\(r), \(i)), \(err), \(lhs), \(rhs)")
                    }
                }
            }
        }
    }
    func testExpf()  { testSCF({CF.exp($0)},     _cexpf) }
    func testExpM1f()  {   // C99 does not have cexpm1f so we define one
        testSCF({CF.expMinusOne($0)}, {
                let e = _cexpf(_CCF(real:$0.real,imag:$0.imag))
                return _CCF(real:e.real-1.0, imag:e.imag)
        })
    }
    func testLogf()  { testSCF({CF.log($0)},     _clogf) { r,_ in r <= .ulpOfOne } }
    func testLog1pf(){   // C99 does not have clog1pf so we define one
        testSCF({CF.log(onePlus:$0)},
               {_clogf(_CCF(real:$0.real+1.0, imag:$0.imag)) })
    }
    func testSqrtf() { testSCF({CF.sqrt($0)},   _csqrtf) { r,_ in r <= .ulpOfOne } }
    func testSinf()  { testSCF({CF.sin($0)},     _csinf) }
    func testCosf()  { testSCF({CF.cos($0)},     _ccosf) }
    func testTanf()  { testSCF({CF.tan($0)},     _ctanf) { _,i in fmax <= abs(i) } }
    func testAsinf() { testSCF({CF.asin($0)},   _casinf) { r,_ in 1.0 <= abs(r) }  }
    func testAcosf() { testSCF({CF.acos($0)},   _cacosf) { r,_ in 1.0 <= abs(r) }  }
    func testAtanf() { testSCF({CF.atan($0)},   _catanf) { r,_ in r == 0 } }
    func testSinhf() { testSCF({CF.sinh($0)},   _csinhf) }
    func testCoshf() { testSCF({CF.cosh($0)},   _ccoshf) }
    func testTanhf() { testSCF({CF.tanh($0)},   _ctanhf) { r,_ in fmax <= abs(r) } }
    func testAsinhf(){ testSCF({CF.asinh($0)}, _casinhf) { r,_ in r == 0 } }
    func testAcoshf(){ testSCF({CF.acosh($0)}, _cacoshf) { r,_ in r <= Float(1.0).nextUp } }
    func testAtanhf(){ testSCF({CF.atanh($0)}, _catanhf) { r,_ in 1.0 <= abs(r) } }
    //
}

