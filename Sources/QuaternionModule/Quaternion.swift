//===--- Quaternion.swift -------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule

/// A quaternion represented by a real and three imaginary parts.
///
/// TODO: More informations on type
///
/// Implementation notes:
/// -
///
/// `.magnitude` does not return the Euclidean norm; it uses the "infinity
/// norm" (`max(|a|,|b|,|c|,|d|)`) instead. There are two reasons for this
/// choice: first, it's simply faster to compute on most hardware. Second,
/// there exist values for which the Euclidean norm cannot be represented.
/// Using the infinity norm avoids this problem entirely without significant
/// downsides. You can access the Euclidean norm using the `length` property.
/// See `Complex` type of the swift-numerics package for additional details.
public struct Quaternion<RealType> where RealType: Real & SIMDScalar {

  /// The components of the 4-dimensional vector space of the quaternion.
  ///
  /// Components are stored within a 4-dimensional SIMD vector with the scalar component
  /// first, i.e. representing the most common mathmatical representation that is:
  ///
  ///     a + bi + cj + dk
  @usableFromInline @inline(__always)
  internal var components: SIMD4<RealType>

  /// Creates a new quaternion from given 4-dimensional vector.
  ///
  /// This initializer creates a new quaternion by reading the values of the vector as components
  /// of the quaternion with the scalar component ordered first, i.e in the form of:
  ///
  ///     a + bi + cj + dk
  ///
  /// - Parameter components: The components of the 4-dimensionsal vector space of the quaternion,
  /// scalar part first.
  @_transparent
  public init(from components: SIMD4<RealType>) {
    self.components = components
  }
}

// MARK: - Basic Property
extension Quaternion {
  /// The real part of this quaternion value.
  public var real: RealType {
    @_transparent
    _read { yield components[0] }

    @_transparent
    _modify { yield &components[0] }
  }

  /// The imaginary part of this quaternion value.
  public var imaginary: SIMD3<RealType> {
    @_transparent
    get { components[SIMD3(1,2,3)] }

    @_transparent
    set {
        components[1] = newValue[0]
        components[2] = newValue[1]
        components[3] = newValue[2]
    }
  }

  /// The additive identity, with real and imaginary parts all zero.
  ///
  /// See also:
  /// -
  /// - .one
  /// - .i
  /// - .infinity
  @_transparent
  public static var zero: Quaternion {
    .init(0)
  }

  /// The multiplicative identity, with real part one and imaginary parts all zero.
  ///
  /// See also:
  /// -
  /// - .zero
  /// - .i
  /// - .infinity
  @_transparent
  public static var one: Quaternion {
    .init(1)
  }

  /// The imaginary unit.
  ///
  /// See also:
  /// -
  /// - .zero
  /// - .one
  /// - .infinity
  @_transparent
  public static var i: Quaternion {
    .init(imaginary: SIMD3(repeating: 1))
  }

  /// The point at infinity.
  ///
  /// See also:
  /// -
  /// - .zero
  /// - .one
  /// - .i
  @_transparent
  public static var infinity: Quaternion {
    .init(.infinity)
  }

  /// The conjugate of this quaternion value.
  @_transparent
  public var conjugate: Quaternion {
    .init(from: components.replacing(with: -components, where: [false, true, true, true]))
  }

  /// True if this value is finite.
  ///
  /// A quaternion value is finite if neither component is infinity or nan.
  ///
  /// See also:
  /// -
  /// - `.isNormal`
  /// - `.isSubnormal`
  /// - `.isZero`
  /// - `.isPure`
  @_transparent
  public var isFinite: Bool {
    components.x.isFinite
        && components.y.isFinite
        && components.z.isFinite
        && components.w.isFinite
  }

  /// True if this value is normal.
  ///
  /// A quaternion is normal if it is finite and *either* the real or imaginary component is normal.
  /// A floating-point number representing one of the components is normal if its exponent allows a
  /// full-precision representation.
  ///
  /// See also:
  /// -
  /// - `.isFinite`
  /// - `.isSubnormal`
  /// - `.isZero`
  /// - `.isPure`
  @_transparent
  public var isNormal: Bool {
    isFinite && (
        real.isNormal || (imaginary.x.isNormal && imaginary.y.isNormal && imaginary.z.isNormal)
    )
  }

