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
  /// See also `atan()`.
  static func atan2(y: Self, x: Self) -> Self
  
  /// The error function evaluated at `x`.
  ///
  /// See also `erfc()`.
  static func erf(_ x: Self) -> Self
  
  /// The complimentary error function evaluated at `x`.
  ///
  /// See also `erf()`.
  static func erfc(_ x: Self) -> Self
  
  /// 2^x
  ///
  /// See also `exp()`, `expMinusOne()`, `exp10()`, `log2()` and `pow()`.
  static func exp2(_ x: Self) -> Self
  
  /// 10^x
  ///
  /// See also `exp()`, `expMinusOne()`, `exp2()`, `log10()` and `pow()`.
  static func exp10(_ x: Self) -> Self
  
  /// `sqrt(x*x + y*y)`, computed in a manner that avoids spurious overflow or
  /// underflow.
  static func hypot(_ x: Self, _ y: Self) -> Self
  
  /// The gamma function Γ(x).
  ///
  /// See also `logGamma()` and `signGamma()`.
  static func gamma(_ x: Self) -> Self
  
  /// The base-2 logarithm of `x`.
  ///
  /// See also `exp2()`, `log()`, `log(onePlus:)` and `log10()`.
  static func log2(_ x: Self) -> Self
  
  /// The base-10 logarithm of `x`.
  ///
  /// See also: `exp10()`, `log()`, `log(onePlus:)` and `log2()`.
  static func log10(_ x: Self) -> Self
  
#if !os(Windows)
  /// The logarithm of the absolute value of the gamma function, log(|Γ(x)|).
  ///
  /// Not available on Windows targets.
  ///
  /// See also `gamma()` and `signGamma()`.
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
  /// See also `gamma()` and `logGamma()`.
  static func signGamma(_ x: Self) -> FloatingPointSign
#endif
  
  /// a*b + c, computed _either_ with an FMA or with separate multiply and add,
  /// whichever is fastest on the compilation target.
  static func _mulAdd(_ a: Self, _ b: Self, _ c: Self) -> Self
  
  /// a + b, with the optimizer licensed to reassociate and form FMAs.
  ///
  /// Floating-point addition is not an associative operation, so the Swift
  /// compiler does not have any flexibility in how it evaluates an expression
  /// like:
  /// ```
  /// func sum(array: [Float]) -> Float {
  ///   array.reduce(0, +)
  /// }
  /// ```
  /// Using `_relaxedAdd` instead of `+` permits the compiler to reorder the
  /// terms in the summation, which unlocks loop unrolling and vectorization.
  /// In a benchmark, simply using `_relaxedAdd` provides about an 8x speedup
  /// for release builds, without any unsafe flags or other optimizations.
  /// Further improvement should be possible by improving LLVM optimizations
  /// or adding attributes to license more aggressive unrolling and taking
  /// advantage of vector ISA extensions for swift.
  static func _relaxedAdd(_ a: Self, _ b: Self) -> Self
  
  /// a * b, with the optimizer licensed to reassociate and form FMAs.
  ///
  /// Floating-point addition and multiplication are not associative operations,
  /// so the Swift compiler does not have any flexibility in how it evaluates
  /// an expression
  /// like:
  /// ```
  /// func sumOfSquares(array: [Float]) -> Float {
  ///   array.reduce(0) { $0 + $1*$1 }
  /// }
  /// ```
  /// Using `_relaxedAdd` and `_relaxedMul` instead of `+` and `*` permits the
  /// compiler to reorder the terms in the summation, which unlocks loop
  /// unrolling and vectorization, and form fused multiply-adds, which allows
  /// us to achieve twice the throughput on some hardware.
  ///
  /// If you want to license FMA formation, but _not_ reassociation (desirable
  /// for some numerics tasks), use `_mulAdd(a, b, c)` instead.
  static func _relaxedMul(_ a: Self, _ b: Self) -> Self
}
