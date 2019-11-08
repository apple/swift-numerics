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

/// Performs a Real to Complex out-of-place discrete fourier transform. This function requires/results the first half of frequency domain only.
///
/// - parameters:
///   - log2N: The base 2 exponent of the number of elements to process.
///   - in_real: The even part of elements of real input vector when performing forward transform. Otherwise, this is the real part of complex input vector.
///   - in_imag: The odd part of elements of real input vector when performing forward transform. Otherwise, this is the imaginary part of complex input vector.
///   - in_stride: Stride between elements in `in_real` and `in_imag`.
///   - out_real: The real part of complex output vector when performing forward transform. Otherwise, this is the even part of elements of real output vector.
///   - out_imag: The imaginary part of complex output vector when performing forward transform. Otherwise, this is the odd part of elements of real output vector.
///   - out_stride: Stride between elements in `out_real` and `out_imag`.
///   - direction: Forward or inverse directional.
@inlinable
@inline(__always)
public func vDSP_fft_zrop<T: Real & BinaryFloatingPoint>(_ log2N: Int, _ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int, _ direction: FFTDirection) {
    switch direction {
    case .forward: vDSP_fft_zrop_forward_imp(log2N, in_real, in_imag, in_stride, out_real, out_imag, out_stride)
    case .inverse: vDSP_fft_zrop_inverse_imp(log2N, in_real, in_imag, in_stride, out_real, out_imag, out_stride)
    }
}

@inlinable
@inline(__always)
func vDSP_fft_zrop_forward_twiddling_imp<T: Real & BinaryFloatingPoint>(_ log2N: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) {
    
    // http://www.katjaas.nl/realFFT/realFFT2.html
    
    let length = 1 << log2N
    let half = length >> 1
    let fourth = length >> 2
    
    let _stride = half * stride
    var op_r = real
    var op_i = imag
    var oph_r = real + _stride
    var oph_i = imag + _stride
    
    let tr = op_r.pointee
    let ti = op_i.pointee
    op_r.pointee = tr + ti
    op_i.pointee = tr - ti
    
    let opf_i = imag + fourth * stride
    opf_i.pointee = -opf_i.pointee
    
    let angle = -T.pi / T(half)
    let _cos = T.cos(angle)
    let _sin = T.sin(angle)
    var _cos1 = _cos
    var _sin1 = _sin
    for _ in 1..<fourth {
        
        op_r += stride
        op_i += stride
        oph_r -= stride
        oph_i -= stride
        
        let or = op_r.pointee
        let oi = op_i.pointee
        let ohr = oph_r.pointee
        let ohi = oph_i.pointee
        
        let evenreal = or + ohr
        let evenim = oi - ohi
        let oddreal = oi + ohi
        let oddim = ohr - or
        
        let _r = oddreal * _cos1 - oddim * _sin1
        let _i = oddreal * _sin1 + oddim * _cos1
        
        op_r.pointee = 0.5 * (evenreal + _r)
        op_i.pointee = 0.5 * (_i + evenim)
        oph_r.pointee = 0.5 * (evenreal - _r)
        oph_i.pointee = 0.5 * (_i - evenim)
        
        let _c1 = _cos * _cos1 - _sin * _sin1
        let _s1 = _cos * _sin1 + _sin * _cos1
        _cos1 = _c1
        _sin1 = _s1
    }
}