  /// True if this value is subnormal.
  ///
  /// A quaternion is subnormal if it is finite, not normal, and not zero. When the result of a
  /// computation is subnormal, underflow has occurred and the result generally does not have full
  /// precision.
  ///
  /// See also:
  /// -
  /// - `.isFinite`
  /// - `.isNormal`
  /// - `.isZero`
  /// - `.isPure`
  @_transparent
  public var isSubnormal: Bool {
    isFinite && !isNormal && !isZero
  }

  /// True if this value is zero.
  ///
  /// A quaternion is zero if *both* the real and imaginary components are zero.
  ///
  /// See also:
  /// -
  /// - `.isFinite`
  /// - `.isNormal`
  /// - `.isSubnormal`
  /// - `.isPure`
  @_transparent
  public var isZero: Bool {
    return components.x.isZero
        && components.y.isZero
        && components.z.isZero
        && components.w.isZero
  }

  /// True if this value is only defined by the imaginary part (`real == .zero`)
  @_transparent
  public var isPure: Bool {
    real.isZero
  }

  /// The ∞-norm of the value (`max(abs(real), abs(imaginary))`).
  ///
  /// If you need the Euclidean norm (a.k.a. 2-norm) use the `length` or `lengthSquared`
  /// properties instead.
  ///
  /// Edge cases:
  /// -
  /// - If `z` is not finite, `z.magnitude` is `.infinity`.
  /// - If `z` is zero, `z.magnitude` is `0`.
  /// - Otherwise, `z.magnitude` is finite and non-zero.
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
}

// MARK: - Additional Initializers
extension Quaternion {
  /// The quaternion with specified real part and zero imaginary part.
  ///
  /// Equivalent to `Quaternion(real, SIMD3(repeating: 0))`.
  @inlinable
  public init(_ real: RealType) {
    self.init(real, SIMD3(repeating: 0))
  }

  /// The quaternion with specified imaginary part and zero real part.
  ///
  /// Equivalent to `Quaternion(0, imaginary)`.
  @inlinable
  public init(imaginary: SIMD3<RealType>) {
    self.init(0, imaginary)
  }

  /// The quaternion with specified imaginary part and zero real part.
  ///
  /// Equivalent to `Quaternion(0, imaginary)`.
  @inlinable
  public init(imaginary: (b: RealType, c: RealType, d: RealType)) {
    self.init(imaginary: SIMD3(imaginary.b, imaginary.c, imaginary.d))
  }

  /// The quaternion with specified real part and imaginary parts.
  @inlinable
  public init(_ real: RealType, _ imaginary: SIMD3<RealType>) {
    self.init(from: SIMD4(real, imaginary.x, imaginary.y, imaginary.z))
  }

  /// The quaternion with specified real part and imaginary parts.
  @inlinable
  public init(_ real: RealType, _ imaginary: (b: RealType, c: RealType, d: RealType)) {
    self.init(real, SIMD3(imaginary.b, imaginary.c, imaginary.d))
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

  public typealias IntegerLiteralType = Int

  @inlinable
  public init(integerLiteral value: Int) {
    self.init(RealType(value))
  }
}

extension Quaternion where RealType: BinaryFloatingPoint {
  /// `other` rounded to the nearest representable value of this type.
  @inlinable
  public init<Other: BinaryFloatingPoint>(_ other: Quaternion<Other>) {
    self.init(from: SIMD4(
        RealType(other.components.x),
        RealType(other.components.y),
        RealType(other.components.z),
        RealType(other.components.w)
    ))
  }

  /// `other`, if it can be represented exactly in this type; otherwise `nil`.
  @inlinable
  public init?<Other: BinaryFloatingPoint>(exactly other: Quaternion<Other>) {
    guard
        let x = RealType(exactly: other.components.x),
        let y = RealType(exactly: other.components.y),
        let z = RealType(exactly: other.components.z),
        let w = RealType(exactly: other.components.w)
    else { return nil }
    self.init(from: SIMD4(x, y, z, w))
  }
}

// MARK: - Conformance to Hashable and Equatable
extension Quaternion: Hashable {

  @_transparent
  public static func == (lhs: Quaternion, rhs: Quaternion) -> Bool {
    // Identify all numbers with either component non-finite as a single "point at infinity".
    guard lhs.isFinite || rhs.isFinite else { return true }
    // For finite numbers, equality is defined componentwise. Cases where
    // only one of a or b is infinite fall through to here as well, but this
    // expression correctly returns false for them so we don't need to handle
    // them explicitly.
    return lhs.components == rhs.components
  }

