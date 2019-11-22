//===--- Integer.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension FixedWidthInteger {
    
    @inlinable
    @inline(__always)
    public var bit_reverse: Self {
        
        var m1: Self = 0
        for _ in 0..<Self.bitWidth >> 3 {
            m1 = (m1 << 8) | 0x0F
        }
        
        let m2 = (m1 << 2) ^ m1
        let m3 = (m2 << 1) ^ m2
        
        let s1 = (0xF0 as Self).byteSwapped
        let s2 = s1 << 2
        let s3 = s2 << 1
        
        let x0 = self.byteSwapped
        let u0 = (x0 & m1) << 4
        let v0 = ((x0 & ~m1) >> 4) & ~s1
        
        let x1 = u0 | v0
        let u1 = (x1 & m2) << 2
        let v1 = ((x1 & ~m2) >> 2) & ~s2
        
        let x2 = u1 | v1
        let u2 = (x2 & m3) << 1
        let v2 = ((x2 & ~m3) >> 1) & ~s3
        
        return u2 | v2
    }
}

extension BinaryInteger {
    
    @inlinable
    @inline(__always)
    public var isPower2 : Bool {
        return 0 < self && self & (self - 1) == 0
    }
}

@inlinable
@inline(__always)
public func log2<T: FixedWidthInteger>(_ x: T) -> T {
    return x == 0 ? 0 : T(T.bitWidth - x.leadingZeroBitCount - 1)
}
