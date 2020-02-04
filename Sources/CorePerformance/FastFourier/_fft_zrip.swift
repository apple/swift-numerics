//===--- _fft_zrip.swift ----------------------------------------*- swift -*-===//
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

/// Performs a Real to Complex out-of-place discrete fourier transform. This function requires/results the first half of frequency domain only.
///
/// - complexity: O(n log2(n))
///
/// - parameters:
///   - log2n: The base 2 exponent of the number of elements to process.
///   - real:
///     - For input:
///       The even part of elements of real input vector when performing forward transform. Otherwise, this is the real part of complex input vector.
///     - For output:
///       The real part of complex output vector when performing forward transform. Otherwise, this is the even part of elements of real output vector.
///   - imag:
///     - For input:
///       The odd part of elements of real input vector when performing forward transform. Otherwise, this is the imaginary part of complex input vector.
///     - For output:
///       The imaginary part of complex output vector when performing forward transform. Otherwise, this is the odd part of elements of real output vector.
///   - stride: Stride between elements in `real` and `imag`.
///   - direction: Forward or inverse directional.
@inlinable
@inline(__always)
public func _fft_zrip<T: Real & BinaryFloatingPoint>(_ log2n: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int, _ direction: FFTDirection) {
    switch direction {
    case .forward: _fft_zrip_forward_imp(log2n, real, imag, stride)
    case .inverse: _fft_zrip_inverse_imp(log2n, real, imag, stride)
    }
}

@inlinable
@inline(__always)
func _fft_zrip_forward_imp<T: Real & BinaryFloatingPoint>(_ log2n: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) {
    
    switch log2n {
        
    case 0: break
        
    case 1:
        _fft_zrop_forward_2(real, imag, real, imag)
    case 2:
        _fft_zrop_forward_4(real, imag, stride, real, imag, stride)
    case 3:
        _fft_zrop_forward_8(real, imag, stride, real, imag, stride)
        
    default:
        _fft_zip_imp(log2n - 1, real, imag, stride)
        _fft_zrop_forward_twiddling_imp(log2n, real, imag, stride)
    }
}
@inlinable
@inline(__always)
func _fft_zrip_inverse_imp<T: Real & BinaryFloatingPoint>(_ log2n: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) {
    _fft_zrop_inverse_imp(log2n, real, imag, stride, real, imag, stride)
}
