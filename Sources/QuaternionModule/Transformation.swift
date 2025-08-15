//===--- Transformation.swift ---------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 - 2022 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule

extension Quaternion {
  /// The [rotation angle][wiki] of the Angle-Axis representation.
  ///
  /// Returns the rotation angle about the rotation *axis* in radians
  /// within *[0, 2π]* range.
  ///
  /// Edge cases:
  /// - If the quaternion is zero or non-finite, angle is `nan`.
  ///
  /// See also `.axis`, `.angleAxis`, `.rotationVector`,
  /// `init(length:angle:axis:)` and `init(rotation:)`.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Recovering_the_axis-angle_representation
  @inlinable
  public var angle: RealType {
    2 * halfAngle
  }

  /// The [rotation axis][wiki] of the Angle-Axis representation.
  ///
  /// Returns the *(x,y,z)* rotation axis encoded in the quaternion
  /// as SIMD3 vector of unit length.
  ///
  /// Edge cases:
  /// - If the quaternion is zero or non-finite, axis is `nan` in all lanes.
  /// - If the rotation angle is zero, axis is `nan` in all lanes.
  ///
  /// See also `.angle`, `.angleAxis`, `.rotationVector`,
  /// `init(length:angle:axis:)` and `init(rotation:)`.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Recovering_the_axis-angle_representation
  @inlinable
  public var axis: SIMD3<RealType> {
    guard isFinite, imaginary != .zero else { return SIMD3(repeating: .nan) }

    // If lengthSquared computes without over/underflow, everything is fine
    // and the result is correct. If not, we have to do the computation
    // carefully and unscale the quaternion first.
    let lenSq = imaginary.lengthSquared
    guard lenSq.isNormal else { return divided(by: magnitude).axis }
    return imaginary / .sqrt(lenSq)
  }

  /// The [Angle-Axis][wiki] representation.
  ///
  /// Returns the length of the quaternion, the rotation angle in radians
  /// within *[0, 2π]* and the rotation axis as SIMD3 vector of unit length.
  ///
  /// Edge cases:
  /// - If the quaternion is zero or non-finite, angle and axis are `nan`.
  /// - If the angle is zero, axis is `nan` in all lanes.
  ///
  /// See also `.angle`, `.axis`, `.rotationVector`, `init(length:angle:axis:)`
  /// and `init(rotation:)`.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Recovering_the_axis-angle_representation
  public var angleAxis: (length: RealType, angle: RealType, axis: SIMD3<RealType>) {
    (length, angle, axis)
  }

  /// The [rotation vector][rotvector].
  ///
  /// A rotation vector is a vector of same direction as the rotation axis,
  /// whose length is the rotation angle of an Angle-Axis representation. It
  /// is effectively the product of multiplying the rotation `axis` by the
  /// rotation `angle`. Rotation vectors are often called "scaled axis" — this
  /// is a different name for the same concept.
  ///
  /// Edge cases:
  /// - If the quaternion is zero or non-finite, the rotation vector is `nan`
  /// in all lanes.
  /// - If the rotation angle is zero, the rotation vector is `nan`
  /// in all lanes.
  ///
  /// See also `.angle`, `.axis`, `.angleAxis`, `init(length:angle:axis:)`
  /// and `init(rotation:)`.
  ///
  /// [rotvector]: https://en.wikipedia.org/wiki/Axis–angle_representation#Rotation_vector
  @_transparent
  public var rotationVector: SIMD3<RealType> {
    axis * angle
  }

  /// Creates a unit quaternion specified with [Angle-Axis][wiki] values.
  ///
  /// Angle-Axis is a representation of a three-dimensional rotation using two
  /// different quantities: an angle describing the magnitude of rotation, and
  /// a vector of unit length indicating the axis direction to rotate along.
  /// The optional length parameter scales the quaternion after the conversion.
  ///
  /// This initializer reads given `length`, `angle` and `axis` values and
  /// creates a quaternion of equal rotation properties and of specified length
  /// using the following equation:
  ///
  ///     Q = (cos(angle/2), axis * sin(angle/2)) * length
  ///
  /// If `length` is not specified, it defaults to *1*; and the final
  /// quaternion is of unit length.
  ///
  /// - Note: `axis` must be of unit length, or an assertion failure occurs.
  ///
  /// Edge cases:
  /// - Negative lengths are interpreted as reflecting the point through the origin, i.e.:
  ///   ```
  ///   Quaternion(length: -r, angle: θ, axis: axis) == -Quaternion(length: r, angle: θ, axis: axis)
  ///   ```
  /// - For any `θ` and any `axis`, even `.infinity` or `.nan`:
  ///   ```
  ///   Quaternion(length: .zero, angle: θ, axis: axis) == .zero
  ///   ```
  /// - For any `θ` and any `axis`, even `.infinity` or `.nan`:
  ///   ```
  ///   Quaternion(length: .infinity, angle: θ, axis: axis) == .infinity
  ///   ```
  /// - Otherwise, `θ` must be finite, or a precondition failure occurs.
  ///
  /// See also `.angle`, `.axis`, `.angleAxis`, `.rotationVector`
  /// and `init(rotation:)`.
  ///
  /// - Parameter length: The length of the quaternion. Defaults to `1`.
  /// - Parameter angle: The rotation angle about the rotation axis in radians.
  /// - Parameter axis: The rotation axis. Must be of unit length.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Recovering_the_axis-angle_representation
  @inlinable
  public init(length: RealType = 1, angle: RealType, axis: SIMD3<RealType>) {
    guard !length.isZero, length.isFinite else {
      self = Quaternion(length)
      return
    }

    // Length is finite and non-zero, therefore
    // 1. `angle` must be finite or a precondition failure needs to occur; as
    //    this is not representable.
    // 2. `axis` must be of unit length or an assertion failure occurs; while
    //    "wrong" by definition, it is representable.
    precondition(
      angle.isFinite,
      "Either angle must be finite, or length must be zero or infinite."
    )
    assert(
      // TODO: Replace with `approximateEquality()`
      abs(.sqrt(axis.lengthSquared)-1) < max(.sqrt(axis.lengthSquared), 1)*RealType.ulpOfOne.squareRoot(),
      "Given axis must be of unit length."
    )

    self = Quaternion(halfAngle: angle/2, unitAxis: axis).multiplied(by: length)
  }

