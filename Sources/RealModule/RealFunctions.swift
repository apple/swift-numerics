//===--- RealFunctions.swift ----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

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
  /// - `expMinusOne()`
  /// - `exp10()`
  /// - `log2()`
  /// - `pow()`
  static func exp2(_ x: Self) -> Self
  
  /// 10^x
  ///
  /// See also:
  /// -
  /// - `exp()`
  /// - `expMinusOne()`
  /// - `exp2()`
  /// - `log10()`
  /// - `pow()`
  static func exp10(_ x: Self) -> Self
  
  /// `sqrt(x*x + y*y)`, computed in a manner that avoids spurious overflow or
  /// underflow.
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
  /// - `log(onePlus:)`
  /// - `log10()`
  static func log2(_ x: Self) -> Self
  
  /// The base-10 logarithm of `x`.
  ///
  /// See also:
  /// -
  /// - `exp10()`
  /// - `log()`
  /// - `log(onePlus:)`
  /// - `log2()`
  static func log10(_ x: Self) -> Self
  
#if !os(Windows)
  /// The logarithm of the absolute value of the gamma function, log(|Γ(x)|).
  ///
  /// Not available on Windows targets.
  ///
  /// See also:
  /// -
  /// - `gamma()`
  /// - `signGamma()`
  static func logGamma(_ x: Self) -> Self
  
  /// The sign of the gamma function, Γ(x).
  ///
  /// For `x >= 0`, `signGamma(x)` is `.plus`. For negative `x`, `signGamma(x)`
  /// is `.plus` when `x` is an integer, and otherwise it is `.minus` whenever
  /// `trunc(x)` is even, and `.plus` when `trunc(x)` is odd.
  ///
  /// This function is used together with `logGamma`, which computes the
  /// logarithm of the absolute value of Γ(x), to recover the sign information.
  ///
  /// Not available on Windows targets.
  ///
  /// See also:
  /// -
  /// - `gamma()`
  /// - `logGamma()`
  static func signGamma(_ x: Self) -> FloatingPointSign
#endif
  
  /// a*b + c, computed _either_ with an FMA or with separate multiply and add.
  ///
  /// Whichever is faster should be chosen by the compiler statically.
  static func _mulAdd(_ a: Self, _ b: Self, _ c: Self) -> Self
}
