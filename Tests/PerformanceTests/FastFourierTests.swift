//===--- FastFourierTests.swift ----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import Performance
import Complex
import Real

func _FDFT<T>(_ input: [T]) -> [Complex<T>] {
    
    let n = input.count
    
    let source = zip(input, Array(repeating: 0, count: n)).map { Complex($0, $1) }
    
    var result = _FDFT(source)
    
    // we only have half length of frequency domain
    result[0] = Complex(result[0].real, result[n/2].real)
    
    result.removeSubrange(n/2..<n)
    
    return result
}

func _FDFT<T>(_ input: [Complex<T>]) -> [Complex<T>] {
    
    let n = input.count
    
    var result: [Complex<T>] = Array(repeating: .zero, count: n)
    
    for i in 0..<n {
        for j in 0..<n {
            let twiddle = Complex(length: 1, phase: -2 * .pi * T(i * j) / T(n))
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
            let twiddle = Complex(length: 1, phase: 2 * .pi * T(i * j) / T(n))
            result[i] += input[j] * twiddle
        }
    }
    
    return result
}

final class FastFourierTests: XCTestCase {
    
    let accuracy = 0.00000001
    
    func testTypedFastFourier1() {
        
        let length = 1 << 8
        
        let input = (0..<length).map { _ in Complex(Double.random(in: -1...1), Double.random(in: -1...1)) }
        
        let output = FastFourier.transform(input, direction: .forward)
        
        let check = _FDFT(input)
        
        for i in 0..<length {
            XCTAssertEqual(check[i].real, output[i].real, accuracy: accuracy)
            XCTAssertEqual(check[i].imaginary, output[i].imaginary, accuracy: accuracy)
        }
    }
    
    func testTypedFastFourier2() {
        
        let length = 1 << 8
        
        let in_real: [Double] = (0..<length).map { _ in Double.random(in: -1...1) }
        let in_imag: [Double] = (0..<length).map { _ in Double.random(in: -1...1) }
        
        let (out_real, out_imag) = FastFourier.transform(in_real, in_imag, direction: .forward)
        
        let check = _FDFT(zip(in_real, in_imag).map { Complex($0, $1) })
        
        for i in 0..<length {
            XCTAssertEqual(check[i].real, out_real[i], accuracy: accuracy)
            XCTAssertEqual(check[i].imaginary, out_imag[i], accuracy: accuracy)
        }
    }
}
