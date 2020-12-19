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
        radiansPart + degreesPart.asRadians
    }
    
    public var degrees: T {
        radiansPart.asDegrees + degreesPart
    }
    
    fileprivate var degreesPart: T = 0
    
    fileprivate var radiansPart: T = 0
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

extension ElementaryFunctions
where Self: Real {
    /// See also:
    /// -
    /// `ElementaryFunctions.cos()`
    public static func cos(_ angle: Angle<Self>) -> Self {
        let degrees = angle.normalizedDegreesPart()
        let cosa = cosd(degrees)
        let cosb = cos(angle.radiansPart)
        let sina = sind(degrees)
        let sinb = sin(angle.radiansPart)
        return cossum(cosa, cosb, sina, sinb)
    }
    
    private static func cosd(_ degrees: Self) -> Self {
        let (exactPart, rest) = degrees.extractParts()
        guard let exactAngle = exactPart else {
            return cos(rest.asRadians)
        }
        let (cosa, sina) = getExactCosAndSin(for: exactAngle)
        let cosb = cosd(rest)
        let sinb = sind(rest)
        return cossum(cosa, cosb, sina, sinb)
    }
    
    private static func cossum(_ cosa: Self, _ cosb: Self, _ sina: Self, _ sinb: Self) -> Self {
        return cosa * cosb - sina * sinb
    }
}

extension ElementaryFunctions
where Self: Real {
    /// See also:
    /// -
    /// `ElementaryFunctions.sin()`
    public static func sin(_ angle: Angle<Self>) -> Self {
        let degrees = angle.normalizedDegreesPart()
        let cosa = cosd(degrees)
        let cosb = cos(angle.radiansPart)
        let sina = sind(degrees)
        let sinb = sin(angle.radiansPart)
        return sinsum(cosa, cosb, sina, sinb)
    }
    
    private static func sind(_ degrees: Self) -> Self {
        let (exactPart, rest) = degrees.extractParts()
        guard let exactAngle = exactPart else {
            return sin(rest.asRadians)
        }
        let (cosa, sina) = getExactCosAndSin(for: exactAngle)
        let cosb = cosd(rest)
        let sinb = sind(rest)
        return sinsum(cosa, cosb, sina, sinb)
    }
    
    private static func sinsum(_ cosa: Self, _ cosb: Self, _ sina: Self, _ sinb: Self) -> Self {
        return sina * cosb + cosa * sinb
    }
}

