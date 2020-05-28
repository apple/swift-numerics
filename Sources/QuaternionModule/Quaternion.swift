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

/// A quaternion represented by a real (or scalar) and three imaginary (or vector) parts.
///
/// TODO: introductory text on quaternions
///
/// Implementation notes:
/// -
/// This type does not provide heterogeneous real/quaternion arithmetic,
/// not even the natural vector-space operations like real * quaternion.
/// There are two reasons for this choice: first, Swift broadly avoids
/// mixed-type arithmetic when the operation can be adequately expressed
/// by a conversion and homogeneous arithmetic. Second, with the current
/// typechecker rules, it would lead to undesirable ambiguity in common
/// expressions (see README.md for more details).
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
  /// Components are stored within a 4-dimensional SIMD vector with the scalar part
  /// first, i.e. representing the most common mathmatical representation that is:
  ///
  ///     a + bi + cj + dk
  @usableFromInline @inline(__always)
  internal var components: SIMD4<RealType>

  /// A quaternion constructed from given 4-dimensional vector.
  ///
  /// Creates a new quaternion by reading the values of the SIMD vector
  /// as components of a quaternion with teh scalar part first, i.e. in the form of:
  ///
  ///     a + bi + cj + dk
  @usableFromInline @inline(__always)
  internal init(from components: SIMD4<RealType>) {
    self.components = components
  }
}

// MARK: - Basic Property
extension Quaternion {
  /// The real part of this quaternion.
  ///
  /// If `q` is not finite, `q.real` is `.nan`.
  public var real: RealType {
    @_transparent
    get { isFinite ? components[0] : .nan }

    @_transparent
    set { components[0] = newValue }
  }

  /// The imaginary part of this quaternion.
  ///
  /// If `q` is not finite, `q.imaginary` is `.nan` in all lanes.
  public var imaginary: SIMD3<RealType> {
    @_transparent
    get { isFinite ? components[SIMD3(1,2,3)] : SIMD3(repeating: .nan) }

    @_transparent
    set {
        components[1] = newValue[0]
        components[2] = newValue[1]
        components[3] = newValue[2]
    }
  }

  /// The additive identity, with real and *all* imaginary parts zero.
  ///
  /// See also:
  /// -
  /// - .one
  /// - .i
  /// - .infinity
  @_transparent
  public static var zero: Quaternion {
    Quaternion(from: SIMD4(repeating: 0))
  }

  /// The multiplicative identity, with real part one and *all* imaginary parts zero.
  ///
  /// See also:
  /// -
  /// - .zero
  /// - .i
  /// - .infinity
  @_transparent
  public static var one: Quaternion {
    Quaternion(from: SIMD4(1,0,0,0))
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
    Quaternion(imaginary: SIMD3(repeating: 1))
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
    Quaternion(.infinity)
  }

  /// The conjugate of this quaternion.
  @_transparent
  public var conjugate: Quaternion {
    Quaternion(from: components.replacing(with: -components, where: [false, true, true, true]))
  }

  /// True if this value is finite.
  ///
  /// A quaternion is finite if neither component is an infinity or nan.
  ///
  /// See also:
  /// -
  /// - `.isNormal`
  /// - `.isSubnormal`
  /// - `.isZero`
  /// - `.isPure`
  @_transparent
  public var isFinite: Bool {
    return components.x.isFinite
        && components.y.isFinite
        && components.z.isFinite
        && components.w.isFinite
  }

  /// True if this value is normal.
  ///
  /// A quaternion is normal if it is finite and *either* the real or *all* of the imaginary
  /// components are normal. A floating-point number representing one of the components is normal
  /// if its exponent allows a full-precision representation.
  ///
  /// See also:
  /// -
  /// - `.isFinite`
  /// - `.isSubnormal`
  /// - `.isZero`
  /// - `.isPure`
  @_transparent
  public var isNormal: Bool {
    let realIsNormal = components.x.isNormal
    let imaginaryIsNormal = components.y.isNormal && components.z.isNormal && components.w.isNormal
    return isFinite && (realIsNormal || imaginaryIsNormal)
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
  /// A quaternion is zero if the real and *all* imaginary components are zero.
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
        let a = RealType(exactly: other.components.x),
        let b = RealType(exactly: other.components.y),
        let c = RealType(exactly: other.components.z),
        let d = RealType(exactly: other.components.w)
    else { return nil }
    self.init(from: SIMD4(a, b, c, d))
  }
}

// MARK: - Conformance to Hashable and Equatable
extension Quaternion: Hashable {
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

  @_transparent
  public func hash(into hasher: inout Hasher) {
    // There are two equivalence classes to which we owe special attention:
    // All zeros should hash to the same value, regardless of sign, and all
    // non-finite numbers should hash to the same value, regardless of
    // representation. The correct behavior for zero falls out for free from
    // the hash behavior of floating-point, but we need to use a
    // representative member for any non-finite values.
    if isFinite {
      components.hash(into: &hasher)
    } else {
      hasher.combine(RealType.infinity)
    }
  }
}

// MARK: - Conformance to Codable
// FloatingPoint does not refine Codable, so this is a conditional conformance.
extension Quaternion: Decodable where RealType: Decodable {
  public init(from decoder: Decoder) throws {
    try self.init(from: SIMD4(from: decoder))
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
    guard isFinite else {
        return "inf"
    }
    return "(\(components.x), \(components.y), \(components.z), \(components.w))"
  }
}

extension Quaternion: CustomDebugStringConvertible {
  public var debugDescription: String {
    let a = String(reflecting: components.x)
    let b = String(reflecting: components.y)
    let c = String(reflecting: components.z)
    let d = String(reflecting: components.w)
    return "Quaternion<\(RealType.self)>(\(a), \(b), \(c), \(d))"
  }
}
