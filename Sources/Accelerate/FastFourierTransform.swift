//===--- FastFourierTransform.swift ----------------------------------------*- swift -*-===//
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

public enum FFTDirection {
    
    case forward
    
    case inverse
}

/// Performs an out-of-place discrete fourier transform.
///
/// - parameters:
///   - log2N: The base 2 exponent of the number of elements to process.
///   - in_real: Real part of complex input vector.
///   - in_imag: Imaginary part of complex input vector.
///   - in_stride: Stride between elements in `in_real` and `in_imag`.
///   - out_real: Real part of complex output vector.
///   - out_imag: Imaginary part of complex output vector.
///   - out_stride: Stride between elements in `out_real` and `out_imag`.
///   - direction: Forward or inverse directional.
@_transparent
public func vDSP_fft_zop<T: Real & BinaryFloatingPoint>(_ log2N: Int, _ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int, _ direction: FFTDirection) {
    switch direction {
    case .forward: vDSP_fft_zop_imp(log2N, in_real, in_imag, in_stride, out_real, out_imag, out_stride)
    case .inverse: vDSP_fft_zop_imp(log2N, in_imag, in_real, in_stride, out_imag, out_real, out_stride)
    }
}

@inlinable
func vDSP_fft_zop_imp<T: Real & BinaryFloatingPoint>(_ log2N: Int, _ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    switch log2N {
        
    case 0:
        out_real.pointee = in_real.pointee
        out_imag.pointee = in_imag.pointee
        
    case 1:
        vDSP_fft_zop_imp_2(in_real, in_imag, in_stride, out_real, out_imag, out_stride)
    case 2:
        vDSP_fft_zop_imp_4(in_real, in_imag, in_stride, out_real, out_imag, out_stride)
    case 3:
        vDSP_fft_zop_imp_8(in_real, in_imag, in_stride, out_real, out_imag, out_stride)
        
    default:
        let length = 1 << log2N
        let half = length >> 1
        
        let oph_stride = half * out_stride
        var op_r = out_real
        var op_i = out_imag
        var oph_r = out_real + oph_stride
        var oph_i = out_imag + oph_stride
        
        vDSP_fft_zop_imp(log2N - 1, in_real, in_imag, in_stride << 1, op_r, op_i, out_stride)
        vDSP_fft_zop_imp(log2N - 1, in_real + in_stride, in_imag + in_stride, in_stride << 1, oph_r, oph_i, out_stride)
        
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

// MARK: Fixed Length Cooley-Tukey

@inlinable
@inline(__always)
func vDSP_fft_zop_imp_2<T: Real>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag
    
    let a = real.pointee
    let b = imag.pointee
    real += in_stride
    imag += in_stride
    
    let c = real.pointee
    let d = imag.pointee
    
    _real.pointee = a + c
    _imag.pointee = b + d
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = a - c
    _imag.pointee = b - d
    
}

@inlinable
@inline(__always)
func vDSP_fft_zop_imp_4<T: Real>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag
    
    let a = real.pointee
    let b = imag.pointee
    real += in_stride
    imag += in_stride
    
    let c = real.pointee
    let d = imag.pointee
    real += in_stride
    imag += in_stride
    
    let e = real.pointee
    let f = imag.pointee
    real += in_stride
    imag += in_stride
    
    let g = real.pointee
    let h = imag.pointee
    
    let i = a + e
    let j = b + f
    let k = a - e
    let l = b - f
    let m = c + g
    let n = d + h
    let o = c - g
    let p = d - h
    
    _real.pointee = i + m
    _imag.pointee = j + n
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = k + p
    _imag.pointee = l - o
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = i - m
    _imag.pointee = j - n
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = k - p
    _imag.pointee = l + o
}

@inlinable
@inline(__always)
func vDSP_fft_zop_imp_8<T: Real & BinaryFloatingPoint>(_ real: UnsafePointer<T>, _ imag: UnsafePointer<T>, _ in_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var real = real
    var imag = imag
    var _real = _real
    var _imag = _imag
    
    let a1 = real.pointee
    let a2 = imag.pointee
    real += in_stride
    imag += in_stride
    
    let e1 = real.pointee
    let e2 = imag.pointee
    real += in_stride
    imag += in_stride
    
    let c1 = real.pointee
    let c2 = imag.pointee
    real += in_stride
    imag += in_stride
    
    let g1 = real.pointee
    let g2 = imag.pointee
    real += in_stride
    imag += in_stride
    
    let b1 = real.pointee
    let b2 = imag.pointee
    real += in_stride
    imag += in_stride
    
    let f1 = real.pointee
    let f2 = imag.pointee
    real += in_stride
    imag += in_stride
    
    let d1 = real.pointee
    let d2 = imag.pointee
    real += in_stride
    imag += in_stride
    
    let h1 = real.pointee
    let h2 = imag.pointee
    
    let a3 = a1 + b1
    let a4 = a2 + b2
    let b3 = a1 - b1
    let b4 = a2 - b2
    let c3 = c1 + d1
    let c4 = c2 + d2
    let d3 = c1 - d1
    let d4 = c2 - d2
    let e3 = e1 + f1
    let e4 = e2 + f2
    let f3 = e1 - f1
    let f4 = e2 - f2
    let g3 = g1 + h1
    let g4 = g2 + h2
    let h3 = g1 - h1
    let h4 = g2 - h2
    
    let a5 = a3 + c3
    let a6 = a4 + c4
    let b5 = b3 + d4
    let b6 = b4 - d3
    let c5 = a3 - c3
    let c6 = a4 - c4
    let d5 = b3 - d4
    let d6 = b4 + d3
    let e5 = e3 + g3
    let e6 = e4 + g4
    let f5 = f3 + h4
    let f6 = f4 - h3
    let g5 = e3 - g3
    let g6 = e4 - g4
    let h5 = f3 - h4
    let h6 = f4 + h3
    
    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T
    
    let i = M_SQRT1_2 * (f5 + f6)
    let j = M_SQRT1_2 * (f6 - f5)
    let k = M_SQRT1_2 * (h5 - h6)
    let l = M_SQRT1_2 * (h6 + h5)
    
    _real.pointee = a5 + e5
    _imag.pointee = a6 + e6
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = b5 + i
    _imag.pointee = b6 + j
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = c5 + g6
    _imag.pointee = c6 - g5
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = d5 - k
    _imag.pointee = d6 - l
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = a5 - e5
    _imag.pointee = a6 - e6
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = b5 - i
    _imag.pointee = b6 - j
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = c5 - g6
    _imag.pointee = c6 + g5
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = d5 + k
    _imag.pointee = d6 + l
}
