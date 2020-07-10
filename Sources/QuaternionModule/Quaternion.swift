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

/// A quaternion represented by a real (or scalar) part and three imaginary (or vector) parts.
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
/// norm" (`max(|r|,|x|,|y|,|z|)`) instead. There are two reasons for this
/// choice: first, it's simply faster to compute on most hardware. Second,
/// there exist values for which the Euclidean norm cannot be represented.
/// Using the infinity norm avoids this problem entirely without significant
/// downsides. You can access the Euclidean norm using the `length` property.
/// See `Complex` type of the swift-numerics package for additional details.
///
/// Quaternions are frequently used to represent 3D transformations. It's
/// important to be aware that, when used this way, any quaternion and its
/// negation represent the same transformation, but they do not compare equal
/// using `==` because they are not the same quaternion.
/// You can compare quaternions as 3D transformations using `transformEquals()`.
public struct Quaternion<RealType> where RealType: Real & SIMDScalar {

  /// The components of the 4-dimensional vector space of the quaternion.
  ///
  /// Components are stored within a 4-dimensional SIMD vector with the
  /// scalar part last, i.e. in the form of:
  ///
  ///     xi + yj + zk + r // SIMD(x,y,z,r)
  @usableFromInline @inline(__always)
  internal var components: SIMD4<RealType>

  /// A quaternion constructed from given 4-dimensional SIMD vector.
  ///
  /// Creates a new quaternion by reading the values of the SIMD vector
  /// as components of a quaternion with the scalar part last, i.e. in the form of:
  ///
  ///     xi + yj + zk + r // SIMD(x,y,z,r)
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
    get { isFinite ? components[3] : .nan }

    @_transparent
    set { components[3] = newValue }
  }

  /// The imaginary part of this quaternion.
  ///
  /// If `q` is not finite, `q.imaginary` is `.nan` in all lanes.
  public var imaginary: SIMD3<RealType> {
    @_transparent
    get { isFinite ? components[SIMD3(0,1,2)] : SIMD3(repeating: .nan) }

    @_transparent
    set {
      components = SIMD4(newValue, components[3])
    }
  }

  /// The additive identity, with real and *all* imaginary parts zero.
  ///
  /// See also:
  /// -
  /// - .one
  /// - .i
  /// - .j
  /// - .k
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
  /// - .j
  /// - .k
  /// - .infinity
  @_transparent
  public static var one: Quaternion {
    Quaternion(from: SIMD4(0,0,0,1))
  }

  /// The quaternion with the imaginary unit **i** one, i.e. `0 + i + 0j + 0k`.
  ///
  /// See also:
  /// -
  /// - .zero
  /// - .one
  /// - .j
  /// - .k
  /// - .infinity
  @_transparent
  public static var i: Quaternion {
    Quaternion(imaginary: SIMD3(1,0,0))
  }

  /// The quaternion with the imaginary unit **j** one, i.e. `0 + 0i + j + 0k`.
  ///
  /// See also:
  /// -
  /// - .zero
  /// - .one
  /// - .i
  /// - .k
  /// - .infinity
  @_transparent
  public static var j: Quaternion {
    Quaternion(imaginary: SIMD3(0,1,0))
  }

  /// The quaternion with the imaginary unit **k** one, i.e. `0 + 0i + 0j + k`.
  ///
  /// See also:
  /// -
  /// - .zero
  /// - .one
  /// - .i
  /// - .j
  /// - .infinity
  @_transparent
  public static var k: Quaternion {
    Quaternion(imaginary: SIMD3(0,0,1))
  }

  /// The point at infinity.
  ///
  /// See also:
  /// -
  /// - .zero
  /// - .one
  /// - .i
  /// - .j
  /// - .k
  @_transparent
  public static var infinity: Quaternion {
    Quaternion(.infinity)
  }

  /// The conjugate of this quaternion.
  @_transparent
  public var conjugate: Quaternion {
    Quaternion(from: components * [-1, -1, -1, 1])
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
  /// A quaternion is normal if it is finite and *any* of its real or imaginary components
  /// are normal. A floating-point number representing one of the components is normal
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
    return isFinite && (
      components.x.isNormal ||
      components.y.isNormal ||
      components.z.isNormal ||
      components.w.isNormal
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
    components == .zero
  }

  /// True if this value is only defined by the imaginary part (`real == .zero`)
  @_transparent
  public var isPure: Bool {
    real.isZero
  }

  /// A "canonical" representation of the value.
  ///
  /// For normal quaternion instances with a RealType conforming to
  /// BinaryFloatingPoint (the common case), the result is simply this value
  /// unmodified. For zeros, the result has the representation (+0, +0, +0, +0).
  /// For infinite values, the result has the representation (+inf, +0, +0, +0).
  ///
  /// If the RealType admits non-canonical representations, the x, y, z and r
  /// components are canonicalized in the result.
  ///
  /// This is mainly useful for interoperation with other languages, where
  /// you may want to reduce each equivalence class to a single representative
  /// before passing across language boundaries, but it may also be useful
  /// for some serialization tasks. It's also a useful implementation detail for
  /// some primitive operations.
  ///
  /// See also:
  /// -
  /// - `.canonicalizedTransform`
  @_transparent
  public var canonicalized: Self {
    guard !isZero else { return .zero }
    guard isFinite else { return .infinity }
    return self.multiplied(by: 1)
  }

  /// A "canonical transformation" representation of the value.
  ///
  /// For normal quaternion instances with a RealType conforming to
  /// BinaryFloatingPoint (the common case) and a non-negative real component,
  /// the result is simply this value unmodified. For instances with a negative
  /// real component, the result is this quaternion negated -(r, x, y, z); so
  /// the real component is always positive.
  /// For zeros, the result has the representation (+0, +0, +0, +0). For
  /// infinite values, the result has the representation (+inf, +0, +0, +0).
  ///
  /// If the RealType admits non-canonical representations, the x, y, z and r
  /// components are canonicalized in the result.
  ///
  /// See also:
  /// -
  /// - `.canonicalized`
  @_transparent
  public var canonicalizedTransform: Self {
    let canonical = canonicalized
    if canonical.real.sign == .plus { return canonical }
    return -canonical
  }
}