  /// Creates a unit quaternion specified with given [rotation vector][wiki].
  ///
  /// A rotation vector is a vector of same direction as the rotation axis,
  /// whose length is the rotation angle of an Angle-Axis representation. It
  /// is effectively the product of multiplying the rotation `axis` by the
  /// rotation `angle`.
  ///
  /// This initializer reads the angle and axis values of given rotation vector
  /// and creates a quaternion of equal rotation properties using the following
  /// equation:
  ///
  ///     Q = (cos(angle/2), axis * sin(angle/2))
  ///
  /// Rotation vectors are sometimes referred to as *scaled axis* — this is a
  /// different name for the same concept.
  ///
  /// The final quaternion is of unit length.
  ///
  /// Edge cases:
  /// - If `vector` is `.zero`, the quaternion is `.zero`:
  ///   ```
  ///   Quaternion(rotation: .zero) == .zero
  ///   ```
  /// - If `vector` is `.infinity` or `-.infinity`, the quaternion is `.infinity`:
  ///   ```
  ///   Quaternion(rotation: -.infinity) == .infinity
  ///   ```
  ///
  /// See also `.angle`, `.axis`, `.angleAxis`, `.rotationVector`
  /// and `init(length:angle:axis:)`.
  ///
  /// - Parameter vector: The rotation vector.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Axis–angle_representation#Rotation_vector
  @inlinable
  public init(rotation vector: SIMD3<RealType>) {
    let angle: RealType = .sqrt(vector.lengthSquared)
    if !angle.isZero, angle.isFinite {
      self = Quaternion(halfAngle: angle/2, unitAxis: vector/angle)
    } else {
      self = Quaternion(angle)
    }
  }

  /// Transforms a vector by this quaternion.
  ///
  /// Quaternions are frequently used to represent three-dimensional
  /// transformations, and thus are used to transform vectors in
  /// three-dimensional space. The transformation of an arbitrary vector
  /// by a quaternion is known as an action.
  ///
  /// The canonical way of transforming an arbitrary three-dimensional vector
  /// `v` by a quaternion `q` is given by the following [formula][wiki]
  ///
  ///     p' = qpq⁻¹
  ///
  /// where `p` is a *pure* quaternion (`real == .zero`) with imaginary part
  /// equal to vector `v`, and where `p'` is another pure quaternion with
  /// imaginary part equal to the transformed vector `v'`. The implementation
  /// uses this formular but boils down to a simpler and faster implementation
  /// as `p` is known to be pure and `q` is assumed to have unit length – which
  /// allows for simplification.
  ///
  /// - Note: This method assumes this quaternion is of unit length.
  ///
  /// Edge cases:
  /// - For any quaternion `q`, even `.zero` or `.infinity`, if `vector` is
  /// `.infinity` or `-.infinity` in any of the lanes or all, the returning
  /// vector is `.infinity` in all lanes:
  ///   ```
  ///   SIMD3(-.infinity,0,0) * q == SIMD3(.infinity,.infinity,.infinity)
  ///   ```
  /// - For any quaternion `q`, even `.zero` or `.infinity`, if `vector` is
  /// `.zero`, the returning vector is also `.zero`.
  ///   ```
  ///   SIMD3(0,0,0) * q == .zero
  ///   ```
  ///
  /// - Parameter vector: A vector to rotate by this quaternion
  /// - Returns: The vector rotated by this quaternion
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Using_quaternion_as_rotations
  @inlinable
  public func act(on vector: SIMD3<RealType>) -> SIMD3<RealType> {
    guard vector.isFinite else { return .infinity }
    guard vector != .zero else { return .zero }

    // The following expression have been split up so the type-checker
    // can resolve them in a reasonable time.
    let p1 = vector * (real*real - imaginary.lengthSquared)
    let p2 = imaginary * imaginary.dot(vector)
    let p3 = imaginary.cross(vector) * real 
    let rotatedVector = p1 + (p2 + p3) * 2

    // If the rotation computes without over/underflow, everything is fine
    // and the result is correct. If not, we have to do the computation
    // carefully and first unscale the vector, rotate it again and then
    // rescale the vector
    if
        (rotatedVector.x.isNormal || rotatedVector.x.isZero) &&
        (rotatedVector.y.isNormal || rotatedVector.y.isZero) &&
        (rotatedVector.z.isNormal || rotatedVector.z.isZero)
    {
        return rotatedVector
    }
    let scale = max(abs(vector.max()), abs(vector.min()))
    return act(on: vector/scale) * scale
  }
}
