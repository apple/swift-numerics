//===--- RealFunctions.swift ----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2025 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

public protocol RealFunctions: ElementaryFunctions {
  /// The signed angle formed in the plane between the vector `(x,y)` and the
  /// positive real axis, measured in radians.
  ///
  /// The result is in the interval `[-π, π]`.
  ///
  /// The argument order to `atan2` may be surprising to new programmers.
  /// The convention of `y` being the first argument goes back at least to
  /// Fortran IV in 1961 and is generally followed in computing with a few
  /// notable exceptions (e.g. Mathematica and Excel). This convention was
  /// originally chosen because of the mathematical definition of the
  /// function:
  ///
  /// ```
  /// atan2(y,x) = atan(y/x) if x > 0
  /// ```
  ///
  /// See also ``ElementaryFunctions/atan(_:)``, as well as the `phase` and
  /// `polar` properties defined on the `Complex` type.
  static func atan2(y: Self, x: Self) -> Self
  
  /// The [error function](https://en.wikipedia.org/wiki/Error_function)
  /// evaluated at `x`.
  static func erf(_ x: Self) -> Self
  
  /// The complimentary [error function](https://en.wikipedia.org/wiki/Error_function)
  /// evaluated at `x`.
  static func erfc(_ x: Self) -> Self
  
  /// 2 raised to the power x.
  ///
  /// See also ``log2(_:)``, ``ElementaryFunctions/exp(_:)``,
  /// ``ElementaryFunctions/expMinusOne(_:)``
  /// and ``ElementaryFunctions/pow(_:_:)-2qmul``.
  static func exp2(_ x: Self) -> Self
  
  /// 10 raised to the power x.
  ///
  /// See also ``log10(_:)``, ``ElementaryFunctions/exp(_:)``,
  /// ``ElementaryFunctions/expMinusOne(_:)``
  /// and ``ElementaryFunctions/pow(_:_:)-2qmul``.
  static func exp10(_ x: Self) -> Self
  
  /// The length of the vector `(x,y)`, computed in a manner that avoids
  /// spurious overflow or underflow.
  ///
  /// See also the `length` and `polar` properties defined on the `Complex`
  /// type.
  static func hypot(_ x: Self, _ y: Self) -> Self
  
  /// The [gamma function](https://en.wikipedia.org/wiki/Gamma_function) Γ(x).
  static func gamma(_ x: Self) -> Self
  
  /// The base-2 logarithm of `x`.
  ///
  /// See also ``exp2(_:)``, ``ElementaryFunctions/log(_:)``,
  /// and ``ElementaryFunctions/log(onePlus:)``.
  static func log2(_ x: Self) -> Self
  
  /// The base-10 logarithm of `x`.
  ///
  /// See also ``exp10(_:)``, ``ElementaryFunctions/log(_:)``,
  /// and ``ElementaryFunctions/log(onePlus:)``.
  static func log10(_ x: Self) -> Self
  
#if !os(Windows)
  /// The logarithm of the absolute value of the
  /// [gamma function](https://en.wikipedia.org/wiki/Gamma_function),
  /// log(|Γ(x)|).
  ///
  /// Not available on Windows targets.
  static func logGamma(_ x: Self) -> Self
  
  /// The sign of the
  /// [gamma function](https://en.wikipedia.org/wiki/Gamma_function), Γ(x).
  ///
  /// For `x >= 0`, `signGamma(x)` is `.plus`. For negative `x`, `signGamma(x)`
  /// is `.plus` when `x` is an integer, and otherwise it is `.minus` whenever
  /// `trunc(x)` is even, and `.plus` when `trunc(x)` is odd.
  ///
  /// This function is used together with ``logGamma(_:)``, which computes the
  /// logarithm of the absolute value of Γ(x), to recover the sign information.
  ///
  /// Not available on Windows targets.
  static func signGamma(_ x: Self) -> FloatingPointSign
#endif
}