extension ElementaryFunctions
where Self: Real {
    /// See also:
    /// -
    /// `ElementaryFunctions.tan()`
    public static func tan(_ angle: Angle<Self>) -> Self {
        let degrees = angle.normalizedDegreesPart()
        let tana = tand(degrees)
        let tanb = tan(angle.radiansPart)
        return tansum(tana, tanb)
    }
    
    private static func tand(_ degrees: Self) -> Self {
        let (exactPart, rest) = degrees.extractParts()
        guard let exactAngle = exactPart else {
            return tan(rest.asRadians)
        }
        let tana = getExactTan(for: exactAngle)
        let tanb = tand(rest)
        return tansum(tana, tanb)
    }
    
    private static func tansum(_ tana: Self, _ tanb: Self) -> Self {
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

extension ElementaryFunctions
where Self: Real {
    fileprivate static func getExactCosAndSin(for degrees: Self) -> (cos: Self, sin: Self) {
        let knownTrigonometry = exactAngleConversions().first(where: { $0.degrees == degrees.magnitude })!
        return (knownTrigonometry.cos, knownTrigonometry.sin * degrees.realSign)
    }
    
    fileprivate static func getExactTan(for degrees: Self) -> Self {
        let knownTrigonometry = exactAngleConversions().first(where: { $0.degrees == degrees.magnitude })!
        return knownTrigonometry.tan * degrees.realSign
    }
}

extension Angle {
    /// See also:
    /// -
    /// `ElementaryFunctions.acos()`
    public static func acos(_ x: T) -> Self {
        guard let exactSolution = exactAngleConversions().first(where: {$0.cos == x.magnitude }) else {
            return .radians(T.acos(x))
        }
        let degrees = x > 0
            ?  exactSolution.degrees
            : 180 - exactSolution.degrees
        return .degrees(degrees)
    }

    /// See also:
    /// -
    /// `ElementaryFunctions.asin()`
    public static func asin(_ x: T) -> Self {
        guard let exactSolution = exactAngleConversions().first(where: { $0.sin == x.magnitude }) else {
            return .radians(T.asin(x))
        }
        return .degrees(exactSolution.degrees * x.realSign)
    }

    /// See also:
    /// -
    /// `ElementaryFunctions.atan()`
    public static func atan(_ x: T) -> Self {
        guard let exactSolution = exactAngleConversions().first(where: { $0.tan == x.magnitude }) else {
            return .radians(T.atan(x))
        }
        return .degrees(exactSolution.degrees * x.realSign)
    }

    /// See also:
    /// -
    /// `RealFunctions.atan2()`
    public static func atan2(y: T, x: T) -> Self {
        let norm = (x*x + y*y).squareRoot()
        assert(norm != 0)
        let sin = y / norm
        let cos = x / norm
        guard let exactSolution = exactAngleConversions().first(where: { cos.magnitude.isApproximatelyEqual(to: $0.cos)
                                                                    && sin.magnitude.isApproximatelyEqual(to:$0.sin) }) else {
            return .radians(T.atan2(y: y, x: x))
        }
        if y >= 0 && x >= 0 {
            return .degrees(exactSolution.degrees)
        }
        if y >= 0 && x < 0 {
            return .degrees(180 - exactSolution.degrees)
        }
        if y < 0 && x >= 0 {
            return .degrees(-exactSolution.degrees)
        }
        return .degrees(-180 + exactSolution.degrees)
    }
}

//
//extension Angle {
//    /// Checks whether the current angle is contained within a given closed range.
//    ///
//    /// - Parameters:
//    ///
//    ///     - range: The closed angular range within which containment is checked.
//    public func contained(in range: ClosedRange<Angle<T>>) -> Bool {
//        range.contains(self)
//    }
//
//    /// Checks whether the current angle is contained within a given half-open range.
//    ///
//    /// - Parameters:
//    ///
//    ///     - range: The half-open angular range within which containment is checked.
//    public func contained(in range: Range<Angle<T>>) -> Bool {
//        range.contains(self)
//    }
//}
//
//extension Angle {
//    // “Is angle δ no more than angle ε away from angle ζ?”
//}

extension Angle: Comparable {
    public static func < (lhs: Angle<T>, rhs: Angle<T>) -> Bool {
        guard lhs != rhs else {
            return false
        }
        return lhs.radians < rhs.radians
    }
}

extension Real {
    fileprivate var asRadians: Self { self * .pi / 180 }
    
    fileprivate var asDegrees: Self { self * 180 / .pi }
    
    fileprivate func extractParts()  -> (common: Self?, rest: Self) {
        if let summandsAbove90 = extractParts(limit: 90) {
            return (summandsAbove90.exact, summandsAbove90.rest)
        }
        if let summandsAbove60 = extractParts(limit: 60) {
            return (summandsAbove60.exact, summandsAbove60.rest)
        }
        if let summandsAbove45 = extractParts(limit: 45) {
            return (summandsAbove45.exact, summandsAbove45.rest)
        }
        if let summandsAbove30 = extractParts(limit: 30) {
            return (summandsAbove30.exact, summandsAbove30.rest)
        }
        return (nil, self)
    }
    
    private func extractParts(limit: Self)  -> DegreesSummands<Self>? {
        guard self.magnitude >= limit else {
            return nil
        }
        return DegreesSummands(exact: realSign * limit,
                               rest: realSign * (self.magnitude - limit))
    }
}

private struct DegreesSummands<T: Real> {
    let exact: T
    let rest: T
}

extension Angle {
    fileprivate func normalizedDegreesPart() -> T {
        normalize(\.degreesPart, limit: 180)
    }
    
    fileprivate func normalizedRadiansPart() -> T {
        normalize(\.radiansPart, limit: .pi)
    }
    
    private func normalize(_ path: KeyPath<Self, T>, limit: T) -> T {
        var normalized = self[keyPath: path]
        
        while normalized > limit {
            normalized -= 2 * limit
        }
        
        while normalized < -limit {
            normalized += 2 * limit
        }
        
        return normalized
    }
}

private struct ExactTrigonometry<T: Real> {
    let degrees: T
    let cos: T
    let sin: T
    let tan: T
}

private func exactAngleConversions<T: Real>() -> [ExactTrigonometry<T>] {
    [
        ExactTrigonometry(degrees:  0,
                             cos: 1,
                             sin: 0,
                             tan: 0),
        ExactTrigonometry(degrees: 30,
                             cos: T.sqrt(3)/2,
                             sin: 1 / 2,
                             tan: T.sqrt(3) / 3),
        ExactTrigonometry(degrees: 45,
                             cos: T.sqrt(2) / 2,
                             sin: T.sqrt(2) / 2,
                             tan: 1),
        ExactTrigonometry(degrees: 60,
                             cos: 1 / 2,
                             sin: T.sqrt(3) / 2,
                             tan: T.sqrt(3)),
        ExactTrigonometry(degrees: 90,
                             cos: 0,
                             sin: 1,
                             tan: T.infinity),
    ]
}

extension Real {
    fileprivate var realSign: Self {
        guard self.isFinite else {
            return self == .infinity ? 1 : -1
        }
        return self > 0 ? 1 : -1
    }
}
