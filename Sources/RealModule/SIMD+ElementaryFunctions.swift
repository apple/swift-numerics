#if canImport(_Differentiation)
import _Differentiation
#endif

#if !canImport(_Differentiation)
// add `AdditiveArithmetic` conformance since this is only present in the _Differentiation module which is not present everywhere
extension SIMD2: @retroactive AdditiveArithmetic where Scalar: FloatingPoint {}
extension SIMD4: @retroactive AdditiveArithmetic where Scalar: FloatingPoint {}
extension SIMD8: @retroactive AdditiveArithmetic where Scalar: FloatingPoint {}
extension SIMD16: @retroactive AdditiveArithmetic where Scalar: FloatingPoint {}
extension SIMD32: @retroactive AdditiveArithmetic where Scalar: FloatingPoint {}
extension SIMD64: @retroactive AdditiveArithmetic where Scalar: FloatingPoint {}
#endif

extension SIMD where Scalar: ElementaryFunctions {
    @_transparent
    public static func exp(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .exp(x[i])
        }
        return v
    }

    @_transparent
    public static func expMinusOne(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .expMinusOne(x[i])
        }
        return v
    }

    @_transparent
    public static func cosh(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .cosh(x[i])
        }
        return v
    }

    @_transparent
    public static func sinh(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .sinh(x[i])
        }
        return v
    }

    @_transparent
    public static func tanh(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .tanh(x[i])
        }
        return v
    }

    @_transparent
    public static func cos(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .cos(x[i])
        }
        return v
    }

    @_transparent
    public static func sin(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .sin(x[i])
        }
        return v
    }

    @_transparent
    public static func tan(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .tan(x[i])
        }
        return v
    }

    @_transparent
    public static func log(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .log(x[i])
        }
        return v
    }

    @_transparent
    public static func log(onePlus x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .log(onePlus: x[i])
        }
        return v
    }

    @_transparent
    public static func acosh(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .acosh(x[i])
        }
        return v
    }

    @_transparent
    public static func asinh(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .asinh(x[i])
        }
        return v
    }

    @_transparent
    public static func atanh(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .atanh(x[i])
        }
        return v
    }

    @_transparent
    public static func acos(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .acos(x[i])
        }
        return v
    }

    @_transparent
    public static func asin(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .asin(x[i])
        }
        return v
    }

    @_transparent
    public static func atan(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .atan(x[i])
        }
        return v
    }

    @_transparent
    public static func pow(_ x: Self, _ n: Int) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .pow(x[i], n)
        }
        return v
    }

    @_transparent
    public static func pow(_ x: Self, _ y: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .pow(x[i], y[i])
        }
        return v
    }

    @_transparent
    public static func sqrt(_ x: Self) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .sqrt(x[i])
        }
        return v
    }

    @_transparent
    public static func root(_ x: Self, _ n: Int) -> Self {
        var v = Self()
        for i in v.indices {
            v[i] = .root(x[i], n)
        }
        return v
    }
}

extension SIMD2: ElementaryFunctions where Scalar: ElementaryFunctions & FloatingPoint { }
extension SIMD4: ElementaryFunctions where Scalar: ElementaryFunctions & FloatingPoint { }
extension SIMD8: ElementaryFunctions where Scalar: ElementaryFunctions & FloatingPoint { }
extension SIMD16: ElementaryFunctions where Scalar: ElementaryFunctions & FloatingPoint { }
extension SIMD32: ElementaryFunctions where Scalar: ElementaryFunctions & FloatingPoint { }
extension SIMD64: ElementaryFunctions where Scalar: ElementaryFunctions & FloatingPoint { }
