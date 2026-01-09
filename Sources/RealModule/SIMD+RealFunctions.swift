
// All `RealFunctions` implementations are here except for
// `static func signGamma(_ x: Self) -> FloatingPointSign`
// as SIMD can't work with `FloatingPointSign`
extension SIMD where Scalar: RealFunctions {
    @_transparent
    public static func atan2(y: Self, x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .atan2(y: y[i], x: x[i])
        }
        return v
    }

    @_transparent
    public static func erf(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .erf(x[i])
        }
        return v
    }

    @_transparent
    public static func erfc(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .erfc(x[i])
        }
        return v
    }

    @_transparent
    public static func exp2(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .exp2(x[i])
        }
        return v
    }

    @_transparent
    public static func exp10(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .exp10(x[i])
        }
        return v
    }

    @_transparent
    public static func hypot(_ x: Self, _ y: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .hypot(x[i], y[i])
        }
        return v
    }

    @_transparent
    public static func gamma(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .gamma(x[i])
        }
        return v
    }

    @_transparent
    public static func log2(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .log2(x[i])
        }
        return v
    }

    @_transparent
    public static func log10(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .log10(x[i])
        }
        return v
    }

    @_transparent
    public static func logGamma(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .logGamma(x[i])
        }
        return v
    }
}
