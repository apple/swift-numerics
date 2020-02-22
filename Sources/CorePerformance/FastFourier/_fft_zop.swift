//===--- _fft_zop.swift ----------------------------------------*- swift -*-===//
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

/// Performs a Complex to Complex out-of-place discrete fourier transform.
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
///   - in_real: Real part of complex input vector.
///   - in_imag: Imaginary part of complex input vector.
///   - in_stride: Stride between elements in `in_real` and `in_imag`.
///   - out_real: Real part of complex output vector.
///   - out_imag: Imaginary part of complex output vector.
///   - out_stride: Stride between elements in `out_real` and `out_imag`.
///   - direction: Forward or inverse directional.
@_transparent
public func _fft_zop<T: Real & BinaryFloatingPoint>(_ log2n: Int, _ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int, _ direction: FFTDirection) {
    switch direction {
    case .forward:
        
        // perform the forward transform.
        _fft_zop_imp(log2n, in_real, in_imag, in_stride, out_real, out_imag, out_stride)
        
    case .inverse:
        
        // we can perform the inverse transform by swapping the real and imaginary.
        _fft_zop_imp(log2n, in_imag, in_real, in_stride, out_imag, out_real, out_stride)
    }
}

@inlinable
func _fft_zop_imp<T: Real & BinaryFloatingPoint>(_ log2n: Int, _ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    switch log2n {
        
    case 0:
        out_real.pointee = in_real.pointee
        out_imag.pointee = in_imag.pointee
        
    case 1:
        _fft_zop_imp_2(in_real, in_imag, in_stride, out_real, out_imag, out_stride)
    case 2:
        _fft_zop_imp_4(in_real, in_imag, in_stride, out_real, out_imag, out_stride)
    case 3:
        _fft_zop_imp_8(in_real, in_imag, in_stride, out_real, out_imag, out_stride)
        
    default:
        let length = 1 << log2n
        let half = length >> 1
        
        let oph_stride = half * out_stride
        var op_r = out_real
        var op_i = out_imag
        var oph_r = out_real + oph_stride
        var oph_i = out_imag + oph_stride
        
        _fft_zop_imp(log2n - 1, in_real, in_imag, in_stride << 1, op_r, op_i, out_stride)
        _fft_zop_imp(log2n - 1, in_real + in_stride, in_imag + in_stride, in_stride << 1, oph_r, oph_i, out_stride)
        
        let angle = -T.pi / T(half)
        let _cos = T.cos(angle)
        let _sin = T.sin(angle)
        var _cos1: T = 1
        var _sin1: T = 0
        for _ in 0..<half {
            let tpr = op_r.pointee
            let tpi = op_i.pointee
            let tphr = oph_r.pointee
            let tphi = oph_i.pointee
            let tphrc = tphr * _cos1
            let tphic = tphi * _cos1
            let tphrs = tphr * _sin1
            let tphis = tphi * _sin1
            let _c = _cos * _cos1 - _sin * _sin1
            let _s = _cos * _sin1 + _sin * _cos1
            _cos1 = _c
            _sin1 = _s
            op_r.pointee = tpr + tphrc - tphis
            op_i.pointee = tpi + tphrs + tphic
            oph_r.pointee = tpr - tphrc + tphis
            oph_i.pointee = tpi - tphrs - tphic
            op_r += out_stride
            op_i += out_stride
            oph_r += out_stride
            oph_i += out_stride
        }
    }
}
