//===--- Unsafe.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import Complex

extension UnsafeBufferPointer {
    
    @inlinable
    @inline(__always)
    func _reboundToReal<T>(body: (UnsafeBufferPointer<T>) -> Void) where Element == Complex<T> {
        let raw_ptr = UnsafeRawBufferPointer(self)
        let bound_ptr = raw_ptr.bindMemory(to: T.self)
        defer { _ = raw_ptr.bindMemory(to: Complex<T>.self) }
        return body(bound_ptr)
    }
}

extension UnsafeMutableBufferPointer {
    
    @inlinable
    @inline(__always)
    func _reboundToReal<T>(body: (UnsafeMutableBufferPointer<T>) -> Void) where Element == Complex<T> {
        let raw_ptr = UnsafeMutableRawBufferPointer(self)
        let bound_ptr = raw_ptr.bindMemory(to: T.self)
        defer { _ = raw_ptr.bindMemory(to: Complex<T>.self) }
        return body(bound_ptr)
    }
}
