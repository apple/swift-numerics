//===--- _fft_zop_imp_4.swift ----------------------------------------*- swift -*-===//
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

@inlinable
@inline(__always)
func _fft_zop_imp_4<T: Real>(_ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var in_real = in_real
    var in_imag = in_imag
    var out_real = out_real
    var out_imag = out_imag
    
    let a = in_real.pointee
    let b = in_imag.pointee
    in_real += in_stride
    in_imag += in_stride
    
    let c = in_real.pointee
    let d = in_imag.pointee
    in_real += in_stride
    in_imag += in_stride
    
    let e = in_real.pointee
    let f = in_imag.pointee
    in_real += in_stride
    in_imag += in_stride
    
    let g = in_real.pointee
    let h = in_imag.pointee
    
    let i = a + e
    let j = b + f
    let k = a - e
    let l = b - f
    let m = c + g
    let n = d + h
    let o = c - g
    let p = d - h
    
    out_real.pointee = i + m
    out_imag.pointee = j + n
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = k + p
    out_imag.pointee = l - o
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = i - m
    out_imag.pointee = j - n
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = k - p
    out_imag.pointee = l + o
}