@inlinable
@inline(__always)
func vDSP_fft_zrop_forward_imp<T: Real & BinaryFloatingPoint>(_ log2N: Int, _ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    switch log2N {
        
    case 0:
        out_real.pointee = in_real.pointee
        out_imag.pointee = 0
        
    case 1:
        vDSP_fft_zrop_forward_2(in_real, in_imag, out_real, out_imag)
    case 2:
        vDSP_fft_zrop_forward_4(in_real, in_imag, in_stride, out_real, out_imag, out_stride)
    case 3:
        vDSP_fft_zrop_forward_8(in_real, in_imag, in_stride, out_real, out_imag, out_stride)
        
    default:
        vDSP_fft_zop_imp(log2N - 1, in_real, in_imag, in_stride, out_real, out_imag, out_stride)
        vDSP_fft_zrop_forward_twiddling_imp(log2N, out_real, out_imag, out_stride)
    }
}
@inlinable
@inline(__always)
func vDSP_fft_zrop_inverse_imp<T: Real & BinaryFloatingPoint>(_ log2N: Int, _ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    switch log2N {
        
    case 0:
        out_real.pointee = in_real.pointee
        
    case 1:
        vDSP_fft_zrop_inverse_2(in_real, in_imag, out_real, out_imag)
    case 2:
        vDSP_fft_zrop_inverse_4(in_real, in_imag, in_stride, out_real, out_imag, out_stride)
    case 3:
        vDSP_fft_zrop_inverse_8(in_real, in_imag, in_stride, out_real, out_imag, out_stride)
        
    default:
        let length = 1 << log2N
        let half = length >> 1
        let fourth = length >> 2
        
        var ip_r = in_real
        var ip_i = in_imag
        var iph_r = in_real + half * in_stride
        var iph_i = in_imag + half * in_stride
        var tp_r = out_real
        var tp_i = out_imag
        var tph_r = tp_r + half * out_stride
        var tph_i = tp_i + half * out_stride
        
        let tr = ip_r.pointee
        let ti = ip_i.pointee
        tp_r.pointee = tr + ti
        tp_i.pointee = tr - ti
        
        let ipf_r = ip_r + fourth * in_stride
        let ipf_i = ip_i + fourth * in_stride
        let tpf_r = tp_r + fourth * out_stride
        let tpf_i = tp_i + fourth * out_stride
        tpf_r.pointee = ipf_r.pointee * 2.0
        tpf_i.pointee = -ipf_i.pointee * 2.0
        
        let angle = -T.pi / T(half)
        let _cos = T.cos(angle)
        let _sin = T.sin(angle)
        var _cos1 = _cos
        var _sin1 = _sin
        for _ in 1..<fourth {
            
            ip_r += in_stride
            ip_i += in_stride
            iph_r -= in_stride
            iph_i -= in_stride
            tp_r += out_stride
            tp_i += out_stride
            tph_r -= out_stride
            tph_i -= out_stride
            
            let ir = ip_r.pointee
            let ii = ip_i.pointee
            let ihr = iph_r.pointee
            let ihi = iph_i.pointee
            
            let evenreal = ir + ihr
            let evenim = ii - ihi
            let oddreal = ii + ihi
            let oddim = ihr - ir
            
            let _r = oddreal * _cos1 + oddim * _sin1
            let _i = oddreal * _sin1 - oddim * _cos1
            
            tp_r.pointee = evenreal - _r
            tp_i.pointee = _i + evenim
            tph_r.pointee = evenreal + _r
            tph_i.pointee = _i - evenim
            
            let _c1 = _cos * _cos1 - _sin * _sin1
            let _s1 = _cos * _sin1 + _sin * _cos1
            _cos1 = _c1
            _sin1 = _s1
        }
        
        vDSP_fft_zip(log2N - 1, out_real, out_imag, out_stride, .inverse)
    }
}

/// Performs a Real to Complex out-of-place discrete fourier transform. This function requires/results the first half of frequency domain only.
///
/// - parameters:
///   - log2N: The base 2 exponent of the number of elements to process.
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
public func vDSP_fft_zrip<T: Real & BinaryFloatingPoint>(_ log2N: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int, _ direction: FFTDirection) {
    switch direction {
    case .forward: vDSP_fft_zrip_forward_imp(log2N, real, imag, stride)
    case .inverse: vDSP_fft_zrip_inverse_imp(log2N, real, imag, stride)
    }
}

