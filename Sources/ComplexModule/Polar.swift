//===--- Polar.swift ------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2025 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule

extension Complex {
  /// The Euclidean norm (a.k.a. 2-norm).
  ///
  /// This property takes care to avoid spurious over- or underflow in
  /// this computation. For example:
  ///
  ///     let x: Float = 3.0e+20
  ///     let x: Float = 4.0e+20
  ///     let naive = sqrt(x*x + y*y) // +Inf
  ///     let careful = Complex(x, y).length // 5.0e+20
  ///
  /// Note that it *is* still possible for this property to overflow,
  /// because the length can be as much as sqrt(2) times larger than
  /// either component, and thus may not be representable in the real type.
  ///
  /// For most use cases, you can use the cheaper ``magnitude``
  /// property (which computes the ∞-norm) instead, which always produces
  /// a representable result. See <doc:Magnitude> for more details.
  ///
  /// Edge cases:
  /// - If a complex value is not finite, its `length` is `infinity`.
  ///
  /// See also ``lengthSquared``, ``phase``, ``polar``
  /// and ``init(length:phase:)``.
  @_transparent
  public var length: RealType {
    let naive = lengthSquared
    guard naive.isNormal else { return carefulLength }
    return .sqrt(naive)
  }
  
  //  Internal implementation detail of ``length``, moving slow path off
  //  of the inline function. Note that even `carefulLength` can overflow
  //  for finite inputs, but only when the result is outside the range
  //  of representable values.
  @usableFromInline
  internal var carefulLength: RealType {
    guard isFinite else { return .infinity }
    return .hypot(x, y)
  }
  
  /// The squared length `(real*real + imaginary*imaginary)`.
  ///
  /// This property is more efficient to compute than ``length``, but is
  /// highly prone to overflow or underflow; for finite values that are
  /// not well-scaled, `lengthSquared` is often either zero or
  /// infinity, even when `length` is a finite number. Use this property
  /// only when you are certain that this value is well-scaled.
  ///
  /// For many cases, ``magnitude`` can be used instead, which is similarly
  /// cheap to compute and always returns a representable value.
  ///
  /// Note that because of how `lengthSquared` is used, it is a primary
  /// design goal that it be as fast as possible. Therefore, it does not
  /// normalize infinities, and may return either `.infinity` or `.nan`
  /// for non-finite values.
  @_transparent
  public var lengthSquared: RealType {
    x*x + y*y
  }
  
  /// The phase (angle, or "argument").
  ///
  /// - Returns: The angle (measured above the real axis) in radians. If
  /// the complex value is zero or infinity, the phase is not defined,
  /// and `nan` is returned.
  ///
  /// See also ``length``, ``polar`` and ``init(length:phase:)``.
  @inlinable
  public var phase: RealType {
    guard isFinite && !isZero else { return .nan }
    return .atan2(y: y, x: x)
  }
  
  /// The length and phase (or polar coordinates) of this value.
  ///
  /// Edge cases:
  /// - If the complex value is zero or non-finite, phase is `.nan`.
  /// - If the complex value is non-finite, length is `.infinity`.
  ///
  /// See also: ``length``, ``phase`` and ``init(length:phase:)``.
  public var polar: (length: RealType, phase: RealType) {
    (length, phase)
  }
  
  /// Creates a complex value specified with polar coordinates.
  ///
  /// Edge cases:
  /// - Negative lengths are interpreted as reflecting the point through the
  ///   origin, i.e.:
  ///   ```
  ///   Complex(length: -r, phase: θ) == -Complex(length: r, phase: θ)
  ///   ```
  /// - For any `θ`, even `.infinity` or `.nan`:
  ///   ```
  ///   Complex(length: .zero, phase: θ) == .zero
  ///   ```
  /// - For any `θ`, even `.infinity` or `.nan`, if `r` is infinite then:
  ///   ```
  ///   Complex(length: r, phase: θ) == .infinity
  ///   ```
  /// - Otherwise, `θ` must be finite, or a precondition failure occurs.
  ///
  /// See also ``length``, ``phase`` and ``polar``.
  @inlinable
  public init(length: RealType, phase: RealType) {
    if phase.isFinite {
      self = Complex(.cos(phase), .sin(phase)).multiplied(by: length)
    } else {
      precondition(
        length.isZero || length.isInfinite,
        "Either phase must be finite, or length must be zero or infinite."
      )
      self = Complex(length)
    }
  }
}
