//===--- _fft_zrop_8.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

@inlinable
@inline(__always)
func _fft_zrop_forward_8<T: BinaryFloatingPoint>(_ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var in_real = in_real
    var in_imag = in_imag
    var out_real = out_real
    var out_imag = out_imag
    
    let a1 = in_real.pointee
    let e1 = in_imag.pointee
    in_real += in_stride
    in_imag += in_stride
    
    let c1 = in_real.pointee
    let g1 = in_imag.pointee
    in_real += in_stride
    in_imag += in_stride
    
    let b1 = in_real.pointee
    let f1 = in_imag.pointee
    in_real += in_stride
    in_imag += in_stride
    
    let d1 = in_real.pointee
    let h1 = in_imag.pointee
    
    let a3 = a1 + b1
    let b3 = a1 - b1
    let c3 = c1 + d1
    let d3 = c1 - d1
    let e3 = e1 + f1
    let f3 = e1 - f1
    let g3 = g1 + h1
    let h3 = g1 - h1
    
    let a5 = a3 + c3
    let c5 = a3 - c3
    let e5 = e3 + g3
    let g5 = e3 - g3
    
    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T
    
    let i = M_SQRT1_2 * (f3 - h3)
    let j = M_SQRT1_2 * (f3 + h3)
    
    out_real.pointee = a5 + e5
    out_imag.pointee = a5 - e5
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b3 + i
    out_imag.pointee = -d3 - j
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5
    out_imag.pointee = -g5
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = b3 - i
    out_imag.pointee = d3 - j
    out_real += out_stride
    out_imag += out_stride
}

@inlinable
@inline(__always)
func _fft_zrop_inverse_8<T: BinaryFloatingPoint>(_ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ in_stride: Int, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var in_real = in_real
    var in_imag = in_imag
    var out_real = out_real
    var out_imag = out_imag
    
    let a1 = in_real.pointee
    let b1 = in_imag.pointee
    in_real += in_stride
    in_imag += in_stride
    
    let e1 = in_real.pointee
    let e2 = in_imag.pointee
    in_real += in_stride
    in_imag += in_stride
    
    let c1 = in_real.pointee
    let c2 = in_imag.pointee
    in_real += in_stride
    in_imag += in_stride
    
    let g1 = in_real.pointee
    let g2 = in_imag.pointee
    
    let a3 = a1 + b1
    let b3 = a1 - b1
    let c3 = c1 + c1
    let d4 = c2 + c2
    let e3 = e1 + g1
    let e4 = e2 - g2
    let f3 = e1 - g1
    let f4 = e2 + g2
    let g3 = g1 + e1
    let g4 = g2 - e2
    let h3 = g1 - e1
    let h4 = g2 + e2
    
    let a5 = a3 + c3
    let b5 = b3 - d4
    let c5 = a3 - c3
    let d5 = b3 + d4
    let e5 = e3 + g3
    let f5 = f3 - h4
    let f6 = f4 + h3
    let g6 = e4 - g4
    let h5 = f3 + h4
    let h6 = f4 - h3
    
    let M_SQRT1_2 = 0.7071067811865475244008443621048490392848359376884740 as T
    
    let i = M_SQRT1_2 * (f5 - f6)
    let k = M_SQRT1_2 * (h5 + h6)
    
    out_real.pointee = a5 + e5
    out_imag.pointee = b5 + i
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5 - g6
    out_imag.pointee = d5 - k
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = a5 - e5
    out_imag.pointee = b5 - i
    out_real += out_stride
    out_imag += out_stride
    
    out_real.pointee = c5 + g6
    out_imag.pointee = d5 + k
}
