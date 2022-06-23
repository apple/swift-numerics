//===--- Polar.swift ------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2022 Apple Inc. and the Swift Numerics project authors
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
//   representable (consider the quaternion with `r`, `x`, `y` and `z` all
//   equal to `RealType.greatestFiniteMagnitude`; the Euclidean norm is
//   `.sqrt(4) * .greatestFiniteMagnitude`, which overflows).
//
// The infinity norm is unique among the common vector norms in having
// the property that every finite vector has a representable finite norm,
// which makes it the obvious choice to bind `.magnitude`.
extension Quaternion {
  /// The Euclidean norm (a.k.a. 2-norm, `sqrt(r*r + x*x + y*y + z*z)`).
  ///
  /// This value is highly prone to overflow or underflow.
  ///
  /// For most use cases, you can use the cheaper `.magnitude`
  /// property (which computes the ∞-norm) instead, which always produces
  /// a representable result.
  ///
  /// Edge cases:
  /// - If a quaternion is not finite, its `.length` is `infinity`.
  ///
  /// See also `.magnitude`, `.lengthSquared`, `.polar` and
  /// `init(length:argument:axis:)`.
  @_transparent
  public var length: RealType {
    let naive = lengthSquared
    guard naive.isNormal else { return carefulLength }
    return .sqrt(naive)
  }

  // Internal implementation detail of `length`, moving slow path off
  // of the inline function.
  @usableFromInline
  internal var carefulLength: RealType {
    guard isFinite else { return .infinity }
    guard !magnitude.isZero else { return .zero }
    // Unscale the quaternion, calculate its length and rescale the result
    return divided(by: magnitude).length * magnitude
  }

  /// The squared length `(r*r + x*x + y*y + z*z)`.
  ///
  /// This value is highly prone to overflow or underflow.
  /// 
  /// For many cases, `.magnitude` can be used instead, which is similarly
  /// cheap to compute and always returns a representable value.
  ///
  /// This property is more efficient to compute than `length`.
  ///
  /// See also `.magnitude`, `.length`, `.polar` and
  /// `init(length:argument:axis:)`.
  @_transparent
  public var lengthSquared: RealType {
    (components * components).sum()
  }

  /// The principle argument (half rotation angle) in radians within
  /// *[0, π]* range.
  ///
  /// Edge cases:
  /// - If the quaternion is zero or non-finite, argument is `nan`.
  @inlinable
  public var argument: RealType {
    guard isFinite else { return .nan }
    guard imaginary != .zero else {
      // A zero quaternion does not encode transformation properties.
      // If imaginary is zero, real must be non-zero or nan is returned.
      return real.isZero ? .nan : .zero
    }

    // If lengthSquared computes without over/underflow, everything is fine
    // and the result is correct. If not, we have to do the computation
    // carefully and unscale the quaternion first.
    let lenSq = imaginary.lengthSquared
    guard lenSq.isNormal else { return divided(by: magnitude).argument }
    return .atan2(y: .sqrt(lenSq), x: real)
  }

  /// The [polar decomposition][wiki].
  ///
  /// Returns the length of this quaternion, argument in radians of range
  /// *[0, π]* and the rotation axis as SIMD3 vector of unit length.
  ///
  /// Edge cases:
  /// - If the quaternion is zero, length is `.zero` and argument and axis
  /// are `nan`.
  /// - If the quaternion is non-finite, length is `.infinity` and argument and
  /// axis are `nan`.
  /// - For any length other than `.zero` or `.infinity`, if argument is zero,
  /// axis is `nan`.
  ///
  /// See also `.magnitude`, `.length`, `.lengthSquared` and
  /// `init(length:argument:axis:)`.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Polar_decomposition#Quaternion_polar_decomposition
  public var polar: (length: RealType, argument: RealType, axis: SIMD3<RealType>) {
    (length, argument, axis)
  }

  /// Creates a new quaternion from given half rotation angle about given
  /// rotation axis.
  ///
  /// The angle-axis values are transformed using the following equation:
  ///
  ///     Q = (cos(argument), unitAxis * sin(argument))
  ///
  /// - Parameters:
  ///   - argument: The half rotation angle
  ///   - unitAxis: The rotation axis of unit length
  @usableFromInline @inline(__always)
  internal init(argument: RealType, unitAxis: SIMD3<RealType>) {
    self.init(real: .cos(argument), imaginary: unitAxis * .sin(argument))
  }

  /// Creates a quaternion specified with [polar coordinates][wiki].
  ///
  /// This initializer reads given `length`, `argument` and `axis` values and
  /// creates a quaternion of equal rotation properties and specified *length*
  /// using the following equation:
  ///
  ///     Q = (cos(argument), axis * sin(argument)) * length
  ///
  /// Edge cases:
  /// - Negative lengths are interpreted as reflecting the point through the
  ///   origin, i.e.:
  ///   ```
  ///   Quaternion(length: -r, argument: θ, axis: axis) == -Quaternion(length: r, argument: θ, axis: axis)
  ///   ```
  /// - For any `θ` and any `axis`, even `.infinity` or `.nan`:
  ///   ```
  ///   Quaternion(length: .zero, argument: θ, axis: axis) == .zero
  ///   ```
  /// - For any `θ` and any `axis`, even `.infinity` or `.nan`:
  ///   ```
  ///   Quaternion(length: .infinity, argument: θ, axis: axis) == .infinity
  ///   ```
  /// - Otherwise, `θ` must be finite, or a precondition failure occurs and
  ///   `axis` must be of unit length, or an assertion failure occurs.
  ///
  /// See also `.magnitude`, `.length`, `.lengthSquared` and `.polar`.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Polar_decomposition#Quaternion_polar_decomposition
  @inlinable
  public init(length: RealType, argument: RealType, axis: SIMD3<RealType>) {
    guard !length.isZero, length.isFinite else {
      self = Quaternion(length)
      return
    }

    // Length is finite and non-zero, therefore
    // 1. `argument` must be finite or a precondition failure needs to occur; as
    //    this is not representable.
    // 2. `axis` must be of unit length or an assertion failure occurs; while
    //    "wrong" by definition, it is representable.
    precondition(
      argument.isFinite,
      "Either argument must be finite, or length must be zero or infinite."
    )
    assert(
      // TODO: Replace with `approximateEquality()`
      abs(.sqrt(axis.lengthSquared)-1) < max(.sqrt(axis.lengthSquared), 1)*RealType.ulpOfOne.squareRoot(),
      "Given axis must be of unit length."
    )

    self = Quaternion(argument: argument, unitAxis: axis).multiplied(by: length)
  }
}
