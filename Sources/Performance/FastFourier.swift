//===--- FastFourier.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import Real
import Complex
import CorePerformance

/// A namespace for fast fourier based algorithm.
public enum FastFourier {
    
    /// Fast Fourier transform directions.
    public enum Direction {
        
        /// Performs forward direction of fourier transform.
        case forward
        
        /// Performs inverse direction of fourier transform.
        case inverse
    }
    
}

extension FastFourier.Direction {
    
    var rawValue: FFTDirection {
        switch self {
        case .forward: return .forward
        case .inverse: return .inverse
        }
    }
}

extension FastFourier {
    
    /// Computes fast Fourier transform.
    ///
    /// This function behaves the same as the following
    ///
    /// ```swift
    /// let _2_PI = direction == .forward ? -2 * .pi : 2 * .pi
    ///
    /// for i in 0..<n {
    ///     for j in 0..<n {
    ///         let twiddle = Complex(length: 1, phase: _2_PI * T(i * j) / T(n))
    ///         output[i] += input[j] * twiddle
    ///     }
    /// }
    /// ```
    ///
    /// - precondition: The length of vector must be power of 2.
    ///
    /// - complexity: O(n log2(n))
    public static func transform<U, T>(
        _ vector: U,
        direction: Direction
    ) -> U where U : PerformanceMutableBuffer, U.Element == Complex<T>, T : BinaryFloatingPoint {
        
        precondition(vector.count.isPower2, "Invalid length of vector. The length of vector should be power of 2.")
        
        var vector = vector
        let count = vector.count
        
        vector.withUnsafeMutableBufferPointer { $0._reboundToReal { vector in
            
            guard let buffer = vector.baseAddress else { return }
            
            _fft_zip(log2(count), buffer, buffer + 1, 2, direction.rawValue)
            
            } }
        
        return vector
    }
    
}

extension FastFourier {
    
    /// Computes fast Fourier transform.
    ///
    /// This function behaves the same as the following
    ///
    /// ```swift
    /// let _2_PI = direction == .forward ? -2 * .pi : 2 * .pi
    ///
    /// for i in 0..<n {
    ///     for j in 0..<n {
    ///         let twiddle = Complex(length: 1, phase: _2_PI * T(i * j) / T(n))
    ///         output[i] += input[j] * twiddle
    ///     }
    /// }
    /// ```
    ///
    /// - precondition: The length of vector must be power of 2.
    ///
    /// - complexity: O(n log2(n))
    ///
    public static func transform<U>(
        _ real: U,
        _ imaginary: U,
        direction: Direction
    ) -> (real: U, imaginary: U) where U : PerformanceMutableBuffer, U.Element : Real & BinaryFloatingPoint {
        
        precondition(real.count == imaginary.count, "Invalid length of inputs. The length of inputs should be same.")
        precondition(real.count.isPower2, "Invalid length of vector. The length of vector should be power of 2.")
        
        var real = real
        var imaginary = imaginary
        let count = real.count
        
        real.withUnsafeMutableBufferPointer { real in
            
            guard let real = real.baseAddress else { return }
            
            imaginary.withUnsafeMutableBufferPointer { imaginary in
                
                guard let imaginary = imaginary.baseAddress else { return }
                
                _fft_zip(log2(count), real, imaginary, 1, direction.rawValue)
                
            }
        }
        
        return (real, imaginary)
    }
    
}