// MARK: - Additional Initializers
extension Quaternion {
  /// The quaternion with specified real part and zero imaginary part.
  ///
  /// Equivalent to `Quaternion(real: real, imaginary: SIMD3(repeating: 0))`.
  @inlinable
  public init(_ real: RealType) {
    self.init(real: real, imaginary: SIMD3(repeating: 0))
  }

  /// The quaternion with specified imaginary part and zero real part.
  ///
  /// Equivalent to `Quaternion(real: 0, imaginary: imaginary)`.
  @inlinable
  public init(imaginary: SIMD3<RealType>) {
    self.init(real: 0, imaginary: imaginary)
  }

  /// The quaternion with specified imaginary part and zero real part.
  ///
  /// Equivalent to `Quaternion(real: 0, imaginary: imaginary)`.
  @inlinable
  public init(imaginary x: RealType, _ y: RealType, _ z: RealType) {
    self.init(imaginary: SIMD3(x, y, z))
  }

  /// The quaternion with specified real part and imaginary parts.
  @inlinable
  public init(real: RealType, imaginary: SIMD3<RealType>) {
    self.init(from: SIMD4(imaginary, real))
  }

  /// The quaternion with specified real part and imaginary parts.
  @inlinable
  public init(real: RealType, imaginary x: RealType, _ y: RealType, _ z: RealType) {
    self.init(real: real, imaginary: SIMD3(x, y, z))
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
        let r = RealType(exactly: other.components.w)
    else { return nil }
    self.init(from: SIMD4(x, y, z, r))
  }
}

// MARK: - Conformance to Hashable and Equatable
extension Quaternion: Hashable {
  /// Returns a Boolean value indicating whether two values are equal.
  ///
  /// - Important:
  ///   Quaternions are frequently used to represent 3D transformations. It's
  ///   important to be aware that, when used this way, any quaternion and its
  ///   negation represent the same transformation, but they do not compare
  ///   equal using `==` because they are not the same quaternion. You can
  ///   compare quaternions as 3D transformations using `transformEquals()`.
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

  /// Transformation equality comparison
  ///
  /// Returns a Boolean value indicating whether the 3D transformations of this
  /// quaternion equals the 3D transformation of `other`.
  ///
  /// - Parameter other: The value to compare.
  /// - Returns: True if the transformation of this quaternion equals `other`.
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
    return "(\(components.w), \(components.x), \(components.y), \(components.z))"
  }
}

extension Quaternion: CustomDebugStringConvertible {
  public var debugDescription: String {
    let x = String(reflecting: components.x)
    let y = String(reflecting: components.y)
    let z = String(reflecting: components.z)
    let r = String(reflecting: components.w)
    return "Quaternion<\(RealType.self)>(\(r), \(x), \(y), \(z))"
  }
}
