//===--- ElementaryFunctions.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2025 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

public protocol ElementaryFunctions: AdditiveArithmetic {
  /// The [exponential function][wiki] e^x whose base `e` is the base of the
  /// natural logarithm.
  ///
  /// For types that conform to ``RealFunctions`` see
  /// ``RealFunctions/exp2(_:)`` and ``RealFunctions/exp10(_:)``.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Exponential_function
  static func exp(_ x: Self) -> Self
  
  /// exp(x) - 1, computed in such a way as to maintain accuracy for small x.
  ///
  /// When `x` is close to zero, the expression `.exp(x) - 1` suffers from
  /// catastrophic cancellation and the result will not have full accuracy.
  /// The `.expMinusOne(x)` function gives you a means to address this problem.
  ///
  /// As an example, consider the expression `(x + 1) * .exp(x) - 1`.  When `x`
  /// is smaller than `.ulpOfOne`, this expression evaluates to `0.0`, when it
  /// should actually round to `2*x`. We can get a full-accuracy result by
  /// using the following instead:
  /// ```
  /// let t = .expMinusOne(x)
  /// return x*(t+1) + t       // x*exp(x) + (exp(x)-1) = (x+1)*exp(x) - 1
  /// ```
  /// This re-written expression delivers an accurate result for all values
  /// of `x`, not just for small values.
  ///
  /// For types that conform to ``RealFunctions`` see
  /// ``RealFunctions/exp2(_:)`` and ``RealFunctions/exp10(_:)``.
  static func expMinusOne(_ x: Self) -> Self
  
  /// The [hyperbolic cosine][wiki] of `x`.
  /// ```
  ///            e^x + e^-x
  /// cosh(x) = ------------
  ///                2
  /// ```
  ///
  /// See also ``acosh(_:)``.
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
  /// See also ``asinh(_:)``.
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
  /// See also ``atanh(_:)``.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Hyperbolic_function
  static func tanh(_ x: Self) -> Self
  
  /// The [cosine][wiki] of `x`.
  ///
  /// For real types, `x` may be interpreted as an angle measured in radians.
  ///
  /// See also ``acos(_:)``.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Cosine
  static func cos(_ x: Self) -> Self
  
  
  /// The [sine][wiki] of `x`.
  ///
  /// For real types, `x` may be interpreted as an angle measured in radians.
  ///
  /// See also ``asin(_:)``.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Sine
  static func sin(_ x: Self) -> Self
  
  /// The [tangent][wiki] of `x`.
  ///
  /// For real types, `x` may be interpreted as an angle measured in radians.
  ///
  /// See also ``atan(_:)``.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Tangent
  static func tan(_ x: Self) -> Self
  
  /// The [natural logarithm][wiki] of `x`.
  ///
  /// For types that conform to ``RealFunctions`` see also
  /// ``RealFunctions/log2(_:)`` and ``RealFunctions/log10(_:)``.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Logarithm
  static func log(_ x: Self) -> Self
  
  /// log(1 + x), computed in such a way as to maintain accuracy for small x.
  ///
  /// For types that conform to ``RealFunctions`` see also
  /// ``RealFunctions/log2(_:)`` and ``RealFunctions/log10(_:)``.
  static func log(onePlus x: Self) -> Self
  
  /// The [inverse hyperbolic cosine][wiki] of `x`.
  ///
  /// ```
  /// cosh(acosh(x)) ≅ x
  /// ```
  ///
  /// See also ``cosh(_:)``.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_hyperbolic_function
  static func acosh(_ x: Self) -> Self
  
  /// The [inverse hyperbolic sine][wiki] of `x`.
  ///
  /// ```
  /// sinh(asinh(x)) ≅ x
  /// ```
  ///
  /// See also ``sinh(_:)``.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_hyperbolic_function
  static func asinh(_ x: Self) -> Self
  
  /// The [inverse hyperbolic tangent][wiki] of `x`.
  ///
  /// ```
  /// tanh(atanh(x)) ≅ x
  /// ```
  ///
  /// See also ``tanh(_:)``.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_hyperbolic_function
  static func atanh(_ x: Self) -> Self
  
  /// The [arccosine][wiki] (inverse cosine) of `x`.
  ///
  /// For real types, the result may be interpreted as an angle measured in
  /// radians.
  ///
  /// ```
  /// cos(acos(x)) ≅ x
  /// ```
  ///
  /// See also ``cos(_:)``.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
  static func acos(_ x: Self) -> Self
  
  /// The [arcsine][wiki]  (inverse sine) of `x`.
  ///
  /// For real types, the result may be interpreted as an angle measured in
  /// radians.
  ///
  /// ```
  /// sin(asin(x)) ≅ x
  /// ```
  ///
  /// See also ``sin(_:)``.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
  static func asin(_ x: Self) -> Self
  
  /// The [arctangent][wiki]  (inverse tangent) of `x`.
  ///
  /// For real types, the result may be interpreted as an angle measured in
  /// radians.
  ///
  /// ```
  /// tan(atan(x)) ≅ x
  /// ```
  ///
  /// See also ``tan(_:)``.
  /// For types that conform to ``RealFunctions``, you will sometimes want
  /// to use ``RealFunctions/atan2(y:x:)`` instead.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Inverse_trigonometric_functions
  static func atan(_ x: Self) -> Self
  
  /// exp(y * log(x)) computed with additional internal precision.
  ///
  /// The edge-cases of this function are defined based on the behavior of the
  /// expression `exp(y log x)`, matching IEEE 754's `powr` operation.
  /// In particular, this means that if `x` and `y` are both zero, `pow(x,y)`
  /// is `nan` for real types and `infinity` for complex types, rather than 1.
  ///
  /// There is also
  /// <doc:/documentation/RealModule/ElementaryFunctions/pow(_:_:)-9imp6>,
  /// whose behavior is defined in terms of repeated multiplication.
  static func pow(_ x: Self, _ y: Self) -> Self
  
  /// `x` raised to the nth power.
  ///
  /// The edge-cases of this function are defined in terms of repeated
  /// multiplication or division, rather than exp(n log x). In particular,
  /// `Float.pow(0, 0)` is 1.
  static func pow(_ x: Self, _ n: Int) -> Self
  
  /// The [square root][wiki] of `x`.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Square_root
  static func sqrt(_ x: Self) -> Self
  
  /// The nth root of `x`.
  static func root(_ x: Self, _ n: Int) -> Self
}
