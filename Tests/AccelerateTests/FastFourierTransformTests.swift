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
    
    func test_vDSP_fft_zrop_2() {
        
        let in_real: [Double] = [1, 2]
        let in_imag: [Double] = [0, 0]
        
        var out_real: [Double] = Array(repeating: 0, count: 1)
        var out_imag: [Double] = Array(repeating: 0, count: 1)
        
        vDSP_fft_zrop(1, in_real, 1, &out_real, &out_imag, 1)
        
        var check = _FDFT(zip(in_real, in_imag).map(Complex.init))
        
        // we only have half length of frequency domain
        check[0] = Complex(check[0].real, check[1].real)
        
        for i in 0..<1 {
            XCTAssertEqual(check[i].real, out_real[i], accuracy: accuracy)
            XCTAssertEqual(check[i].imaginary, out_imag[i], accuracy: accuracy)
        }
    }
    
    func test_vDSP_fft_zop_forward_2() {
        
        let in_real: [Double] = [1, 2]
        let in_imag: [Double] = [3, 4]
        
        var out_real: [Double] = Array(repeating: 0, count: 2)
        var out_imag: [Double] = Array(repeating: 0, count: 2)
        
        vDSP_fft_zop(1, in_real, in_imag, 1, &out_real, &out_imag, 1, .forward)
        
        let check = _FDFT(zip(in_real, in_imag).map(Complex.init))
        
        for i in 0..<2 {
            XCTAssertEqual(check[i].real, out_real[i], accuracy: accuracy)
            XCTAssertEqual(check[i].imaginary, out_imag[i], accuracy: accuracy)
        }
    }
    
    func test_vDSP_fft_zop_inverse_2() {
        
        let in_real: [Double] = [1, 2]
        let in_imag: [Double] = [3, 4]
        
        var out_real: [Double] = Array(repeating: 0, count: 2)
        var out_imag: [Double] = Array(repeating: 0, count: 2)
        
        vDSP_fft_zop(1, in_real, in_imag, 1, &out_real, &out_imag, 1, .inverse)
        
        let check = _IDFT(zip(in_real, in_imag).map(Complex.init))
        
        for i in 0..<2 {
            XCTAssertEqual(check[i].real, out_real[i], accuracy: accuracy)
            XCTAssertEqual(check[i].imaginary, out_imag[i], accuracy: accuracy)
        }
    }
    
    func test_vDSP_fft_zrop_4() {
        
        let in_real: [Double] = [1, 2, 3, 4]
        let in_imag: [Double] = [0, 0, 0, 0]
        
        var out_real: [Double] = Array(repeating: 0, count: 2)
        var out_imag: [Double] = Array(repeating: 0, count: 2)
        
        vDSP_fft_zrop(2, in_real, 1, &out_real, &out_imag, 1)
        
        var check = _FDFT(zip(in_real, in_imag).map(Complex.init))
        
        // we only have half length of frequency domain
        check[0] = Complex(check[0].real, check[2].real)
        
        for i in 0..<2 {
            XCTAssertEqual(check[i].real, out_real[i], accuracy: accuracy)
            XCTAssertEqual(check[i].imaginary, out_imag[i], accuracy: accuracy)
        }
    }
    
    func test_vDSP_fft_zop_forward_4() {
        
        let in_real: [Double] = [1, 2, 3, 4]
        let in_imag: [Double] = [5, 6, 7, 8]
        
        var out_real: [Double] = Array(repeating: 0, count: 4)
        var out_imag: [Double] = Array(repeating: 0, count: 4)
        
        vDSP_fft_zop(2, in_real, in_imag, 1, &out_real, &out_imag, 1, .forward)
        
        let check = _FDFT(zip(in_real, in_imag).map(Complex.init))
        
        for i in 0..<4 {
            XCTAssertEqual(check[i].real, out_real[i], accuracy: accuracy)
            XCTAssertEqual(check[i].imaginary, out_imag[i], accuracy: accuracy)
        }
    }
    
    func test_vDSP_fft_zop_inverse_4() {
        
        let in_real: [Double] = [1, 2, 3, 4]
        let in_imag: [Double] = [5, 6, 7, 8]
        
        var out_real: [Double] = Array(repeating: 0, count: 4)
        var out_imag: [Double] = Array(repeating: 0, count: 4)
        
        vDSP_fft_zop(2, in_real, in_imag, 1, &out_real, &out_imag, 1, .inverse)
        
        let check = _IDFT(zip(in_real, in_imag).map(Complex.init))
        
        for i in 0..<4 {
            XCTAssertEqual(check[i].real, out_real[i], accuracy: accuracy)
            XCTAssertEqual(check[i].imaginary, out_imag[i], accuracy: accuracy)
        }
    }
    
    func test_vDSP_fft_zrop_8() {
        
        let in_real: [Double] = [1, 2, 3, 4, 5, 6, 7, 8]
        let in_imag: [Double] = [0, 0, 0, 0, 0, 0, 0, 0]
        
        var out_real: [Double] = Array(repeating: 0, count: 4)
        var out_imag: [Double] = Array(repeating: 0, count: 4)
        
        vDSP_fft_zrop(3, in_real, 1, &out_real, &out_imag, 1)
        
        var check = _FDFT(zip(in_real, in_imag).map(Complex.init))
        
        // we only have half length of frequency domain
        check[0] = Complex(check[0].real, check[4].real)
        
        for i in 0..<4 {
            XCTAssertEqual(check[i].real, out_real[i], accuracy: accuracy)
            XCTAssertEqual(check[i].imaginary, out_imag[i], accuracy: accuracy)
        }
    }
    
    func test_vDSP_fft_zop_forward_8() {
        
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
    
    func test_vDSP_fft_zop_inverse_8() {
        
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
    
    func test_vDSP_fft_zrop_16() {
        
        let in_real: [Double] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
        let in_imag: [Double] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        
        var out_real: [Double] = Array(repeating: 0, count: 8)
        var out_imag: [Double] = Array(repeating: 0, count: 8)
        
        vDSP_fft_zrop(4, in_real, 1, &out_real, &out_imag, 1)
        
        var check = _FDFT(zip(in_real, in_imag).map(Complex.init))
        
        // we only have half length of frequency domain
        check[0] = Complex(check[0].real, check[8].real)
        
        for i in 0..<8 {
            XCTAssertEqual(check[i].real, out_real[i], accuracy: accuracy)
            XCTAssertEqual(check[i].imaginary, out_imag[i], accuracy: accuracy)
        }
    }
    
    func test_vDSP_fft_zop_forward_16() {
        
        let in_real: [Double] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
        let in_imag: [Double] = [17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32]
        
        var out_real: [Double] = Array(repeating: 0, count: 16)
        var out_imag: [Double] = Array(repeating: 0, count: 16)
        
        vDSP_fft_zop(4, in_real, in_imag, 1, &out_real, &out_imag, 1, .forward)
        
        let check = _FDFT(zip(in_real, in_imag).map(Complex.init))
        
        for i in 0..<16 {
            XCTAssertEqual(check[i].real, out_real[i], accuracy: accuracy)
            XCTAssertEqual(check[i].imaginary, out_imag[i], accuracy: accuracy)
        }
    }
    
    func test_vDSP_fft_zop_inverse_16() {
        
        let in_real: [Double] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
        let in_imag: [Double] = [17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32]
        
        var out_real: [Double] = Array(repeating: 0, count: 16)
        var out_imag: [Double] = Array(repeating: 0, count: 16)
        
        vDSP_fft_zop(4, in_real, in_imag, 1, &out_real, &out_imag, 1, .inverse)
        
        let check = _IDFT(zip(in_real, in_imag).map(Complex.init))
        
        for i in 0..<16 {
            XCTAssertEqual(check[i].real, out_real[i], accuracy: accuracy)
            XCTAssertEqual(check[i].imaginary, out_imag[i], accuracy: accuracy)
        }
    }
}
