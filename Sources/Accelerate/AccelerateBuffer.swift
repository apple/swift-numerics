//===--- AccelerateBuffer.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// An object composed of count elements that are stored contiguously in memory.
///
/// In practice, most types conforming to this protocol will be Collections,
/// but they need not be--they need only have an Element type and count, and
/// provide the withUnsafeBufferPointer function.
public protocol AccelerateBuffer {
    /// The buffer's element type.
    associatedtype Element
    
    /// The number of elements in the buffer.
    var count: Int { get }
    
    /// Calls a closure with a pointer to the object's contiguous storage.
    func withUnsafeBufferPointer<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R
    ) rethrows -> R
}

/// A mutable object composed of count elements that are stored contiguously
/// in memory.
///
/// In practice, most types conforming to this protocol will be
/// MutableCollections, but they need not be.
public protocol AccelerateMutableBuffer: AccelerateBuffer {
    /// Calls the given closure with a pointer to the object's mutable
    /// contiguous storage.
    mutating func withUnsafeMutableBufferPointer<R>(
        _ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R
    ) rethrows -> R
}

public extension AccelerateBuffer where Self: Collection {
    @inlinable
    func withUnsafeBufferPointer<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R
    ) rethrows -> R {
        return try withContiguousStorageIfAvailable(body)!
    }
}

extension AccelerateMutableBuffer where Self: MutableCollection {
    @inlinable
    public mutating func withUnsafeMutableBufferPointer<R>(
        _ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R
    ) rethrows -> R {
        return try withContiguousMutableStorageIfAvailable(body)!
    }
}

extension Array: AccelerateMutableBuffer { }

extension ContiguousArray: AccelerateMutableBuffer { }

extension ArraySlice: AccelerateMutableBuffer { }

extension UnsafeBufferPointer: AccelerateBuffer { }

extension UnsafeMutableBufferPointer: AccelerateMutableBuffer { }

extension Slice: AccelerateBuffer where Base: AccelerateBuffer { }

extension Slice: AccelerateMutableBuffer
where Base: AccelerateMutableBuffer & MutableCollection { }
