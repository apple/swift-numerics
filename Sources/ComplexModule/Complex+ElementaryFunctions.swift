//===--- Complex+ElementaryFunctions --------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule

extension Complex:ElementaryFunctions {
    public static func exp(_ z: Self) -> Self {
        let r = RealType.exp(z.real)
        let a = z.imaginary
        return Self(r * .cos(a), r * .sin(a))
    }
    public static func expMinusOne(_ z: Self) -> Self {
        return -exp(z/2) * 2 * sin(z * .i / 2) * .i
    }
    public static func cosh(_ z: Self) -> Self {
        return cos(z * .i)
    }
    public static func sinh(_ z: Self) -> Self {
        return -sin(z * .i) * .i
    }
    public static func tanh(_ z: Self) -> Self {
        return sinh(z) / cosh(z)
    }
    public static func cos(_ z: Self) -> Self {
        let (x, y) = (z.real, z.imaginary)
        return Self(+.cos(x) * .cosh(y), -.sin(x) * .sinh(y))
    }
    public static func sin(_ z: Self) -> Self {
        let (x, y) = (z.real, z.imaginary)
        return Self(+.sin(x) * .cosh(y), +.cos(x) * .sinh(y))
    }
    public static func tan(_ z: Self) -> Self {
        return sin(z) / cos(z)
    }
    public static func log(_ z: Self) -> Self {
        let (r, a) = z.polar
        return Self(RealType.log(r), a)
    }
    public static func log(onePlus z: Self) -> Self {
        return 2 * atanh(z / (z + 2))
    }
    public static func acosh(_ z:Self) -> Self {
        return log(z + sqrt(z + 1) * sqrt(z - 1))
    }
    public static func asinh(_ z:Self) -> Self {
        return log(z + sqrt(z * z + 1))
    }
    public static func atanh(_ z:Self) -> Self {
        return (log(1 + z) - log(1 - z)) / 2
    }
    public static func acos(_ z:Self) -> Self {
         return log(z - sqrt(1 - z * z) * .i) * .i
    }
    public static func asin(_ z:Self) -> Self {
        return -log(z * .i + sqrt(1 - z * z)) * .i
    }
    public static func atan(_ z:Self) -> Self {
        return (log(1 - z * .i) - log(1 + z * .i)) * .i / 2
    }
    public static func pow(_ lhs: Self, _ rhs: Self) -> Self {
        return exp(log(lhs) * rhs)
    }
    public static func pow(_ lhs: Self, _ rhs: Int) -> Self {
        // MARK: - NOT OPTIMAL
        return pow(lhs, Self(RealType(rhs), 0))
    }
    public static func sqrt(_ z:Self) -> Self {
        let r = z.length
        let x = RealType.sqrt((r + z.real)/2)
        let y = RealType.sqrt((r - z.real)/2)
        return Self(x, z.imaginary.sign == .minus ? -y : y)
    }
    public static func root(_ z: Self, _ n: Int) -> Self {
        // MARK: - NOT OPTIMAL
        return pow(z, Self(RealType(1) / RealType(n)))
    }
}
