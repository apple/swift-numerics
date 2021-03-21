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
public struct Angle<T: Real>: Equatable {
    fileprivate var degreesPart: T = 0
    fileprivate var radiansPart: T = 0
    
    fileprivate init() {}
    
    fileprivate init(degreesPart: T, radiansPart: T) {
        self.degreesPart = degreesPart
        self.radiansPart = radiansPart
    }
    
    public init(radians: T) {
        radiansPart = radians
    }
    
    public static func radians(_ value: T) -> Angle<T> {
        .init(radians: value)
    }
    
    public init(degrees: T) {
        degreesPart = degrees
    }
    
    public static func degrees(_ value: T) -> Angle<T> {
        .init(degrees: value)
    }
    
    public var radians: T {
        radiansPart + degreesPart * .pi / 180
    }
    
    public var degrees: T {
        radiansPart * 180 / .pi + degreesPart
    }
}

extension Angle: AdditiveArithmetic {
    public static var zero: Angle<T> { .init() }
    
    public static func + (lhs: Angle<T>, rhs: Angle<T>) -> Angle<T> {
        .init(degreesPart: lhs.degreesPart + rhs.degreesPart,
              radiansPart: lhs.radiansPart + rhs.radiansPart)
    }
    
    public static func += (lhs: inout Angle<T>, rhs: Angle<T>) {
        lhs.degreesPart += rhs.degreesPart
        lhs.radiansPart += rhs.radiansPart
    }
    
    public static func - (lhs: Angle<T>, rhs: Angle<T>) -> Angle<T> {
        .init(degreesPart: lhs.degreesPart - rhs.degreesPart,
              radiansPart: lhs.radiansPart - rhs.radiansPart)
    }
    
    public static func -= (lhs: inout Angle<T>, rhs: Angle<T>) {
        lhs.degreesPart -= rhs.degreesPart
        lhs.radiansPart -= rhs.radiansPart
    }
}

extension Angle {
    public static func * (lhs: Angle<T>, rhs: T) -> Angle<T> {
        .init(degreesPart: lhs.degreesPart * rhs,
              radiansPart: lhs.radiansPart * rhs)
    }
    
    public static func *= (lhs: inout Angle<T>, rhs: T) {
        lhs.degreesPart *= rhs
        lhs.radiansPart *= rhs
    }
    
    public static func * (lhs: T, rhs: Angle<T>) -> Angle<T> {
        return rhs * lhs
    }
    
    public static func / (lhs: Angle<T>, rhs: T) -> Angle<T> {
        assert(rhs != 0)
        return .init(degreesPart: lhs.degreesPart / rhs,
                     radiansPart: lhs.radiansPart / rhs)
    }
    
    public static func /= (lhs: inout Angle<T>, rhs: T) {
        assert(rhs != 0)
        lhs.degreesPart /= rhs
        lhs.radiansPart /= rhs
    }
}

private extension Angle {
    var piTimesFromDegrees: T {
        if degreesPart.magnitude <= 180 {
            return degreesPart / 180
        }
        let remainder = degreesPart.remainder(dividingBy: 180)
        return remainder / 180
    }
    
    var piTimesFromRadians: T {
        if radiansPart.magnitude <= .pi {
            return radiansPart / .pi
        }
        let remainder = radiansPart.remainder(dividingBy: .pi)
        return remainder / .pi
    }
}

extension ElementaryFunctions
where Self: Real {
    /// The cos of the angle.
    ///
    /// The degrees and radians parts are treated separately and then combined together
    /// using standard trigonometric [identities]. For each part, the corresponding remainder
    /// by  pi or 180° is found, and the higher precision `cos(piTimes:)` function is used
    ///
    /// See also:
    /// -
    /// `ElementaryFunctions.cos()`
    /// [identities]: https://en.wikipedia.org/wiki/List_of_trigonometric_identities#Angle_sum_and_difference_identities
    public static func cos(_ angle: Angle<Self>) -> Self {
        let piTimesDegrees = angle.piTimesFromDegrees
        let piTimesRadians = angle.piTimesFromRadians
        let cosa = cos(piTimes: piTimesDegrees)
        let cosb = cos(piTimes: piTimesRadians)
        let sina = sin(piTimes: piTimesDegrees)
        let sinb = sin(piTimes: piTimesRadians)
        return cosa * cosb - sina * sinb
    }
}

extension ElementaryFunctions
where Self: Real {
    /// The sine of the angle.
    ///
    ///
    /// The degrees and radians parts are treated separately and then combined together
    /// using standard trigonometric [identities]. For each part, the corresponding remainder
    /// by  pi or 180° is found, and the higher precision `sin(piTimes:)` function is used
    ///
    /// See also:
    /// -
    /// `ElementaryFunctions.sin()`
    /// [identities]: https://en.wikipedia.org/wiki/List_of_trigonometric_identities#Angle_sum_and_difference_identities
    public static func sin(_ angle: Angle<Self>) -> Self {
        let piTimesDegrees = angle.piTimesFromDegrees
        let piTimesRadians = angle.piTimesFromRadians
        let cosa = cos(piTimes: piTimesDegrees)
        let cosb = cos(piTimes: piTimesRadians)
        let sina = sin(piTimes: piTimesDegrees)
        let sinb = sin(piTimes: piTimesRadians)
        return sina * cosb + cosa * sinb
    }
}

