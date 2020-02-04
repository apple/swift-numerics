//===--- PerformanceBuffer.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
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
public protocol PerformanceBuffer {
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
public protocol PerformanceMutableBuffer: PerformanceBuffer {
    /// Calls the given closure with a pointer to the object's mutable
    /// contiguous storage.
    mutating func withUnsafeMutableBufferPointer<R>(
        _ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R
    ) rethrows -> R
}

public extension PerformanceBuffer where Self: Collection {
    @inlinable
    func withUnsafeBufferPointer<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R
    ) rethrows -> R {
        return try withContiguousStorageIfAvailable(body)!
    }
}

extension PerformanceMutableBuffer where Self: MutableCollection {
    @inlinable
    public mutating func withUnsafeMutableBufferPointer<R>(
        _ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R
    ) rethrows -> R {
        return try withContiguousMutableStorageIfAvailable(body)!
    }
}

extension Array: PerformanceMutableBuffer { }

extension ContiguousArray: PerformanceMutableBuffer { }

extension ArraySlice: PerformanceMutableBuffer { }

extension UnsafeBufferPointer: PerformanceBuffer { }

extension UnsafeMutableBufferPointer: PerformanceMutableBuffer { }

extension Slice: PerformanceBuffer where Base: PerformanceBuffer { }

extension Slice: PerformanceMutableBuffer
where Base: PerformanceMutableBuffer & MutableCollection { }
