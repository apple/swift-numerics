//===--- FastFourier.swift ----------------------------------------*- swift -*-===//
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

public enum FastFourier {
    
    public enum Direction {
        
        case forward
        
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
    public static func transform<U, T>(
        _ vector: U,
        direction: Direction
    ) -> U where U : PerformanceMutableBuffer, U.Element == Complex<T>, T : BinaryFloatingPoint {
        
        precondition(vector.count.isPower2)
        
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
    public static func transform<U>(
        _ real: U,
        _ imaginary: U,
        direction: Direction
    ) -> (real: U, imaginary: U) where U : PerformanceMutableBuffer, U.Element : Real, U.Element : BinaryFloatingPoint {
        
        precondition(real.count == imaginary.count)
        precondition(real.count.isPower2)
        
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

extension UnsafeBufferPointer {
    
    @inlinable
    @inline(__always)
    func _reboundToReal<T>(body: (UnsafeBufferPointer<T>) -> Void) where Element == Complex<T> {
        let raw_ptr = UnsafeRawBufferPointer(self)
        let bound_ptr = raw_ptr.bindMemory(to: T.self)
        defer { _ = raw_ptr.bindMemory(to: Complex<T>.self) }
        return body(bound_ptr)
    }
}

extension UnsafeMutableBufferPointer {
    
    @inlinable
    @inline(__always)
    func _reboundToReal<T>(body: (UnsafeMutableBufferPointer<T>) -> Void) where Element == Complex<T> {
        let raw_ptr = UnsafeMutableRawBufferPointer(self)
        let bound_ptr = raw_ptr.bindMemory(to: T.self)
        defer { _ = raw_ptr.bindMemory(to: Complex<T>.self) }
        return body(bound_ptr)
    }
}
