//===--- vDSP_fft_zop_imp_4.swift ----------------------------------------*- swift -*-===//
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
