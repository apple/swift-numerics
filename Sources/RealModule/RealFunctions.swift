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

  /// (1+x) raised to the nth power.
  ///
  /// This operation computes simple compound interest: a principal of 1
  /// earning a rate of `x` per period, held for `n` periods, grows to
  /// `pow(onePlus: x, n)`.
  ///
  /// This is more accurate than `pow(1+x, n)` when `x` is small, because
  /// `1+x` rounds away the low-order digits of `x` before the power is
  /// taken, while this function does not. For example, at `Double`
  /// precision, a rate so small that `1+x` rounds to exactly 1:
  /// ```
  /// let x = 0x1.0p-60         // a very small rate
  /// Double.pow(1+x, 3650)     // 1.0, all information about x is lost
  /// Double.pow(onePlus: x, 3650)
  /// // 1.000000000000003, accurate
  /// ```
  ///
  /// IEEE 754 calls this operation `compound`. See also
  /// ``powMinusOne(onePlus:_:)``, which is more accurate still when the
  /// result is close to 1, as well as
  /// ``ElementaryFunctions/pow(_:_:)-9imp6`` and
  /// ``ElementaryFunctions/log(onePlus:)``.
  ///
  /// Edge cases:
  ///
  /// - `pow(onePlus: x, 0)` is 1 for every `x >= -1`, including infinity.
  /// - `pow(onePlus: -1, n)` is `+0` for `n > 0` and `+infinity` for `n < 0`,
  ///   matching repeated multiplication or division by zero.
  /// - `pow(onePlus: .infinity, n)` is `+infinity` for `n > 0` and `+0` for
  ///   `n < 0`.
  /// - The result is `NaN` if `x < -1` or `x` is `NaN`, for every `n`
  ///   including zero. (1+x)ⁿ is not real-valued for `x < -1` and
  ///   non-integral exponents, and IEEE 754 specifies a domain error for
  ///   this case.
  static func pow(onePlus x: Self, _ n: Int) -> Self

  /// (1+x) raised to the nth power, minus 1.
  ///
  /// This operation computes the *interest earned* by a principal of 1
  /// at a rate of `x` per period held for `n` periods, as opposed to
  /// ``pow(onePlus:_:)``, which computes the resulting balance.
  ///
  /// When the result is close to zero--that is, when `x*n` is small--the
  /// expression `pow(onePlus: x, n) - 1` suffers catastrophic cancellation
  /// and loses accuracy. This function does not:
  /// ```
  /// let x = 0x1.0p-60
  /// Double.pow(onePlus: x, 8) - 1  // 0.0, every digit is lost
  /// Double.powMinusOne(onePlus: x, 8)
  /// // 6.938893903907228e-18, accurate
  /// ```
  ///
  /// See also ``pow(onePlus:_:)`` and
  /// ``ElementaryFunctions/expMinusOne(_:)``.
  ///
  /// Edge cases:
  ///
  /// - `powMinusOne(onePlus: x, 0)` is 0 for every `x >= -1`.
  /// - `powMinusOne(onePlus: -1, n)` is `-1` for `n > 0` and `+infinity`
  ///   for `n < 0`.
  /// - `powMinusOne(onePlus: .infinity, n)` is `+infinity` for `n > 0` and
  ///   `-1` for `n < 0`.
  /// - The result is `NaN` if `x < -1` or `x` is `NaN`, for every `n`
  ///   including zero.
  static func powMinusOne(onePlus x: Self, _ n: Int) -> Self

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
