//===--- vDSP_fft_zop_imp_2.swift ----------------------------------------*- swift -*-===//
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