  @_transparent
  public func hash(into hasher: inout Hasher) {
    // There are two equivalence classes to which we owe special attention:
    // All zeros should hash to the same value, regardless of sign, and all
    // non-finite numbers should hash to the same value, regardless of
    // representation. The correct behavior for zero falls out for free from
    // the hash behavior of floating-point, but we need to use a
    // representative member for any non-finite values.
    if isFinite {
      hasher.combine(components.x)
      hasher.combine(components.y)
      hasher.combine(components.z)
      hasher.combine(components.w)
    } else {
      hasher.combine(RealType.infinity)
    }
  }
}

// MARK: - Conformance to Codable
// FloatingPoint does not refine Codable, so this is a conditional conformance.
extension Quaternion: Decodable where RealType: Decodable {
  public init(from decoder: Decoder) throws {
    var unkeyedContainer = try decoder.unkeyedContainer()
    self.init(from: try unkeyedContainer.decode(SIMD4<RealType>.self))
  }
}

extension Quaternion: Encodable where RealType: Encodable {
  public func encode(to encoder: Encoder) throws {
    try components.encode(to: encoder)
  }
}

// MARK: - Formatting
extension Quaternion: CustomStringConvertible {
  public var description: String {
    guard isFinite else { return "inf" }
    return "(\(components.x), \(components.y), \(components.z), \(components.w))"
  }
}

extension Quaternion: CustomDebugStringConvertible {
  public var debugDescription: String {
    "Quaternion<\(RealType.self)>\(description)"
  }
}

// MARK: - Operations for working with polar form
extension Quaternion {

  /// The Euclidean norm (a.k.a. 2-norm, `sqrt(lengthSquared)`).
  ///
  /// Note that it *is* possible for this property to overflow,
  /// because `lengthSquared` is highly prone to overflow or underflow.
  ///
  /// For most use cases, you can use the cheaper `.magnitude`
  /// property (which computes the ∞-norm) instead, which always produces
  /// a representable result.
  ///
  /// Edge cases:
  /// -
  /// If a complex value is not finite, its `.length` is `infinity`.
  ///
  /// See also:
  /// -
  /// - `.magnitude`
  /// - `.lengthSquared`
  /// - `.phase`
  /// - `.polar`
  /// - `init(r:θ:)`
  @_transparent
  public var length: RealType {
    return .sqrt(lengthSquared)
  }

  /// The squared length `(real*real + (imaginary*imaginary).sum())`.
  ///
  /// This property is more efficient to compute than `length`.
  ///
  /// This value is highly prone to overflow or underflow.
  /// For many cases, `.magnitude` can be used instead, which is similarly
  /// cheap to compute and always returns a representable value.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.magnitude`
  @_transparent
  public var lengthSquared: RealType {
    (components * components).sum()
  }

  // MARK: - TODO: .altitude, .azimuth, .polar & .init(length:altitude:azimuth:) -

  /// The altitude (angle).
  ///
  /// Edge cases:
  /// -
  /// If the quaternion is zero or non-finite, phase is `nan`.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.polar`
  /// - `init(length:altitude:azimuth:)`
//  @inlinable
//  public var altitude: RealType

  /// The azimuth (angle).
  ///
  /// Edge cases:
  /// -
  /// If the quaternion is zero or non-finite, phase is `nan`.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.polar`
  /// - `init(length:altitude:azimuth:)`
//  @inlinable
//  public var azimuth: RealType

  /// The length, altitude and azimuth (or polar coordinates) of this value.
  ///
  /// Edge cases:
  /// -
  /// If the quaternion is zero or non-finite, phase is `.nan`.
  /// If the quaternion is non-finite, length is `.infinity`.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.altitude`
  /// - `.azimuth`
  /// - `init(length:altitude:azimuth:)`
//  public var polar: (length: RealType, altitude: RealType, azimuth: RealType) {
//    (length, altitude, azimuth)
//  }

  /// Creates a complex value specified with polar coordinates.
  ///
  /// Edge cases:
  /// -
  /// - Negative lengths are interpreted as reflecting the point through the origin, i.e.:
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
  /// See also:
  /// -
  /// - `.length`
  /// - `.altitude`
  /// - `.azimuth`
  /// - `.polar`
//  @inlinable
//  public init(length: RealType, altitude: RealType, azimuth: RealType)
}
