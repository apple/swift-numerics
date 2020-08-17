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
        -exp(z/2) * 2 * sin(z * .i / 2) * .i
    }
    public static func cosh(_ z: Self) -> Self {
        Self(
            .cosh(z.real) * .cos(z.imaginary),
            .sinh(z.real) * .sin(z.imaginary)
        )
    }
    public static func sinh(_ z: Self) -> Self {
        Self(
            .sinh(z.real) * .cos(z.imaginary),
            .cosh(z.real) * .sin(z.imaginary)
        )
    }
    public static func tanh(_ z: Self) -> Self {
        sinh(z) / cosh(z)
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
        sin(z) / cos(z)
    }
    public static func log(_ z: Self) -> Self {
        let (r, a) = z.polar
        return Self(RealType.log(r), a)
    }
    public static func log(onePlus z: Self) -> Self {
        // return 2 * atanh(z / (z + 2))
        // the following implementation by HaydenMcCabe
        let (x, y) = (z.real, z.imaginary)
        let a = x*x + y*y + 2*x
        let u = RealType.log(onePlus: a) / 2
        let v = RealType.atan2(y: y, x: x+1)
        return Self(u, v)
    }
    public static func acosh(_ z:Self) -> Self {
        log(z + sqrt(z + 1) * sqrt(z - 1))
    }
    public static func asinh(_ z:Self) -> Self {
        log(z + sqrt(z * z + 1))
    }
    public static func atanh(_ z:Self) -> Self {
        (log(1 + z) - log(1 - z)) / 2
    }
    public static func acos(_ z:Self) -> Self {
        log(z - sqrt(1 - z * z) * .i) * .i
    }
    public static func asin(_ z:Self) -> Self {
        -log(z * .i + sqrt(1 - z * z)) * .i
    }
    public static func atan(_ z:Self) -> Self {
        (log(1 - z * .i) - log(1 + z * .i)) * .i / 2
    }
    public static func pow(_ z: Self, _ w: Self) -> Self {
        exp(log(z) * w)
    }
    public static func pow<I:SignedInteger>(_ z: Self, _ n: I) -> Self {
        // algorithm:
        //  https://en.wikipedia.org/wiki/Exponentiation_by_squaring
        var result = Self(1, 0)
        var base = z
        var k = abs(n)
        while k > 0 {
            if k & 1 != 0 { result *= base }
            base *= base
            k >>= 1
        }
        return n < 0 ? 1/result : result
    }
    public static func sqrt(_ z:Self) -> Self {
        let r = z.length
        let x = RealType.sqrt((r + z.real)/2)
        let y = RealType.sqrt((r - z.real)/2)
        return Self(x, z.imaginary.sign == .minus ? -y : y)
    }
    public static func root<I:SignedInteger>(_ z: Self, _ n: I) -> Self {
        switch n {
        case  0:    return .infinity
        case  1:    return z
        case  2:    return sqrt(z)
        case -1:    return 1/z
        case -2:    return 1/sqrt(z)
        default:
            guard let nth = RealType(n).reciprocal else { return .infinity }
            return pow(z, Complex(nth, 0))
        }
    }
}
