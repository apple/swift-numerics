//===--- ElementaryFunctions.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

/// A type that has elementary functions available.
///
/// An ["elementary function"][elfn] is a function built up from powers, roots,
/// exponentials, logarithms, trigonometric functions (sin, cos, tan) and
/// their inverses, and the hyperbolic functions (sinh, cosh, tanh) and their
/// inverses.
///
/// Conformance to this protocol means that all of these building blocks are
/// available as static functions on the type.
///
/// ```swift
/// let x: Float = 1
/// let y = Float.sin(x) // 0.84147096
/// ```
///
/// There are three broad families of functions defined by `ElementaryFunctions`:
/// - Exponential, trigonometric, and hyperbolic functions:
///   `exp`, `expm1`, `cos`, `sin`, `tan`, `cosh`, `sinh`, and `tanh`.
/// - Logarithmic, inverse trigonometric, and inverse hyperbolic functions:
///   `log`, `log1p`, `acos`, `asin`, `atan`, `acosh`, `asinh`, and `atanh`.
/// - Power and root functions:
///   `pow`, `sqrt`, and `root`.
///
/// There is a second protocol, `RealFunctions`, which refines `ElementaryFunctions`
/// and includes additional operations which are more commonly used specifically with real
/// number types.
///
/// See Also:
/// -
/// - `RealFunctions`
///
/// [elfn]: http://en.wikipedia.org/wiki/Elementary_function
public protocol ElementaryFunctions {
  /// The [exponential function][wiki] e^x whose base `e` is the base of the natural logarithm.
  ///
  /// See also:
  /// -
  /// - `expm1()`
  /// - `exp2()` (for types conforming to `RealFunctions`)
  /// - `exp10()` (for types conforming to `RealFunctions`)
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Exponential_function
  static func exp(_ x: Self) -> Self
  
  /// exp(x) - 1, computed in such a way as to maintain accuracy for small x.
  ///
  /// When `x` is close to zero, the expression `.exp(x) - 1` suffers from catastrophic
  /// cancellation and the result will not have full accuracy. The `.expm1(x)` function gives
  /// you a means to address this problem.
  ///
  /// As an example, consider the expression `(x + 1)*exp(x) - 1`.  When `x` is smaller
  /// than `.ulpOfOne`, this expression evaluates to `0.0`, when it should actually round to
  /// `2*x`. We can get a full-accuracy result by using the following instead:
  /// ```
  /// let expm1x = .expm1(x)
  /// return x*(expm1x + 1) + expm1x
  /// ```
  /// This re-written expression delivers an accurate result for all values of `x`, not just for
  /// small values.
  ///
  /// See also:
  /// -
  /// - `exp()`
  /// - `exp2()` (for types conforming to `RealFunctions`)
  /// - `exp10()` (for types conforming to `RealFunctions`)
  static func expm1(_ x: Self) -> Self
  
  /// The [hyperbolic cosine][wiki] of `x`.
  /// ```
  ///            e^x + e^-x
  /// cosh(x) = ------------
  ///                2
  /// ```
  ///
  /// See also:
  /// -
  /// - `sinh()`
  /// - `tanh()`
  /// - `acosh()`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Hyperbolic_function
  static func cosh(_ x: Self) -> Self
  
  /// The [hyperbolic sine][wiki] of `x`.
  /// ```
  ///            e^x - e^-x
  /// sinh(x) = ------------
  ///                2
  /// ```
  ///
  /// See also:
  /// -
  /// - `cosh()`
  /// - `tanh()`
  /// - `asinh()`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Hyperbolic_function
  static func sinh(_ x: Self) -> Self
  
  /// The [hyperbolic tangent][wiki] of `x`.
  /// ```
  ///            sinh(x)
  /// tanh(x) = ---------
  ///            cosh(x)
  /// ```
  ///
  /// See also:
  /// -
  /// - `cosh()`
  /// - `sinhh()`
  /// - `atanh()`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Hyperbolic_function
  static func tanh(_ x: Self) -> Self
  
