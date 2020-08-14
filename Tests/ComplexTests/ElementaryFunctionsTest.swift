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
    let nums = [
        0.0/0.0, -1.0/0.0,-2.0, -1.0, -0.5, -0.0, +0.0, +0.5, +1.0, +2.0,+1.0/0.0
    ]
    typealias CD = Complex<Double>
    func testSC(_ S:(CD)->CD, _ C:(_CCD)->_CCD,
                _ skip:(Double,Double)->Bool = {_,_ in false} ){
        for r in nums {
            for i in nums {
                if skip(r, i) { continue }
                let lhs = S(Complex(r, i))
                let rhs = C(_CCD(real:r, imag:i))
                if lhs == rhs {
                    XCTAssert(true, "(\(r), \(i))")
                } else {
                    if rhs.real.isNaN || rhs.imag.isNaN {
                        XCTAssert(true, "(\(r), \(i))")
                    } else if lhs.length.isInfinite {
                        XCTAssert(lhs.length.isInfinite, "(\(r), \(i)), \(lhs), \(rhs))")
                    } else {
                        let err = relativeError(lhs, Complex(rhs.real, rhs.imag))
                        XCTAssert(err <= 4, "(\(r), \(i)), \(err), \(lhs), \(rhs)")
                    }
                }
            }
        }
    }
    // {fn($0)} to disambiguate
    func testExp()  { testSC({CD.exp($0)},     _cexp) }
    func testLog()  { testSC({CD.log($0)},     _clog) }
    func testSqrt() { testSC({CD.sqrt($0)},   _csqrt) }
    func testSin()  { testSC({CD.sin($0)},     _csin) }
    func testCos()  { testSC({CD.cos($0)},     _ccos) }
    func testTan()  { testSC({CD.tan($0)},     _ctan) { _,i in i.isInfinite }  }
    func testAsin() { testSC({CD.asin($0)},   _casin) { r,_ in 1.0 <= abs(r) } }
    func testAcos() { testSC({CD.acos($0)},   _cacos) { r,_ in 1.0 <= abs(r) } }
    func testAtan() { testSC({CD.atan($0)},   _catan) { _,i in abs(i) == 2.0 } }
    func testSinh() { testSC({CD.sinh($0)},   _csinh) }
    func testCosh() { testSC({CD.cosh($0)},   _ccosh) }
    func testTanh() { testSC({CD.tanh($0)},   _ctanh) { r,_ in r.isInfinite }  }
    func testAsinh(){ testSC({CD.asinh($0)}, _casinh) { _,i in abs(i) == 2.0 } }
    func testAcosh(){ testSC({CD.acosh($0)}, _cacosh) { r,_ in r < 1.0 } }
    func testAtanh(){ testSC({CD.atanh($0)}, _catanh) { r,_ in 1.0 <= abs(r) } }
    //
    typealias CF = Complex<Float>
    func testSCF(_ S:(CF)->CF, _ C:(_CCF)->_CCF,
                _ skip:(Float,Float)->Bool = {_,_ in false} ){
        let numsf = nums.map{ Float($0) }
        for r in numsf {
            for i in numsf {
                if skip(r, i) { continue }
                let lhs = S(Complex(r, i))
                let rhs = C(_CCF(real:r, imag:i))
                if lhs == rhs {
                    XCTAssert(true, "(\(r), \(i))")
                } else {
                    if rhs.real.isNaN || rhs.imag.isNaN {
                        XCTAssert(true, "(\(r), \(i))")
                    } else if lhs.length.isInfinite {
                        XCTAssert(lhs.length.isInfinite, "(\(r), \(i)), \(lhs), \(rhs))")
                    } else {
                        let err = relativeError(lhs, Complex(rhs.real, rhs.imag))
                        XCTAssert(err <= 8, "(\(r), \(i)), \(err), \(lhs), \(rhs)")
                    }
                }
            }
        }
    }
    func testExpf()  { testSCF({CF.exp($0)},     _cexpf) }
    func testLogf()  { testSCF({CF.log($0)},     _clogf) }
    func testSqrtf() { testSCF({CF.sqrt($0)},   _csqrtf) }
    func testSinf()  { testSCF({CF.sin($0)},     _csinf) }
    func testCosf()  { testSCF({CF.cos($0)},     _ccosf) }
    func testTanf()  { testSCF({CF.tan($0)},     _ctanf) { _,i in i.isInfinite }  }
    func testAsinf() { testSCF({CF.asin($0)},   _casinf) { r,_ in 1.0 <= abs(r) } }
    func testAcosf() { testSCF({CF.acos($0)},   _cacosf) { r,_ in 1.0 <= abs(r) } }
    func testAtanf() { testSCF({CF.atan($0)},   _catanf) { _,i in abs(i) == 2.0 } }
    func testSinhf() { testSCF({CF.sinh($0)},   _csinhf) }
    func testCoshf() { testSCF({CF.cosh($0)},   _ccoshf) }
    func testTanhf() { testSCF({CF.tanh($0)},   _ctanhf) { r,_ in r.isInfinite }  }
    func testAsinhf(){ testSCF({CF.asinh($0)}, _casinhf) { _,i in abs(i) == 2.0 } }
    func testAcoshf(){ testSCF({CF.acosh($0)}, _cacoshf) { r,_ in r < 1.0 } }
    func testAtanhf(){ testSCF({CF.atanh($0)}, _catanhf) { r,_ in 1.0 <= abs(r) } }
    //
}

