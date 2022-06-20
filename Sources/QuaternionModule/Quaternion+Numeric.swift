//===--- Quaternion+Numeric.swift -----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2022 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Quaternion: Numeric {
  @_transparent
  public static func * (lhs: Quaternion, rhs: Quaternion) -> Quaternion {

    let rhsX = SIMD4(+rhs.components.w, +rhs.components.z, -rhs.components.y, +rhs.components.x)
    let rhsY = SIMD4(-rhs.components.z, +rhs.components.w, +rhs.components.x, +rhs.components.y)
    let rhsZ = SIMD4(+rhs.components.y, -rhs.components.x, +rhs.components.w, +rhs.components.z)
    let rhsR = SIMD4(-rhs.components.x, -rhs.components.y, -rhs.components.z, +rhs.components.w)

    let x = (lhs.components * rhsX).sum()
    let y = (lhs.components * rhsY).sum()
    let z = (lhs.components * rhsZ).sum()
    let r = (lhs.components * rhsR).sum()

    return Quaternion(from: SIMD4(x,y,z,r))
  }

  @_transparent
  public static func *= (lhs: inout Quaternion, rhs: Quaternion) {
    lhs = lhs * rhs
  }

  /// The quaternion with specified real part and zero imaginary part.
  ///
  /// Equivalent to `Quaternion(RealType(real))`.
  @inlinable
  public init<Other: BinaryInteger>(_ real: Other) {
    self.init(RealType(real))
  }

  /// The quaternion with specified real part and zero imaginary part,
  /// if it can be constructed without rounding.
  @inlinable
  public init?<Other: BinaryInteger>(exactly real: Other) {
    guard let real = RealType(exactly: real) else { return nil }
    self.init(real)
  }

  /// The ∞-norm of the value (`max(abs(r), abs(x), abs(y), abs(z))`).
  ///
  /// If you need the Euclidean norm (a.k.a. 2-norm) use the `length` or `lengthSquared`
  /// properties instead.
  ///
  /// Edge cases:
  /// - If `q` is not finite, `q.magnitude` is `.infinity`.
  /// - If `q` is zero, `q.magnitude` is `0`.
  /// - Otherwise, `q.magnitude` is finite and non-zero.
  ///
  /// See also `.length` and `.lengthSquared`
  @_transparent
  public var magnitude: RealType {
    guard isFinite else { return .infinity }
    return max(abs(components.max()), abs(components.min()))
  }
}
