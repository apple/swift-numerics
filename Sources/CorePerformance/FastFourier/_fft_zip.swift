//===--- _fft_zip.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule

/// Performs a Complex to Complex in-place discrete fourier transform.
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
/// - complexity: O(n log2(n))
///
/// - parameters:
///   - log2n: The base 2 exponent of the number of elements to process.
///   - real: Real part of complex output vector.
///   - imag: Imaginary part of complex output vector.
///   - stride: Stride between elements in `real` and `imag`.
///   - direction: Forward or inverse directional.
@_transparent
public func _fft_zip<T: Real & BinaryFloatingPoint>(_ log2n: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int, _ direction: FFTDirection) {
    switch direction {
    case .forward:
        
        // perform the forward transform.
        _fft_zip_imp(log2n, real, imag, stride)
        
    case .inverse:
        
        // we can perform the inverse transform by swapping the real and imaginary.
        _fft_zip_imp(log2n, imag, real, stride)
    }
}

@inlinable
func _fft_zip_imp<T: Real & BinaryFloatingPoint>(_ log2n: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) {
    
    switch log2n {
        
    case 0: break
        
    case 1:
        _fft_zop_imp_2(real, imag, stride, real, imag, stride)
    case 2:
        _fft_zop_imp_4(real, imag, stride, real, imag, stride)
    case 3:
        _fft_zop_imp_8(real, imag, stride, real, imag, stride)
        
    default:
        let count = 1 << log2n
        
        do {
            let offset = Int.bitWidth - log2n
            var _real = real
            var _imag = imag
            for i in 1..<count - 1 {
                let _i = Int(UInt(i).bit_reverse >> offset)
                _real += stride
                _imag += stride
                if i < _i {
                    swap(&_real.pointee, &real[_i * stride])
                    swap(&_imag.pointee, &imag[_i * stride])
                }
            }
        }
        
        _fft_zip_reordered_imp(log2n, real, imag, stride)
    }
}

@inlinable
@inline(__always)
func _fft_zip_reordered_imp<T: Real & BinaryFloatingPoint>(_ log2n: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) {
    
    let count = 1 << log2n
    
    do {
        var _r = real
        var _i = imag
        let m_stride = stride << 3
        for _ in Swift.stride(from: 0, to: count, by: 8) {
            _fft_zop_reordered_imp_8(_r, _i, stride)
            _r += m_stride
            _i += m_stride
        }
    }
    
    for s in 3..<log2n {
        
        let m = 2 << s
        let n = 1 << s
        
        let angle = -T.pi / T(n)
        let _cos = T.cos(angle)
        let _sin = T.sin(angle)
        
        let m_stride = m * stride
        let n_stride = n * stride
        
        var r1 = real
        var i1 = imag
        
        for _ in Swift.stride(from: 0, to: count, by: m) {
            
            var _cos1 = 1 as T
            var _sin1 = 0 as T
            
            var _r1 = r1
            var _i1 = i1
            var _r2 = r1 + n_stride
            var _i2 = i1 + n_stride
            
            for _ in 0..<n {
                
                let ur = _r1.pointee
                let ui = _i1.pointee
                let vr = _r2.pointee
                let vi = _i2.pointee
                
                let vrc = vr * _cos1
                let vic = vi * _cos1
                let vrs = vr * _sin1
                let vis = vi * _sin1
                
                let _c = _cos * _cos1 - _sin * _sin1
                let _s = _cos * _sin1 + _sin * _cos1
                _cos1 = _c
                _sin1 = _s
                
                _r1.pointee = ur + vrc - vis
                _i1.pointee = ui + vrs + vic
                _r2.pointee = ur - vrc + vis
                _i2.pointee = ui - vrs - vic
                
                _r1 += stride
                _i1 += stride
                _r2 += stride
                _i2 += stride
            }
            
            r1 += m_stride
            i1 += m_stride
        }
    }
}
