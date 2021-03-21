//===--- RealFunctions.swift ----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

public protocol RealFunctions: ElementaryFunctions {
  
  /// `atan(y/x)`, with representative selected using the quadrant`(x,y)`.
  ///
  /// The [atan2 function][wiki] computes the angle (in radians, in the
  /// range [-π, π]) formed between the positive real axis and the point
  /// `(x,y)`. The sign of the result always matches the sign of y.
  ///
  /// - Warning:
  /// Note the parameter ordering of this function; the `y` parameter
  /// comes *before* the `x` parameter. This is a historical curiosity
  /// going back to early FORTRAN math libraries. In order to minimize
  /// opportunities for confusion and subtle bugs, we require explicit
  /// parameter labels with this function.
  ///
  /// See also:
  /// -
  /// - `ElementaryFunctions.atan(_:)`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Atan2
  static func atan2(y: Self, x: Self) -> Self
  
  /// `cos(πx)`
  ///
  /// Computes the cosine of π times `x`.
  ///
  /// Because π is not representable in any `FloatingPoint` type, for large
  /// `x`, `.cos(.pi * x)` can have arbitrarily large relative error;
  /// `.cos(piTimes: x)` always provides a result with small relative error.
  ///
  /// This is observable even for modest arguments; consider `0.5`:
  /// ```swift
  /// Float.cos(.pi * 0.5)    // 7.54979e-08
  /// Float.cos(piTimes: 0.5) // 0.0
  /// ```
  /// It's important to be clear that there is no bug in the example
  /// given above. Every step of both computations is producing the most
  /// accurate possible result.
  ///
  /// Symmetries:
  /// -
  /// - `.cos(piTimes: -x) = .cos(piTimes: x)`.
  ///
  /// See also:
  /// -
  /// - `sin(piTimes:)`
  /// - `tan(piTimes:)`
  /// - `ElementaryFunctions.cos(_:)`
  static func cos(piTimes x: Self) -> Self
  
  /// `sin(πx)`
  ///
  /// Computes the sine of π times `x`.
  ///
  /// Because π is not representable in any `FloatingPoint` type, for large
  /// `x`, `.sin(.pi * x)` can have arbitrarily large relative error;
  /// `.sin(piTimes: x)` always provides a result with small relative error.
  ///
  /// This is observable even for modest arguments; consider `10`:
  /// ```swift
  /// Float.sin(.pi * 10)    // -2.4636322e-06
  /// Float.sin(piTimes: 10) // 0.0
  /// ```
  /// It's important to be clear that there is no bug in the example
  /// given above. Every step of both computations is producing the most
  /// accurate possible result.
  ///
  /// Symmetry:
  /// -
  /// `.sin(piTimes: -x) = -.sin(piTimes: x)`.
  ///
  /// See also:
  /// -
  /// - `cos(piTimes:)`
  /// - `tan(piTimes:)`
  /// - `ElementaryFunctions.sin(_:)`
  static func sin(piTimes x: Self) -> Self
  
  /// `tan(πx)`
  ///
  /// Computes the tangent of π times `x`.
  ///
  /// Because π is not representable in any `FloatingPoint` type, for large
  /// `x`, `.tan(.pi * x)` can have arbitrarily large relative error;
  /// `.tan(piTimes: x)` always provides a result with small relative error.
  ///
  /// This is observable even for modest arguments; consider `0.5`:
  /// ```swift
  /// Float.tan(.pi * 0.5)    // 13245402.0
  /// Float.tan(piTimes: 0.5) // infinity
  /// ```
  /// It's important to be clear that there is no bug in the example
  /// given above. Every step of both computations is producing the most
  /// accurate possible result.
  ///
  /// Symmetry:
  /// -
  /// `.tan(piTimes: -x) = -.tan(piTimes: x)`.
  ///
  /// See also:
  /// -
  /// - `cos(piTimes:)`
  /// - `sin(piTimes:)`
  /// - `ElementaryFunctions.tan(_:)`
  static func tan(piTimes x: Self) -> Self
  