extension ElementaryFunctions
where Self: Real {
    /// The tangent of the angle.
    ///
    /// The degrees and radians parts are treated separately and then combined together
    /// using standard trigonometric [identities]. For each part, the corresponding remainder
    /// by  pi or 180° is found, and the higher precision `tan(piTimes:)` function is used
    ///
    /// See also:
    /// -
    /// `ElementaryFunctions.tan()`
    /// [identities]: https://en.wikipedia.org/wiki/List_of_trigonometric_identities#Angle_sum_and_difference_identities
    public static func tan(_ angle: Angle<Self>) -> Self {
        let piTimesDegrees = angle.piTimesFromDegrees
        let piTimesRadians = angle.piTimesFromRadians
        let tana = tan(piTimes: piTimesDegrees)
        let tanb = tan(piTimes: piTimesRadians)
        switch (tana.isFinite, tanb) {
        case (false, 0):
            return tana
        case (false, _):
            return -1 / tanb
        default:
            return (tana + tanb) / (1 - tana * tanb)
        }
    }
}

extension Angle {
    /// See also:
    /// -
    /// `ElementaryFunctions.acos()`
    public static func acos(_ x: T) -> Self {
        .radians(T.acos(x))
    }

    /// See also:
    /// -
    /// `ElementaryFunctions.asin()`
    public static func asin(_ x: T) -> Self {
        .radians(T.asin(x))
    }

    /// See also:
    /// -
    /// `ElementaryFunctions.atan()`
    public static func atan(_ x: T) -> Self {
        .radians(T.atan(x))
    }

    /// The 2-argument atan function.
    ///
    ///- Precondition: `x` and `y` cannot be both 0 at the same time
    ///
    /// See also:
    /// -
    /// `RealFunctions.atan2()`
    public static func atan2(y: T, x: T) -> Self {
        .radians(T.atan2(y: y, x: x))
    }
}

extension Angle {
    /// Checks whether the current angle is contained within a range, defined from a start and end angle.
    ///
    /// The comparison is performed based on the equivalent normalized angles in [-pi, pi].
    ///
    /// Examples:
    ///
    /// ```swift
    /// let angle = Angle(degrees: 175)
    ///
    /// // returns true
    /// angle.isInRange(start: Angle(degrees: 170), end:Angle(degrees: -170))
    ///
    /// // returns false
    /// angle.isInRange(start: Angle(degrees: -170), end:Angle(degrees: 170))
    ///
    /// // returns true
    /// angle.isInRange(start: Angle(degrees: 170), end:Angle(degrees: 180))
    ///
    /// // returns false
    /// angle.isInRange(start: Angle(degrees: 30), end:Angle(degrees: 60))
    /// ```
    ///
    /// - Parameters:
    ///
    ///     - start: The start of the range, within which containment is checked.
    ///
    ///     - end: The end of the range, within which containment is checked.
    public func isInRange(start: Angle<T>, end: Angle<T>) -> Bool {
        let fullNormalized = normalize(value: degrees, limit: 180)
        let normalizedStart = normalize(value: start.degrees, limit: 180)
        var normalizedEnd = normalize(value: end.degrees, limit: 180)
        if normalizedEnd < normalizedStart {
            normalizedEnd += 360
        }
        return (normalizedStart <= fullNormalized && fullNormalized <= normalizedEnd)
            || (normalizedStart <= fullNormalized + 360 && fullNormalized + 360 <= normalizedEnd)
    }
}

extension Angle {
    /// Checks whether the current angle is close to another angle within a given tolerance
    ///
    /// - Precondition: `tolerance` must positive, otherwise the return value is always  false
    ///
    /// - Parameters:
    ///
    ///     - other: the angle from which the distance is controlled.
    ///
    ///     - tolerance: the tolerance around `other` for which the result will be true
    ///
    /// - Returns: `true` if the current angle falls within the range ```[self - tolerance, self + tolerance]```, otherwise false
    public func isClose(to other: Angle<T>, within tolerance: Angle<T>) -> Bool {
        precondition(tolerance.degrees >= 0)
        return isInRange(start: other - tolerance, end: other + tolerance)
    }
}

extension Angle: Comparable {
    public static func < (lhs: Angle<T>, rhs: Angle<T>) -> Bool {
        guard lhs != rhs else {
            return false
        }
        return lhs.radians < rhs.radians
    }
}

extension Angle {
    fileprivate func normalize(value: T, limit: T) -> T {
        var normalized = value
        
        while normalized > limit {
            normalized -= 2 * limit
        }
        
        while normalized < -limit {
            normalized += 2 * limit
        }
        
        return normalized
    }
}
