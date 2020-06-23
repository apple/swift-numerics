//===--- Transformation.swift ---------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Quaternion {
  /// The [rotation angle][wiki] of the Angle-Axis representation.
  ///
  /// Returns the rotation angle about the rotation *axis* in radians
  /// within *[0, 2π]* range.
  ///
  /// Edge cases:
  /// -
  /// - If the quaternion is zero or non-finite, angle is `nan`.
  ///
  /// See also:
  /// -
  /// - `.axis`
  /// - `.angleAxis`
  /// - `.polar`
  /// - `.rotationVector`
  /// - `init(angle:axis:)`
  /// - `init(length:angle:axis)`
  /// - `init(rotation:)`
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
  /// -
  /// - If the quaternion is zero or non-finite, axis is `nan` in all lanes.
  /// - If the rotation angle is zero, axis is `nan` in all lanes.
  ///
  /// See also:
  /// -
  /// - `.angle`
  /// - `.angleAxis`
  /// - `.polar`
  /// - `.rotationVector`
  /// - `init(angle:axis:)`
  /// - `init(length:angle:axis)`
  /// - `init(rotation:)`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Recovering_the_axis-angle_representation
  @inlinable
  public var axis: SIMD3<RealType> {
    guard isFinite && imaginary != .zero && !real.isZero else {
      return SIMD3(repeating: .nan)
    }
    return imaginary / .sqrt(imaginary.lengthSquared)
  }

  /// The [Angle-Axis][wiki] representation.
  ///
  /// Returns the rotation angle in radians within *[0, 2π]* and the rotation
  /// axis as SIMD3 vector of unit length.
  ///
  /// Edge cases:
  /// -
  /// - If the quaternion is zero or non-finite, angle and axis are `nan`.
  /// - If the angle is zero, axis is `nan` in all lanes.
  ///
  /// See also:
  /// -
  /// - `.angle`
  /// - `.axis`
  /// - `.polar`
  /// - `.rotationVector`
  /// - `init(angle:axis:)`
  /// - `init(length:angle:axis)`
  /// - `init(rotation:)`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Recovering_the_axis-angle_representation
  public var angleAxis: (angle: RealType, axis: SIMD3<RealType>) {
    (angle, axis)
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
  /// -
  /// - If the quaternion is zero or non-finite, the rotation vector is `nan`
  /// in all lanes.
  /// - If the rotation angle is zero, the rotation vector is `nan`
  /// in all lanes.
  ///
  /// See also:
  /// -
  /// - `.angle`
  /// - `.axis`
  /// - `.angleAxis`
  /// - `init(angle:axis:)`
  /// - `init(length:angle:axis)`
  /// - `init(rotation:)`
  ///
  /// [rotvector]: https://en.wikipedia.org/wiki/Axis–angle_representation#Rotation_vector
  @_transparent
  public var rotationVector: SIMD3<RealType> {
    axis * angle
  }

  /// The [polar decomposition][wiki].
  ///
  /// Returns the length of this quaternion, phase in radians of range *[0, π]*
  /// and the rotation axis as SIMD3 vector of unit length.
  ///
  /// Edge cases:
  /// -
  /// - If the quaternion is zero, length is `.zero` and angle and axis
  /// are `nan`.
  /// - If the quaternion is non-finite, length is `.infinity` and angle and
  /// axis are `nan`.
  /// - For any length other than `.zero` or `.infinity`, if angle is zero, axis
  /// is `nan`.
  ///
  /// See also:
  /// -
  /// - `.angle`
  /// - `.axis`
  /// - `.angleAxis`
  /// - `.rotationVector`
  /// - `init(angle:axis:)`
  /// - `init(length:angle:axis)`
  /// - `init(rotation:)`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Polar_decomposition#Quaternion_polar_decomposition
  public var polar: (length: RealType, phase: RealType, axis: SIMD3<RealType>) {
    (length, halfAngle, axis)
  }

  /// Creates a unit quaternion specified with [Angle-Axis][wiki] values.
  ///
  /// Angle-Axis is a representation of a 3D rotation using two different
  /// quantities: an angle describing the magnitude of rotation, and a vector
  /// of unit length indicating the axis direction to rotate along.
  ///
  /// This initializer reads given `angle` and `axis` values and creates a
  /// quaternion of equal rotation properties using the following equation:
  ///
  ///     Q = (cos(angle/2), axis * sin(angle/2))
  ///
  /// Given `axis` gets normalized if it is not of unit length.
  ///
  /// The final quaternion is of unit length.
  ///
  /// Edge cases:
  /// -
  /// - For any `θ`, even `.infinity` or `.nan`:
  ///   ```
  ///   Quaternion(angle: θ, axis: .zero) == .zero
  ///   ```
  /// - For any `θ`, even `.infinity` or `.nan`:
  ///   ```
  ///   Quaternion(angle: θ, axis: .infinity) == .ininfity
  ///   ```
  /// - Otherwise, `θ` must be finite, or a precondition failure occurs.
  ///
  /// See also:
  /// -
  /// - `.angle`
  /// - `.axis`
  /// - `.angleAxis`
  /// - `.rotationVector`
  /// - `.polar`
  /// - `init(rotation:)`
  /// - `init(length:angle:axis)`
  ///
  /// - Parameter angle: The rotation angle about the rotation axis in radians
  /// - Parameter axis: The rotation axis
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Recovering_the_axis-angle_representation
  @inlinable
  public init(angle: RealType, axis: SIMD3<RealType>) {
    let length: RealType = .sqrt(axis.lengthSquared)
    if angle.isFinite && length.isNormal {
      self = Quaternion(halfAngle: angle/2, unitAxis: axis/length)
    } else {
      precondition(
        length.isZero || length.isInfinite,
        "Either angle must be finite, or axis length must be zero or infinite."
      )
      self = Quaternion(length)
    }
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
  /// -
  /// - If `vector` is `.zero`, the quaternion is `.zero`:
  ///   ```
  ///   Quaternion(rotation: .zero) == .zero
  ///   ```
  /// - If `vector` is `.infinity` or `-.infinity`, the quaternion is `.infinity`:
  ///   ```
  ///   Quaternion(rotation: -.infinity) == .infinity
  ///   ```
  ///
  /// See also:
  /// -
  /// - `.angle`
  /// - `.axis`
  /// - `.angleAxis`
  /// - `.polar`
  /// - `.rotationVector`
  /// - `init(angle:axis:)`
  /// - `init(length:angle:axis)`
  ///
  /// - Parameter vector: The rotation vector.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Axis–angle_representation#Rotation_vector
  @inlinable
  public init(rotation vector: SIMD3<RealType>) {
    let angle: RealType = .sqrt(vector.lengthSquared)
    if !angle.isZero && angle.isFinite {
      self = Quaternion(halfAngle: angle/2, unitAxis: vector/angle)
    } else {
      self = Quaternion(angle)
    }
  }

  /// Creates a quaternion specified with [polar coordinates][wiki].
  ///
  /// This initializer reads given `length`, `phase` and `axis` values and
  /// creates a quaternion of equal rotation properties and specified *length*
  /// using the following equation:
  ///
  ///     Q = (cos(phase), axis * sin(phase)) * length
  ///
  /// Given `axis` gets normalized if it is not of unit length.
  ///
  /// Edge cases:
  /// -
  /// - Negative lengths are interpreted as reflecting the point through the origin, i.e.:
  ///   ```
  ///   Quaternion(length: -r, angle: θ, axis: axis) == Quaternion(length: -r, angle: θ, axis: axis)
  ///   ```
  /// - For any `θ` and any `axis`, even `.infinity` or `.nan`:
  ///   ```
  ///   Quaternion(length: .zero, angle: θ, axis: axis) == .zero
  ///   ```
  /// - For any `θ` and any `axis`, even `.infinity` or `.nan`:
  ///   ```
  ///   Quaternion(length: .infinity, angle: θ, axis: axis) == .infinity
  ///   ```
  /// - Otherwise, `θ` and `axis` must be finite, or a precondition failure occurs.
  ///
  /// See also:
  /// -
  /// - `.angle`
  /// - `.axis`
  /// - `.angleAxis`
  /// - `.rotationVector`
  /// - `.polar`
  /// - `init(angle:axis)`
  /// - `init(rotation:)`
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Polar_decomposition#Quaternion_polar_decomposition
  @inlinable
  public init(length: RealType, phase: RealType, axis: SIMD3<RealType>) {
    let axisLength: RealType = .sqrt(axis.lengthSquared)
    if phase.isFinite && axisLength.isNormal {
      self = Quaternion(
        halfAngle: phase,
        unitAxis: axis/axisLength
      ).multiplied(by: length)
    } else {
      precondition(
        length.isZero || length.isInfinite,
        "Either angle must be finite, or length must be zero or infinite."
      )
      self = Quaternion(length)
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
  /// where `p` is a *pure* quaternion (`real == .zero`) with imaginary part equal
  /// to vector `v`, and where `p'` is another pure quaternion with imaginary
  /// part equal to the transformed vector `v'`. The implementation uses this
  /// formular but boils down to a simpler and faster implementation as `p` is
  /// known to be pure and `q` is assumed to have unit length – which allows
  /// simplification.
  ///
  /// - Note: This method assumes this quaternion is of unit length.
  ///
  /// Edge cases:
  /// -
  /// - For any quaternion `q`, even `.zero` or `.infinity`, if `vector` is
  /// `.infinity` or `-.infinity` in any of the lanes or all, the returning
  /// vector is `.infinity` in all lanes:
  ///   ```
  ///   SIMD3(-.infinity,0,0) * q == SIMD3(.infinity,.infinity,.infinity)
  ///   ```
  ///
  /// - Parameter vector: A vector to rotate by this quaternion
  /// - Returns: The vector rotated by this quaternion
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Using_quaternion_as_rotations
  @inlinable
  public func act(on vector: SIMD3<RealType>) -> SIMD3<RealType> {
    guard vector.isFinite else { return SIMD3(repeating: .infinity) }

    // The following expression have been split up so the type-checker
    // can resolve them in a reasonable time.
    let p1 = vector * (real*real - imaginary.lengthSquared)
    let p2 = 2 * imaginary * imaginary.dot(vector)
    let p3 = 2 * real * imaginary.cross(vector)
    let rotatedVector = p1 + p2 + p3
    if rotatedVector.isFinite { return rotatedVector }

    // If the vector is no longer finite after it is rotated, scale it down,
    // rotate it again and then scale it back-up after the rotation operation
    let scale = max(abs(vector.max()), abs(vector.min()))
    return act(on: vector/scale) * scale
  }
}

// MARK: - Transformation Helper
//
// While Angle/Axis, Rotation Vector and Polar are different representations
// of transformations, they have common properties such as being based on a
// rotation *angle* about a rotation axis of unit length.
//
// The following extension provides these common operation internally.
extension Quaternion {
  /// The half rotation angle in radians within *[0, π]* range.
  ///
  /// Edge cases:
  /// -
  /// If the quaternion is zero or non-finite, halfAngle is `nan`.
  @usableFromInline @inline(__always)
  internal var halfAngle: RealType {
    guard !isZero && isFinite else { return .nan }
    return .atan2(y: .sqrt(imaginary.lengthSquared), x: real)
  }

  /// Creates a new quaternion from given half rotation angle about given
  /// rotation axis.
  ///
  /// The angle-axis values are transformed using the following equation:
  ///
  ///     Q = (cos(halfAngle), unitAxis * sin(halfAngle))
  ///
  /// - Parameters:
  ///   - halfAngle: The half rotation angle
  ///   - unitAxis: The rotation axis of unit length
  @usableFromInline @inline(__always)
  internal init(halfAngle: RealType, unitAxis: SIMD3<RealType>) {
    self.init(.cos(halfAngle), unitAxis * .sin(halfAngle))
  }
}

// MARK: - SIMD Helper
//
// Provides common vector operations on SIMD3 to ease the use of "imaginary"
// and *(x,y,z)* axis representations internally to the module.
extension SIMD3 where Scalar: FloatingPoint {

  /// Returns the squared length of this instance.
  @usableFromInline @inline(__always)
  internal var lengthSquared: Scalar {
    dot(self)
  }

  /// True if all values of this instance are finite
  @usableFromInline @inline(__always)
  internal var isFinite: Bool {
    x.isFinite && y.isFinite && z.isFinite
  }

  /// Returns the scalar/dot product of this vector with `other`.
  @usableFromInline @inline(__always)
  internal func dot(_ other: SIMD3<Scalar>) -> Scalar {
    (self * other).sum()
  }

  /// Returns the vector/cross product of this vector with `other`.
  @usableFromInline @inline(__always)
  internal func cross(_ other: SIMD3<Scalar>) -> SIMD3<Scalar> {
    let yzx = SIMD3<Int>(1,2,0)
    let zxy = SIMD3<Int>(2,0,1)
    return (self[yzx] * other[zxy]) - (self[zxy] * other[yzx])
  }
}
