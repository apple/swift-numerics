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
    public init(degrees: T) {
        let normalized = normalize(degrees, limit: 180)
        self.init(radians: normalized * .pi / 180)
    }
    public static func degrees(_ val: T) -> Angle<T> { .init(degrees: val) }
}

public extension ElementaryFunctions
where Self: Real {
    /// See also:
    /// -
    /// `ElementaryFunctions.cos()`
    static func cos(_ angle: Angle<Self>) -> Self {
        let normalizedRadians = normalize(angle.radians, limit: .pi)
        
        if -.pi/4 < normalizedRadians && normalizedRadians < .pi/4 {
            return Self.cos(normalizedRadians)
        }
        
        if normalizedRadians > 3 * .pi / 4 || normalizedRadians < -3 * .pi / 4 {
            return -Self.cos(.pi - normalizedRadians)
        }
        
        if normalizedRadians >= 0 {
            return Self.sin(.pi/2 - normalizedRadians)
        }
        
        return Self.sin(normalizedRadians + .pi / 2)
    }
    
    /// See also:
    /// -
    /// `ElementaryFunctions.sin()`
    static func sin(_ angle: Angle<Self>) -> Self {
        let normalizedRadians = normalize(angle.radians, limit: .pi)
        
        if .pi / 4 < normalizedRadians && normalizedRadians < 3 * .pi / 4 {
            return Self.sin(normalizedRadians)
        }
        
        if -3 * .pi / 4 < normalizedRadians && normalizedRadians < -.pi / 4 {
            return -Self.sin(-normalizedRadians)
        }

        if normalizedRadians > 3 * .pi / 4 {
            return Self.sin(.pi - normalizedRadians)
        }
        
        if normalizedRadians < -3 * .pi / 4 {
            return -Self.sin(.pi + normalizedRadians)
        }
        
        return Self.sin(normalizedRadians)
    }
    
    /// See also:
    /// -
    /// `ElementaryFunctions.tan()`
    static func tan(_ angle: Angle<Self>) -> Self {
        let sine = sin(angle)
        let cosine = cos(angle)
        
        guard cosine != 0 else {
            var result = Self.infinity
            if sine.sign == .minus {
                result.negate()
            }
            return result
        }
        
        return sine / cosine
    }
}

public extension Angle {
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

extension Angle: AdditiveArithmetic {
    public static var zero: Angle<T> { .radians(0) }
    
    public static func + (lhs: Angle<T>, rhs: Angle<T>) -> Angle<T> {
        Angle(radians: lhs.radians + rhs.radians)
    }
    
    public static func += (lhs: inout Angle<T>, rhs: Angle<T>) {
        lhs.radians += rhs.radians
    }
    
    public static func - (lhs: Angle<T>, rhs: Angle<T>) -> Angle<T> {
        Angle(radians: lhs.radians - rhs.radians)
    }
    
    public static func -= (lhs: inout Angle<T>, rhs: Angle<T>) {
        lhs.radians -= rhs.radians
    }
}

public extension Angle {
    static func * (lhs: Angle<T>, rhs: T) -> Angle<T> {
        Angle(radians: lhs.radians * rhs)
    }
    
    static func *= (lhs: inout Angle<T>, rhs: T) {
        lhs.radians *= rhs
    }
    
    static func * (lhs: T, rhs: Angle<T>) -> Angle<T> {
        Angle(radians: rhs.radians * lhs)
    }
    
    static func / (lhs: Angle<T>, rhs: T) -> Angle<T> {
        assert(rhs != 0)
        return Angle(radians: lhs.radians / rhs)
    }
    
    static func /= (lhs: inout Angle<T>, rhs: T) {
        assert(rhs != 0)
        lhs.radians /= rhs
    }
}

extension Angle: Equatable {
    public static func == (lhs: Angle<T>, rhs: Angle<T>) -> Bool {
        lhs.radians.isApproximatelyEqual(to: rhs.radians)
    }
}

private func normalize<T>(_ input: T, limit: T) -> T
where T: Real {
    var normalized = input
    
    while normalized > limit {
        normalized -= 2 * limit
    }
    
    while normalized < -limit {
        normalized += 2 * limit
    }
    
    return normalized
}