  /// The [error function][wiki] evaluated at `x`.
  ///
  /// See also:
  /// -
  /// - `erfc(_:)`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Error_function
  static func erf(_ x: Self) -> Self
  
  /// The complimentary [error function][wiki] evaluated at `x`.
  ///
  /// See also:
  /// -
  /// - `erf(_:)`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Error_function
  static func erfc(_ x: Self) -> Self
  
  /// 2ˣ
  ///
  /// See also:
  /// -
  /// - `ElementaryFunctions.exp(_:)`
  /// - `ElementaryFunctions.expMinusOne(_:)`
  /// - `exp10(_:)`
  /// - `log2(_:)`
  /// - `ElementaryFunctions.pow(_:)`
  static func exp2(_ x: Self) -> Self
  
  /// 10ˣ
  ///
  /// See also:
  /// -
  /// - `ElementaryFunctions.exp(_:)`
  /// - `ElementaryFunctions.expMinusOne(_:)`
  /// - `exp2(_:)`
  /// - `log10(_:)`
  /// - `ElementaryFunctions.pow(_:)`
  static func exp10(_ x: Self) -> Self
  
  /// The square root of the sum of squares of `x` and `y`.
  ///
  /// The naive expression `.sqrt(x*x + y*y)` and overflow
  /// or underflow if `x` or `y` is not well-scaled, producing zero or
  /// infinity, even when the mathematical result is representable.
  ///
  /// The [hypot][wiki] takes care to avoid this, and always
  /// produces an accurate result when one is available.
  ///
  /// See also:
  /// -
  /// - `ElementaryFunctions.sqrt(_:)`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Hypot
  static func hypot(_ x: Self, _ y: Self) -> Self
  
  /// The [gamma function][wiki] Γ(x).
  ///
  /// See also:
  /// -
  /// - `logGamma(_:)`
  /// - `signGamma(_:)`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Gamma_function
  static func gamma(_ x: Self) -> Self
  
  /// The base-2 logarithm of `x`.
  ///
  /// See also:
  /// -
  /// - `exp2(_:)`
  /// - `ElementaryFunctions.log(_:)`
  /// - `ElementaryFunctions.log(onePlus:)`
  /// - `log10(_:)`
  static func log2(_ x: Self) -> Self
  
  /// The base-10 logarithm of `x`.
  ///
  /// See also:
  /// -
  /// - `exp10(_:)`
  /// - `ElementaryFunctions.log(_:)`
  /// - `ElementaryFunctions.log(onePlus:)`
  /// - `log2(_:)`
  static func log10(_ x: Self) -> Self
  
#if !os(Windows)
  /// The logarithm of the absolute value of the [gamma function][wiki], log(|Γ(x)|).
  ///
  /// - Warning:
  /// Not available on Windows.
  ///
  /// See also:
  /// -
  /// - `gamma(_:)`
  /// - `signGamma(_:)`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Gamma_function
  static func logGamma(_ x: Self) -> Self
  
  /// The sign of the [gamma function][wiki], Γ(x).
  ///
  /// For `x >= 0`, `signGamma(x)` is `.plus`. For negative `x`, `signGamma(x)` is `.plus`
  /// when `x` is an integer, and otherwise it is `.minus` whenever `trunc(x)` is even, and `.plus`
  /// when `trunc(x)` is odd.
  ///
  /// This function is used together with `logGamma`, which computes the logarithm of the
  /// absolute value of Γ(x), to recover the sign information.
  ///
  /// - Warning:
  /// Not available on Windows. 
  ///
  /// See also:
  /// -
  /// - `gamma(_:)`
  /// - `logGamma(_:)`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Gamma_function
  static func signGamma(_ x: Self) -> FloatingPointSign
#endif
  
  /// a*b + c, computed _either_ with an FMA or with separate multiply and add.
  ///
  /// Whichever is faster should be chosen by the compiler statically.
  static func _mulAdd(_ a: Self, _ b: Self, _ c: Self) -> Self
  
  // MARK: Implementation details
  
  /// The low-word of the integer formed by truncating this value.
  var _lowWord: UInt { get }
}

