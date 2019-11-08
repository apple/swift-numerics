//===--- FastFourierTransformTests.swift ----------------------------------*- swift -*-===//
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
import Accelerate
import Complex
import Real

func _FDFT<T>(_ input: [Complex<T>]) -> [Complex<T>] {
    
    let n = input.count
    
    var result: [Complex<T>] = Array(repeating: .zero, count: n)
    
    for i in 0..<n {
        for j in 0..<n {
            let twiddle = Complex(length: 1, phase: -2 * .pi * T(i * j) / T(n))!
            result[i] += input[j] * twiddle
        }
    }
    
    return result
}

func _IDFT<T>(_ input: [Complex<T>]) -> [Complex<T>] {
    
    let n = input.count
    
    var result: [Complex<T>] = Array(repeating: .zero, count: n)
    
    for i in 0..<n {
        for j in 0..<n {
            let twiddle = Complex(length: 1, phase: 2 * .pi * T(i * j) / T(n))!
            result[i] += input[j] * twiddle
        }
    }
    
    return result
}

final class FastFourierTransformTests: XCTestCase {
    
    let accuracy = 0.00000001
    
    func test_vDSP_fft_zrop() {
        
        let in_real: [Double] = [1, 2, 3, 4, 5, 6, 7, 8]
        let in_imag: [Double] = [0, 0, 0, 0, 0, 0, 0, 0]
        
        var out_real: [Double] = Array(repeating: 0, count: 8)
        var out_imag: [Double] = Array(repeating: 0, count: 8)
        
        vDSP_fft_zrop(3, in_real, 1, &out_real, &out_imag, 1)
        
        var check = _FDFT(zip(in_real, in_imag).map(Complex.init))
        
        // we only have half length of frequency domain
        check[0] = Complex(check[0].real, check[4].real)
        
        for i in 0..<4 {
            XCTAssertEqual(check[i].real, out_real[i], accuracy: accuracy)
            XCTAssertEqual(check[i].imaginary, out_imag[i], accuracy: accuracy)
        }
    }
    
    func test_vDSP_fft_zop_forward() {
        
        let in_real: [Double] = [1, 2, 3, 4, 5, 6, 7, 8]
        let in_imag: [Double] = [9, 10, 11, 12, 13, 14, 15, 16]
        
        var out_real: [Double] = Array(repeating: 0, count: 8)
        var out_imag: [Double] = Array(repeating: 0, count: 8)
        
        vDSP_fft_zop(3, in_real, in_imag, 1, &out_real, &out_imag, 1, .forward)
        
        let check = _FDFT(zip(in_real, in_imag).map(Complex.init))
        
        for i in 0..<8 {
            XCTAssertEqual(check[i].real, out_real[i], accuracy: accuracy)
            XCTAssertEqual(check[i].imaginary, out_imag[i], accuracy: accuracy)
        }
    }
    
    func test_vDSP_fft_zop_inverse() {
        
        let in_real: [Double] = [1, 2, 3, 4, 5, 6, 7, 8]
        let in_imag: [Double] = [9, 10, 11, 12, 13, 14, 15, 16]
        
        var out_real: [Double] = Array(repeating: 0, count: 8)
        var out_imag: [Double] = Array(repeating: 0, count: 8)
        
        vDSP_fft_zop(3, in_real, in_imag, 1, &out_real, &out_imag, 1, .inverse)
        
        let check = _IDFT(zip(in_real, in_imag).map(Complex.init))
        
        for i in 0..<8 {
            XCTAssertEqual(check[i].real, out_real[i], accuracy: accuracy)
            XCTAssertEqual(check[i].imaginary, out_imag[i], accuracy: accuracy)
        }
    }
}
