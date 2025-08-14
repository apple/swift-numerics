//===--- RelaxedArithmetic.swift ------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021-2025 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import _NumericsShims

public enum Relaxed { }

extension Relaxed {
  /// a+b, but grants the optimizer permission to reassociate expressions
  /// and form FMAs.
  ///
  /// Floating-point addition is not an associative operation, so the Swift
  /// compiler does not have any flexibility in how it evaluates an expression
  /// like:
  /// ```
  /// func sum(array: [Float]) -> Float {
  ///   array.reduce(0, +)
  /// }
  /// ```
  /// Using `Relaxed.sum` instead of `+` permits the compiler to reorder the
  /// terms in the summation, which unlocks loop unrolling and vectorization.
  /// In a benchmark, simply using `Relaxed.sum` provides about an 8x speedup
  /// for release builds, without any unsafe flags or other optimizations.
  /// Further improvement should be possible by improving LLVM optimizations
  /// or adding attributes to license more aggressive unrolling and taking
  /// advantage of vector ISA extensions for swift.
  ///
  /// If you want to compute `a-b` with relaxed semantics, use
  /// `Relaxed.sum(a, -b)`.
  ///
  /// If a type or toolchain does not support reassociation for optimization
  /// purposes, this operation decays to a normal addition; it is a license
  /// for the compiler to optimize, not a guarantee that any change occurs.
  @_transparent
  public static func sum<T: AlgebraicField>(_ a: T, _ b: T) -> T {
    T._relaxedAdd(a, b)
  }
  
  /// a*b, but grants the optimizer permission to reassociate expressions
  /// and form FMAs.
  ///
  /// Floating-point addition and multiplication are not associative operations,
  /// so the Swift compiler does not have any flexibility in how it evaluates
  /// an expression like:
  /// ```
  /// func sumOfSquares(array: [Float]) -> Float {
  ///   array.reduce(0) { $0 + $1*$1 }
  /// }
  /// ```
  /// Using `Relaxed.sum` and `Relaxed.product` instead of `+` and `*` permits
  /// the compiler to reorder the terms in the summation, which unlocks loop
  /// unrolling and vectorization, and form fused multiply-adds, which allows
  /// us to achieve twice the throughput on some hardware.
  ///
  /// If a type or toolchain does not support reassociation for optimization
  /// purposes, this operation decays to a normal multiplication; it is a
  /// license for the compiler to optimize, not a guarantee that any change
  /// occurs.
  @_transparent
  public static func product<T: AlgebraicField>(_ a: T, _ b: T) -> T {
    T._relaxedMul(a, b)
  }
}

extension Relaxed {
  /// a*b + c, computed _either_ with an FMA or with separate multiply and add,
  /// whichever is fastest according to the optimizer's heuristics.
  @_transparent
  public static func multiplyAdd<T: AlgebraicField>(
    _ a: T, _ b: T, _ c: T
  ) -> T {
    T._relaxedAdd(c, T._relaxedMul(a, b))
  }
}