@inlinable
@inline(__always)
func vDSP_fft_zrip_forward_imp<T: Real & BinaryFloatingPoint>(_ log2N: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) {
    
    switch log2N {
        
    case 0: break
        
    case 1:
        vDSP_fft_zrop_forward_2(real, imag, real, imag)
    case 2:
        vDSP_fft_zrop_forward_4(real, imag, stride, real, imag, stride)
    case 3:
        vDSP_fft_zrop_forward_8(real, imag, stride, real, imag, stride)
        
    default:
        vDSP_fft_zip_imp(log2N - 1, real, imag, stride)
        vDSP_fft_zrop_forward_twiddling_imp(log2N, real, imag, stride)
    }
}
@inlinable
@inline(__always)
func vDSP_fft_zrip_inverse_imp<T: Real & BinaryFloatingPoint>(_ log2N: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) {
    vDSP_fft_zrop_inverse_imp(log2N, real, imag, stride, real, imag, stride)
}

/// Performs a Complex to Complex out-of-place discrete fourier transform.
///
/// This function behaves the same as the following
///
/// ```swift
/// let _2_PI = direction == .forward ? -2 * .pi : -2 * .pi
///
/// for i in 0..<n {
///     for j in 0..<n {
///         let twiddle = Complex(length: 1, phase: _2_PI * T(i * j) / T(n))!
///         output[i] += input[j] * twiddle
///     }
/// }
/// ```
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
    case .forward:
        
        // perform the forward transform.
        vDSP_fft_zop_imp(log2N, in_real, in_imag, in_stride, out_real, out_imag, out_stride)
        
    case .inverse:
        
        // we can perform the inverse transform by swapping the real and imaginary.
        vDSP_fft_zop_imp(log2N, in_imag, in_real, in_stride, out_imag, out_real, out_stride)
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

/// Performs a Complex to Complex in-place discrete fourier transform.
///
/// This function behaves the same as the following
///
/// ```swift
/// let _2_PI = direction == .forward ? -2 * .pi : -2 * .pi
///
/// for i in 0..<n {
///     for j in 0..<n {
///         let twiddle = Complex(length: 1, phase: _2_PI * T(i * j) / T(n))!
///         output[i] += input[j] * twiddle
///     }
/// }
/// ```
///
/// - parameters:
///   - log2N: The base 2 exponent of the number of elements to process.
///   - real: Real part of complex output vector.
///   - imag: Imaginary part of complex output vector.
///   - stride: Stride between elements in `real` and `imag`.
///   - direction: Forward or inverse directional.
@_transparent
public func vDSP_fft_zip<T: Real & BinaryFloatingPoint>(_ log2N: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int, _ direction: FFTDirection) {
    switch direction {
    case .forward:
        
        // perform the forward transform.
        vDSP_fft_zip_imp(log2N, real, imag, stride)
        
    case .inverse:
        
        // we can perform the inverse transform by swapping the real and imaginary.
        vDSP_fft_zip_imp(log2N, imag, real, stride)
    }
}

@inlinable
func vDSP_fft_zip_imp<T: Real & BinaryFloatingPoint>(_ log2N: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) {
    
    switch log2N {
        
    case 0: break
        
    case 1:
        vDSP_fft_zop_imp_2(real, imag, stride, real, imag, stride)
    case 2:
        vDSP_fft_zop_imp_4(real, imag, stride, real, imag, stride)
    case 3:
        vDSP_fft_zop_imp_8(real, imag, stride, real, imag, stride)
        
    default:
        let count = 1 << log2N
        
        do {
            let offset = Int.bitWidth - log2N
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
        
        vDSP_fft_zip_reordered_imp(log2N, real, imag, stride)
    }
}

@inlinable
@inline(__always)
func vDSP_fft_zip_reordered_imp<T: Real & BinaryFloatingPoint>(_ log2N: Int, _ real: UnsafeMutablePointer<T>, _ imag: UnsafeMutablePointer<T>, _ stride: Int) {
    
    let count = 1 << log2N
    
    do {
        var _r = real
        var _i = imag
        let m_stride = stride << 3
        for _ in Swift.stride(from: 0, to: count, by: 8) {
            vDSP_fft_zop_reordered_imp_8(_r, _i, stride)
            _r += m_stride
            _i += m_stride
        }
    }
    
    for s in 3..<log2N {
        
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
