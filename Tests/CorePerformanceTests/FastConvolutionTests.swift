//===--- FastConvolutionTests.swift ----------------------------------*- swift -*-===//
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
import CorePerformance
import ComplexModule
import RealModule

/// return positive mod
func positive_mod<T: BinaryInteger>(_ x: T, _ m: T) -> T {
    let r = x % m
    return r < 0 ? r + m : r
}

func _cyclic_conv(_ signal: [Double], _ kernel: [Double]) -> [Double] {
    
    var result: [Double] = Array(repeating: 0, count: signal.count)
    
    for i in 0..<signal.count {
        
        var sum = 0.0
        
        for j in 0..<kernel.count {
            let k = positive_mod(i - j, signal.count)
            sum += kernel[j] * signal[k]
        }
        
        result[i] = sum
    }
    
    return result
}

func _cyclic_conv<T>(_ signal: [Complex<T>], _ kernel: [Complex<T>]) -> [Complex<T>] {
    
    var result: [Complex<T>] = Array(repeating: 0, count: signal.count)
    
    for i in 0..<signal.count {
        
        var sum: Complex<T> = 0
        
        for j in 0..<kernel.count {
            let k = positive_mod(i - j, signal.count)
            sum += kernel[j] * signal[k]
        }
        
        result[i] = sum
    }
    
    return result
}

final class FastConvolutionTests: XCTestCase {
    
    let accuracy = 0.00000001
    
    func testFFTConv() {
        
        for log2n in 1...8 {
            
            let length = 1 << log2n
            
            let signal = (0..<length).map { _ in Double.random(in: -1...1) }
            let kernel = (0..<length).map { _ in Double.random(in: -1...1) }
            var output: [Double] = Array(repeating: 0, count: signal.count)
            var temp: [Double] = Array(repeating: 0, count: signal.count)
            
            _fft_conv(log2n, signal, 1, kernel, 1, &output, 1, &temp, 1)
            
            let check = _cyclic_conv(signal, kernel)
            
            for i in 0..<output.count {
                XCTAssertEqual(check[i], output[i], accuracy: accuracy)
            }
        }
    }
    
    func testFFTConvComplex() {
        
        for log2n in 1...8 {
            
            let length = 1 << log2n
            
            let sreal = (0..<length).map { _ in Double.random(in: -1...1) }
            let simag = (0..<length).map { _ in Double.random(in: -1...1) }
            let kreal = (0..<length).map { _ in Double.random(in: -1...1) }
            let kimag = (0..<length).map { _ in Double.random(in: -1...1) }
            var oreal: [Double] = Array(repeating: 0, count: sreal.count)
            var oimag: [Double] = Array(repeating: 0, count: simag.count)
            var treal: [Double] = Array(repeating: 0, count: kreal.count)
            var timag: [Double] = Array(repeating: 0, count: kimag.count)
            
            _fft_conv(log2n, sreal, simag, 1, kreal, kimag, 1, &oreal, &oimag, 1, &treal, &timag, 1)
            
            let signal = zip(sreal, simag).map { Complex($0, $1) }
            let kernel = zip(kreal, kimag).map { Complex($0, $1) }
            let check = _cyclic_conv(signal, kernel)
            
            for i in 0..<oreal.count {
                XCTAssertEqual(check[i].real, oreal[i], accuracy: accuracy)
                XCTAssertEqual(check[i].imaginary, oimag[i], accuracy: accuracy)
            }
        }
    }
}
