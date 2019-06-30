//===--- Protocols.swift --------------------------------------*- swift -*-===//
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
/// Additional operations, such as `atan2(y:x:)`, `hypot(_:_:)` and some
/// special functions, are provided on the RealFunctions protocol, which refines
/// ElementaryFunctions.
///
/// [elfn]: http://en.wikipedia.org/wiki/Elementary_function
public protocol ElementaryFunctions {
  /// The [square root][wiki] of `x`.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Square_root
  static func sqrt(_ x: Self) -> Self
  
  /// The [cosine][wiki] of `x`.
  ///
  /// For real types, `x` may be interpreted as an angle measured in radians.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Cosine
  static func cos(_ x: Self) -> Self
  
  
  /// The [sine][wiki] of `x`.
  ///
  /// For real types, `x` may be interpreted as an angle measured in radians.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Sine
  static func sin(_ x: Self) -> Self
  
  /// The [tangent][wiki] of `x`.
  ///
  /// For real types, `x` may be interpreted as an angle measured in radians.
  /// ```
  ///           sin(x)
  /// tan(x) = --------
  ///           cos(x)
  /// ```
  /// [wiki]: https://en.wikipedia.org/wiki/Tangent
  static func tan(_ x: Self) -> Self
  
  /// The [arccosine][wiki] (inverse cosine) of `x`.
  ///
  /// For real types, the result may be interpreted as an angle measured in radians.
  /// ```
  /// cos(acos(x)) ≅ x
  /// ```
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
  static func acos(_ x: Self) -> Self
  
  /// The [arcsine][wiki]  (inverse sine) of `x`.
  ///
  /// For real types, the result may be interpreted as an angle measured in radians.
  /// ```
  /// sin(asin(x)) ≅ x
  /// ```
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
  static func asin(_ x: Self) -> Self
  
  /// The [arctangent][wiki]  (inverse tangent) of `x`.
  ///
  /// For real types, the result may be interpreted as an angle measured in radians.
  /// ```
  /// tan(atan(x)) ≅ x
  /// ```
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
  static func atan(_ x: Self) -> Self
  
  /// The [hyperbolic cosine][wiki] of `x`.
  /// ```
  ///            e^x + e^-x
  /// cosh(x) = ------------
  ///                2
  /// ```
  /// [wiki]: https://en.wikipedia.org/wiki/Hyperbolic_function
  static func cosh(_ x: Self) -> Self
  
  /// The [hyperbolic sine][wiki] of `x`.
  /// ```
  ///            e^x - e^-x
  /// sinh(x) = ------------
  ///                2
  /// ```
  /// [wiki]: https://en.wikipedia.org/wiki/Hyperbolic_function
  static func sinh(_ x: Self) -> Self
  
  /// The [hyperbolic tangent][wiki] of `x`.
  /// ```
  ///            sinh(x)
  /// tanh(x) = ---------
  ///            cosh(x)
  /// ```
  /// [wiki]: https://en.wikipedia.org/wiki/Hyperbolic_function
  static func tanh(_ x: Self) -> Self
  
  /// The [inverse hyperbolic cosine][wiki] of `x`.
  /// ```
  /// cosh(acosh(x)) ≅ x
  /// ```
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_hyperbolic_function
  static func acosh(_ x: Self) -> Self
  
  /// The [inverse hyperbolic sine][wiki] of `x`.
  /// ```
  /// sinh(asinh(x)) ≅ x
  /// ```
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_hyperbolic_function
  static func asinh(_ x: Self) -> Self
  
  /// The [inverse hyperbolic tangent][wiki] of `x`.
  /// ```
  /// tanh(atanh(x)) ≅ x
  /// ```
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_hyperbolic_function
  static func atanh(_ x: Self) -> Self
  
  /// The [exponential function][wiki] e^x whose base `e` is the base of the natural logarithm.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Exponential_function
  static func exp(_ x: Self) -> Self
  
  /// exp(x) - 1, computed in such a way as to maintain accuracy for small x.
  static func expm1(_ x: Self) -> Self
  
  /// The natural [logarithm][wiki] of `x`.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Logarithm
  static func log(_ x: Self) -> Self
  
  /// log(1 + x), computed in such a way as to maintain accuracy for small x.
  static func log1p(_ x: Self) -> Self
  
  /// exp(y * log(x)) computed with additional internal precision.
  static func pow(_ x: Self, _ y: Self) -> Self
  
  /// `x` raised to the nth power.
  static func pow(_ x: Self, _ n: Int) -> Self
  
  /// The nth root of `x`.
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