  /// The [cosine][wiki] of `x`.
  ///
  /// For real types, `x` may be interpreted as an angle measured in radians.
  ///
  /// See also:
  /// -
  /// - `sin()`
  /// - `tan()`
  /// - `acos()`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Cosine
  static func cos(_ x: Self) -> Self
  
  
  /// The [sine][wiki] of `x`.
  ///
  /// For real types, `x` may be interpreted as an angle measured in radians.
  ///
  /// See also:
  /// -
  /// - `cos()`
  /// - `tan()`
  /// - `asin()`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Sine
  static func sin(_ x: Self) -> Self
  
  /// The [tangent][wiki] of `x`.
  ///
  /// For real types, `x` may be interpreted as an angle measured in radians.
  ///
  /// See also:
  /// -
  /// - `cos()`
  /// - `sin()`
  /// - `atan()`
  /// - `atan2(y:x:)` (for types conforming to `RealFunctions`)
  /// ```
  ///           sin(x)
  /// tan(x) = --------
  ///           cos(x)
  /// ```
  /// [wiki]: https://en.wikipedia.org/wiki/Tangent
  static func tan(_ x: Self) -> Self
  
  /// The [natural logarithm][wiki] of `x`.
  ///
  /// See also:
  /// -
  /// - `log1p()`
  /// - `log2()` (for types conforming to `RealFunctions`)
  /// - `log10()` (for types conforming to `RealFunctions`)
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Logarithm
  static func log(_ x: Self) -> Self
  
  /// log(1 + x), computed in such a way as to maintain accuracy for small x.
  ///
  /// See also:
  /// -
  /// - `log()`
  /// - `log2()` (for types conforming to `RealFunctions`)
  /// - `log10()` (for types conforming to `RealFunctions`)
  static func log1p(_ x: Self) -> Self
  
  /// The [inverse hyperbolic cosine][wiki] of `x`.
  /// ```
  /// cosh(acosh(x)) ≅ x
  /// ```
  /// See also:
  /// -
  /// - `asinh()`
  /// - `atanh()`
  /// - `cosh()`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_hyperbolic_function
  static func acosh(_ x: Self) -> Self
  
  /// The [inverse hyperbolic sine][wiki] of `x`.
  /// ```
  /// sinh(asinh(x)) ≅ x
  /// ```
  /// See also:
  /// -
  /// - `acosh()`
  /// - `atanh()`
  /// - `sinh()`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_hyperbolic_function
  static func asinh(_ x: Self) -> Self
  
  /// The [inverse hyperbolic tangent][wiki] of `x`.
  /// ```
  /// tanh(atanh(x)) ≅ x
  /// ```
  /// See also:
  /// -
  /// - `acosh()`
  /// - `asinh()`
  /// - `tanh()`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_hyperbolic_function
  static func atanh(_ x: Self) -> Self
  
  /// The [arccosine][wiki] (inverse cosine) of `x`.
  ///
  /// For real types, the result may be interpreted as an angle measured in radians.
  /// ```
  /// cos(acos(x)) ≅ x
  /// ```
  /// See also:
  /// -
  /// - `asin()`
  /// - `atan()`
  /// - `cos()`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
  static func acos(_ x: Self) -> Self
  
  /// The [arcsine][wiki]  (inverse sine) of `x`.
  ///
  /// For real types, the result may be interpreted as an angle measured in radians.
  /// ```
  /// sin(asin(x)) ≅ x
  /// ```
  /// See also:
  /// -
  /// - `acos()`
  /// - `atan()`
  /// - `sin()`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
  static func asin(_ x: Self) -> Self
  
