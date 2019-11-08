//
//  vDSP_fft_zrop_8.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@inlinable
@inline(__always)
func vDSP_fft_zrop_8<T: BinaryFloatingPoint>(_ input: UnsafePointer<T>, _ in_stride: Int, _ _real: UnsafeMutablePointer<T>, _ _imag: UnsafeMutablePointer<T>, _ out_stride: Int) {
    
    var input = input
    var _real = _real
    var _imag = _imag
    
    let a1 = input.pointee
    input += in_stride
    
    let e1 = input.pointee
    input += in_stride
    
    let c1 = input.pointee
    input += in_stride
    
    let g1 = input.pointee
    input += in_stride
    
    let b1 = input.pointee
    input += in_stride
    
    let f1 = input.pointee
    input += in_stride
    
    let d1 = input.pointee
    input += in_stride
    
    let h1 = input.pointee
    
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
    
    _real.pointee = a5 + e5
    _imag.pointee = a5 - e5
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = b3 + i
    _imag.pointee = -d3 - j
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = c5
    _imag.pointee = -g5
    _real += out_stride
    _imag += out_stride
    
    _real.pointee = b3 - i
    _imag.pointee = d3 - j
    _real += out_stride
    _imag += out_stride
}
