//===--- Convolution.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import Real
import Complex
import CorePerformance

extension FastFourier {
    
    /// Performs a fast fourier based cyclic convolution.
    public static func convolve<U, V>(
        _ vector: U,
        withKernel kernel: V
    ) -> [U.Element] where U : PerformanceBuffer, V : PerformanceBuffer, U.Element : Real & BinaryFloatingPoint, U.Element == V.Element {
        
        precondition(vector.count == kernel.count)
        precondition(vector.count.isPower2)
        
        let count = vector.count
        var output: [U.Element] = Array(repeating: 0, count: count)
        var temp: [U.Element] = Array(repeating: 0, count: count)
        
        vector.withUnsafeBufferPointer { vector in
            
            guard let vector = vector.baseAddress else { return }
            
            kernel.withUnsafeBufferPointer { kernel in
                
                guard let kernel = kernel.baseAddress else { return }
                
                output.withUnsafeMutableBufferPointer { output in
                    
                    guard let output = output.baseAddress else { return }
                    
                    temp.withUnsafeMutableBufferPointer { temp in
                        
                        guard let temp = temp.baseAddress else { return }
                        
                        _fft_conv(log2(count), vector, 1, kernel, 1, output, 1, temp, 1)
                        
                    }
                }
            }
        }
        
        return output
    }
    
    /// Performs a fast fourier based cyclic convolution.
    public static func convolve<T, U, V>(
        _ vector: U,
        withKernel kernel: V
    ) -> [Complex<T>] where U : PerformanceBuffer, V : PerformanceBuffer, T : BinaryFloatingPoint, U.Element == Complex<T>, V.Element == Complex<T> {
        
        precondition(vector.count == kernel.count)
        precondition(vector.count.isPower2)
        
        let count = vector.count
        var output: [Complex<T>] = Array(repeating: 0, count: count)
        var temp: [Complex<T>] = Array(repeating: 0, count: count)
        
        vector.withUnsafeBufferPointer { $0._reboundToReal { vector in
            
            guard let vector = vector.baseAddress else { return }
            
            kernel.withUnsafeBufferPointer { $0._reboundToReal { kernel in
                
                guard let kernel = kernel.baseAddress else { return }
                
                output.withUnsafeMutableBufferPointer { $0._reboundToReal { output in
                    
                    guard let output = output.baseAddress else { return }
                    
                    temp.withUnsafeMutableBufferPointer { $0._reboundToReal { temp in
                        
                        guard let temp = temp.baseAddress else { return }
                        
                        _fft_conv(log2(count), vector, vector + 1, 2, kernel, kernel + 1, 2, output, output + 1, 2, temp, temp + 1, 2)
                        
                        } }
                    } }
                } }
            } }
        
        return output
    }
    
}
