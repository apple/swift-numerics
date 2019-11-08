//===--- vDSP_fft_zop_imp_8.swift ----------------------------------------*- swift -*-===//
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
