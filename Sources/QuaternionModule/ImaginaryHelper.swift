//===--- ImaginaryHelper.swift --------------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019-2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

// Provides common vector operations on SIMD3 to ease the use of the quaternions
// imaginary/vector components internally to the module, and in tests.
extension SIMD3 where Scalar: FloatingPoint {
  /// Returns a vector with infinity in all lanes
  @usableFromInline @inline(__always)
  internal static var infinity: Self {
    SIMD3(repeating: .infinity)
  }

  /// Returns a vector with nan in all lanes
  @usableFromInline @inline(__always)
  internal static var nan: Self {
    SIMD3(repeating: .nan)
  }

  /// Returns a vector with .ulpOfOne in all lanes
  @usableFromInline @inline(__always)
  internal static var ulpOfOne: Self {
    SIMD3(repeating: .ulpOfOne)
  }

  /// True if all values of this instance are finite
  @usableFromInline @inline(__always)
  internal var isFinite: Bool {
    x.isFinite && y.isFinite && z.isFinite
  }

  /// The ∞-norm of the value (`max(abs(x), abs(y), abs(z))`).
  @usableFromInline @inline(__always)
  internal var magnitude: Scalar {
    Swift.max(x.magnitude, y.magnitude, z.magnitude)
  }

  /// The 1-norm of the value (`abs(x) + abs(y) + abs(z))`).
  @usableFromInline @inline(__always)
  internal var oneNorm: Scalar {
    x.magnitude + y.magnitude + z.magnitude
  }

  /// The Euclidean norm (a.k.a. 2-norm, `sqrt(x*x + y*y + z*z)`).
  @usableFromInline @inline(__always)
  internal var length: Scalar {
    let naive = lengthSquared
    guard naive.isNormal else { return carefulLength }
    return naive.squareRoot()
  }

  // Implementation detail of `length`, moving slow path off of the
  // inline function.
  @usableFromInline
  internal var carefulLength: Scalar {
    guard isFinite else { return .infinity }
    guard !magnitude.isZero else { return .zero }
    // Unscale the vector, calculate its length and rescale the result
    return (self / magnitude).length * magnitude
  }

  /// Returns the squared length of this instance.
  @usableFromInline @inline(__always)
  internal var lengthSquared: Scalar {
    dot(self)
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
