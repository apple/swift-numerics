//===--- Quaternion+Hashable.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2022 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Quaternion: Hashable {
  /// Returns a Boolean value indicating whether two values are equal.
  ///
  /// - Important:
  ///   Quaternions are frequently used to represent 3D transformations. It's
  ///   important to be aware that, when used this way, any quaternion and its
  ///   negation represent the same transformation, but they do not compare
  ///   equal using `==` because they are not the same quaternion. You can
  ///   compare quaternions as 3D transformations using `equals(as3DTransform:)`.
  @_transparent
  public static func == (lhs: Quaternion, rhs: Quaternion) -> Bool {
    // Identify all numbers with either component non-finite as a single "point at infinity".
    guard lhs.isFinite || rhs.isFinite else { return true }
    // For finite numbers, equality is defined componentwise. Cases where
    // only one of lhs or rhs is infinite fall through to here as well, but this
    // expression correctly returns false for them so we don't need to handle
    // them explicitly.
    return lhs.components == rhs.components
  }

  /// Returns a Boolean value indicating whether the 3D transformation of the
  /// two quaternions are equal.
  ///
  /// Use this method to test for equality of the 3D transformation properties
  /// of quaternions; where for any quaternion `q`, its negation represent the
  /// same 3D transformation; i.e. `q.equals(as3DTransform: q)` as well as
  /// `q.equals(as3DTransform: -q)` are both `true`.
  ///
  /// - Parameter other: The value to compare.
  /// - Returns: True if the 3D transformation of this quaternion equals `other`.
  @_transparent
  public func equals(as3DTransform other: Quaternion) -> Bool {
    // Identify all numbers with either component non-finite as a single "point at infinity".
    guard isFinite || other.isFinite else { return true }
    // For finite numbers, equality is defined componentwise. Cases where only
    // one of lhs or rhs is infinite fall through to here as well, but this
    // expression correctly returns false for them so we don't need to handle
    // them explicitly.
    return components == other.components || components == -other.components
  }

  @_transparent
  public func hash(into hasher: inout Hasher) {
    // There are two equivalence classes to which we owe special attention:
    // All zeros should hash to the same value, regardless of sign, and all
    // non-finite numbers should hash to the same value, regardless of
    // representation. The correct behavior for zero falls out for free from
    // the hash behavior of floating-point, but we need to use a
    // representative member for any non-finite values.
    // For any normal values we use the "canonical transform" representation,
    // where real is always non-negative. This allows people who are using
    // quaternions as rotations to get the expected semantics out of collections
    // (while unfortunately producing some collisions for people who are not,
    // but not in too catastrophic of a fashion).
    if isFinite {
      canonicalizedTransform.components.hash(into: &hasher)
    } else {
      hasher.combine(RealType.infinity)
    }
  }
}
