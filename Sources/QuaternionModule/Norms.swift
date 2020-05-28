//===--- Norms.swift ------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// Norms and related quantities defined for Quaternion.
//
// The following API are provided by this extension:
//
//   var magnitude: RealType     // infinity norm
//   var length: RealType        // Euclidean norm
//   var lengthSquared: RealType // Euclidean norm squared
//
// For detailed documentation, consult Norms.md or the inline documentation
// for each operation.
//
// Implementation notes:
//
// `.magnitude` does not bind the Euclidean norm; it binds the infinity norm
// instead. There are two reasons for this choice:
//
// - It's simply faster to compute in general, because it does not require
//   a square root.
//
// - There exist finite values `q` for which the Euclidean norm is not
//   representable (consider the quaternion with `a`, `b`, `c` and `d` all
//   equal to `RealType.greatestFiniteMagnitude`; the Euclidean norm is
//   `.sqrt(4) * .greatestFiniteMagnitude`, which overflows).
//
// The infinity norm is unique among the common vector norms in having
// the property that every finite vector has a representable finite norm,
// which makes it the obvious choice to bind `.magnitude`.
extension Quaternion {

  /// The ∞-norm of the value (`max(abs(a), abs(b), abs(c), abs(d))`).
  ///
  /// If you need the Euclidean norm (a.k.a. 2-norm) use the `length` or `lengthSquared`
  /// properties instead.
  ///
  /// Edge cases:
  /// -
  /// - If `q` is not finite, `q.magnitude` is `.infinity`.
  /// - If `q` is zero, `q.magnitude` is `0`.
  /// - Otherwise, `q.magnitude` is finite and non-zero.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.lengthSquared`
  @_transparent
  public var magnitude: RealType {
    guard isFinite else { return .infinity }
    return max(abs(components.max()), abs(components.min()))
  }

  /// The Euclidean norm (a.k.a. 2-norm, `sqrt(a*a + b*b + c*c + d*d)`).
  ///
  /// This value is highly prone to overflow or underflow.
  ///
  /// For most use cases, you can use the cheaper `.magnitude`
  /// property (which computes the ∞-norm) instead, which always produces
  /// a representable result.
  ///
  /// Edge cases:
  /// -
  /// If a quaternion is not finite, its `.length` is `infinity`.
  ///
  /// See also:
  /// -
  /// - `.magnitude`
  /// - `.lengthSquared`
  @_transparent
  public var length: RealType {
    guard isFinite else { return .infinity }
    return .sqrt(lengthSquared)
  }

  /// The squared length `(a*a + b*b + c*c + d*d)`.
  ///
  /// This value is highly prone to overflow or underflow.
  /// 
  /// For many cases, `.magnitude` can be used instead, which is similarly
  /// cheap to compute and always returns a representable value.
  ///
  /// This property is more efficient to compute than `length`.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.magnitude`
  @_transparent
  public var lengthSquared: RealType {
    (components * components).sum()
  }
}