  /// The [arctangent][wiki]  (inverse tangent) of `x`.
  ///
  /// For real types, the result may be interpreted as an angle measured in radians.
  /// ```
  /// tan(atan(x)) ≅ x
  /// ```
  /// See also:
  /// -
  /// - `acos()`
  /// - `asin()`
  /// - `atan2()` (for types conforming to `RealFunctions`)
  /// - `tan()`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
  static func atan(_ x: Self) -> Self
  
  /// exp(y * log(x)) computed with additional internal precision.
  ///
  /// See also:
  /// -
  /// - `sqrt()`
  /// - `root()`
  ///
  static func pow(_ x: Self, _ y: Self) -> Self
  
  /// `x` raised to the nth power.
  ///
  /// See also:
  /// -
  /// - `sqrt()`
  /// - `root()`
  ///
  static func pow(_ x: Self, _ n: Int) -> Self
  
  /// The [square root][wiki] of `x`.
  ///
  /// See also:
  /// -
  /// - `pow()`
  /// - `root()`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Square_root
  static func sqrt(_ x: Self) -> Self
  
  /// The nth root of `x`.
  ///
  /// See also:
  /// -
  /// - `pow()`
  /// - `sqrt()`
  ///
  static func root(_ x: Self, _ n: Int) -> Self
}

public protocol RealFunctions: ElementaryFunctions {
  /// `atan(y/x)`, with sign selected according to the quadrant of `(x, y)`.
  ///
  /// See also:
  /// -
  /// - `atan()`
  static func atan2(y: Self, x: Self) -> Self
  
  /// The error function evaluated at `x`.
  ///
  /// See also:
  /// -
  /// - `erfc()`
  static func erf(_ x: Self) -> Self
  
  /// The complimentary error function evaluated at `x`.
  ///
  /// See also:
  /// -
  /// - `erf()`
  static func erfc(_ x: Self) -> Self
  
  /// 2^x
  ///
  /// See also:
  /// -
  /// - `exp()`
  /// - `expm1()`
  /// - `exp10()`
  /// - `log2()`
  /// - `pow()`
  static func exp2(_ x: Self) -> Self
  
  /// 10^x
  ///
  /// See also:
  /// -
  /// - `exp()`
  /// - `expm1()`
  /// - `exp2()`
  /// - `log10()`
  /// - `pow()`
  static func exp10(_ x: Self) -> Self
  
  /// `sqrt(x*x + y*y)`, computed in a manner that avoids spurious overflow or underflow.
  static func hypot(_ x: Self, _ y: Self) -> Self
  
  /// The gamma function Γ(x).
  ///
  /// See also:
  /// -
  /// - `logGamma()`
  /// - `signGamma()`
  static func gamma(_ x: Self) -> Self
  
  /// The base-2 logarithm of `x`.
  ///
  /// See also:
  /// -
  /// - `exp2()`
  /// - `log()`
  /// - `log1p()`
  /// - `log10()`
  static func log2(_ x: Self) -> Self
  
  /// The base-10 logarithm of `x`.
  ///
  /// See also:
  /// -
  /// - `exp10()`
  /// - `log()`
  /// - `log1p()`
  /// - `log2()`
  static func log10(_ x: Self) -> Self
  
  /// The logarithm of the absolute value of the gamma function, log(|Γ(x)|).
  ///
  /// See also:
  /// -
  /// - `gamma()`
  /// - `signGamma()`
  static func logGamma(_ x: Self) -> Self
}

/// A type that models the real numbers.
///
/// Types conforming to this protocol provide the arithmetic and utility operations defined by
/// the `FloatingPoint` protocol, and provide all of the math functions defined by the
/// `ElementaryFunctions` and `RealFunctions` protocols. This protocol does not
/// add any additional conformances itself, but is very useful as a protocol against which to
/// write generic code. For example, we can naturally write a generic version of the a sigmoid
/// function:
/// ```
/// func sigmoid<T: Real>(_ x: T) -> T {
///   return 1/(1 + .exp(-x))
/// }
/// ```
public protocol Real: FloatingPoint, RealFunctions {
}
