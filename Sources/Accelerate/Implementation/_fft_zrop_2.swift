//===--- _fft_zrop_2.swift ----------------------------------------*- swift -*-===//
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
func _fft_zrop_forward_2<T: FloatingPoint>(_ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>) {
    
    let a = in_real.pointee
    let b = in_imag.pointee
    
    out_real.pointee = a + b
    out_imag.pointee = a - b
}

@inlinable
@inline(__always)
func _fft_zrop_inverse_2<T: FloatingPoint>(_ in_real: UnsafePointer<T>, _ in_imag: UnsafePointer<T>, _ out_real: UnsafeMutablePointer<T>, _ out_imag: UnsafeMutablePointer<T>) {
    
    let a = in_real.pointee
    let b = in_imag.pointee
    
    out_real.pointee = a + b
    out_imag.pointee = a - b
}
