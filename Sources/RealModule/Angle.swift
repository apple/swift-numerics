//===--- Angle.swift ------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

/// A wrapper type for angle operations and functions
///
/// All trigonometric functions expect the argument to be passed as radians (Real), but this is not enforced by the type system.
/// This type serves exactly this purpose, and can be seen as an alternative to the underlying Real implementation.
public struct Angle<T: Real> {
    public var radians: T
    public init(radians: T) { self.radians = radians }
    public static func radians(_ val: T) -> Angle<T> { .init(radians: val) }

    public var degrees: T { radians * 180 / .pi }
    public init(degrees: T) { self.init(radians: degrees * .pi / 180) }
    public static func degrees(_ val: T) -> Angle<T> { .init(degrees: val) }
}

public extension Angle {
    /// See also:
    /// -
    /// `ElementaryFunctions.cosh()`
    var cosh: T { T.cosh(radians) }
    
    /// See also:
    /// -
    /// `ElementaryFunctions.sinh()`
    var sinh: T { T.sinh(radians) }
    
    /// See also:
    /// -
    /// `ElementaryFunctions.tanh()`
    var tanh: T { T.tanh(radians) }
    
    /// See also:
    /// -
    /// `ElementaryFunctions.cos()`
    var cos: T { T.cos(radians) }
    
    /// See also:
    /// -
    /// `ElementaryFunctions.sin()`
    var sin: T { T.sin(radians) }
    
    /// See also:
    /// -
    /// `ElementaryFunctions.tan()`
    var tan: T { T.tan(radians) }
    
    /// See also:
    /// -
    /// `ElementaryFunctions.acosh()`
    static func acosh(_ x: T) -> Self { Angle.radians(T.acosh(x)) }
    
    /// See also:
    /// -
    /// `ElementaryFunctions.asinh()`
    static func asinh(_ x: T) -> Self { Angle.radians(T.asinh(x)) }
    
    /// See also:
    /// -
    /// `ElementaryFunctions.atanh()`
    static func atanh(_ x: T) -> Self { Angle.radians(T.atanh(x)) }
    
    /// See also:
    /// -
    /// `ElementaryFunctions.acos()`
    static func acos(_ x: T) -> Self { Angle.radians(T.acos(x)) }
    
    /// See also:
    /// -
    /// `ElementaryFunctions.asin()`
    static func asin(_ x: T) -> Self { Angle.radians(T.asin(x)) }
    
    /// See also:
    /// -
    /// `ElementaryFunctions.atan()`
    static func atan(_ x: T) -> Self { Angle.radians(T.atan(x)) }
    
    /// See also:
    /// -
    /// `RealFunctions.atan2()`
    static func atan2(y: T, x: T) -> Self { Angle.radians(T.atan2(y: y, x: x)) }
}
