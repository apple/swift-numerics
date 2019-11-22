//===--- _fft_conv.swift ----------------------------------------*- swift -*-===//
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

/// Performs a fast fourier based convolution.
///
/// This function behaves the same as the following
///
/// ```swift
/// for i in 0..<signal.count {
///
///     var sum = 0.0
///
///     for j in 0..<kernel.count {
///         let k = positive_mod(i - j, signal.count)
///         sum += kernel[j] * signal[k]
///     }
///
///     result[i] = sum
/// }
/// ```
///
/// - parameters:
///   - log2N: The base 2 exponent of the number of elements to process.
///   - signal: signal buffer.
///   - signal_stride: Stride between elements in `signal`.
///   - kernel: kernel buffer.
///   - kernel_stride: Stride between elements in `kernel`.
///   - output: output buffer.
///   - out_stride: Stride between elements in `output`.
///   - temp: temporary buffer.
///   - temp_stride: Stride between elements in `temp`.
@inlinable
public func _fft_conv<T: Real & BinaryFloatingPoint>(_ log2N: Int, _ signal: UnsafePointer<T>, _ signal_stride: Int, _ kernel: UnsafePointer<T>, _ kernel_stride: Int, _ output: UnsafeMutablePointer<T>, _ out_stride: Int, _ temp: UnsafeMutablePointer<T>, _ temp_stride: Int) {
    
    let length = 1 << log2N
    let half = length >> 1
    
    var _sreal = temp
    var _simag = temp + temp_stride
    var _kreal = output
    var _kimag = output + out_stride
    
    let s_stride = temp_stride << 1
    let k_stride = out_stride << 1
    
    _fft_zrop(log2N, signal, signal + signal_stride, signal_stride << 1, _sreal, _simag, s_stride, .forward)
    _fft_zrop(log2N, kernel, kernel + kernel_stride, kernel_stride << 1, _kreal, _kimag, k_stride, .forward)
    
    let m = 1 / T(length)
    _kreal.pointee *= m * _sreal.pointee
    _kimag.pointee *= m * _simag.pointee
    for _ in 1..<half {
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
        let _sr = _sreal.pointee
        let _si = _simag.pointee
        let _kr = m * _kreal.pointee
        let _ki = m * _kimag.pointee
        _kreal.pointee = _sr * _kr - _si * _ki
        _kimag.pointee = _sr * _ki + _si * _kr
    }
    
    _fft_zrip(log2N, output, output + out_stride, out_stride << 1, .inverse)
}

/// Performs a fast fourier based convolution.
///
/// This function behaves the same as the following
///
/// ```swift
/// for i in 0..<signal.count {
///
///     var sum = 0.0
///
///     for j in 0..<kernel.count {
///         let k = positive_mod(i - j, signal.count)
///         sum += kernel[j] * signal[k]
///     }
///
///     result[i] = sum
/// }
/// ```
///
/// - parameters:
///   - log2N: The base 2 exponent of the number of elements to process.
///   - sreal: Real part of complex signal buffer.
///   - simag: Imaginary part of complex signal buffer.
///   - signal_stride: Stride between elements in `sreal` and `simag`.
///   - kreal: Real part of complex kernel buffer.
///   - kimag: Imaginary part of complex kernel buffer.
///   - kernel_stride: Stride between elements in `kreal` and `kimag`.
///   - oreal: Real part of complex output buffer.
///   - oimag: Imaginary part of complex output buffer.
///   - out_stride: Stride between elements in `oreal` and `oimag`.
///   - treal: Real part of complex temporary buffer.
///   - timag: Imaginary part of complex temporary buffer.
///   - temp_stride: Stride between elements in `treal` and `timag`.
@inlinable
public func _fft_conv<T: Real & BinaryFloatingPoint>(_ log2N: Int, _ sreal: UnsafePointer<T>, _ simag: UnsafePointer<T>, _ signal_stride: Int, _ kreal: UnsafePointer<T>, _ kimag: UnsafePointer<T>, _ kernel_stride: Int, _ oreal: UnsafeMutablePointer<T>, _ oimag: UnsafeMutablePointer<T>, _ out_stride: Int, _ treal: UnsafeMutablePointer<T>, _ timag: UnsafeMutablePointer<T>, _ temp_stride: Int) {
    
    let length = 1 << log2N
    
    var _sreal = treal
    var _simag = timag
    var _kreal = oreal
    var _kimag = oimag
    
    let s_stride = temp_stride
    let k_stride = out_stride
    
    _fft_zop(log2N, sreal, simag, signal_stride, _sreal, _simag, s_stride, .forward)
    _fft_zop(log2N, kreal, kimag, kernel_stride, _kreal, _kimag, k_stride, .forward)
    
    let m = 1 / T(length)
    for _ in 0..<length {
        let _sr = _sreal.pointee
        let _si = _simag.pointee
        let _kr = m * _kreal.pointee
        let _ki = m * _kimag.pointee
        _sreal.pointee = _sr * _kr - _si * _ki
        _simag.pointee = _sr * _ki + _si * _kr
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
    }
    
    _fft_zop(log2N, treal, timag, temp_stride, oreal, oimag, out_stride, .inverse)
}
