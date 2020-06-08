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
/// norm" (`max(|real|,|xi|,|yj|,|zk|)`) instead. There are two reasons for this
/// choice: first, it's simply faster to compute on most hardware. Second,
/// there exist values for which the Euclidean norm cannot be represented.
/// Using the infinity norm avoids this problem entirely without significant
/// downsides. You can access the Euclidean norm using the `length` property.
/// See `Complex` type of the swift-numerics package for additional details.
public struct Quaternion<RealType> where RealType: Real {
  //  A note on the `x`, `y`, `z` and `w` properties
  //
  //  `x`, `y`, `z` and `w` are the names we use for the raw storage of the
  //  real (w) and imaginary (xi + yj + zk) components of the quaternion. We
  //  also provide public `.real` and `.imaginary` properties, which wrap this
  //  storage and fixup the semantics for non-finite values.

  /// The imaginary *i* component of the value.
  @usableFromInline @inline(__always)
  internal var x: RealType

  /// The imaginary *j* component of the value.
  @usableFromInline @inline(__always)
  internal var y: RealType

  /// The imaginary *k* component of the value.
  @usableFromInline @inline(__always)
  internal var z: RealType

  /// The real component of the value.
  @usableFromInline @inline(__always)
  internal var w: RealType

  /// A quaternion constructed by specifying the real and imaginary parts.
  @_transparent
  public init(real: RealType, imaginary x: RealType, _ y: RealType, _ z: RealType) {
    self.x = x
    self.y = y
    self.z = z
    w = real
  }
}

// MARK: - Basic Property
extension Quaternion {
  /// The real part of this quaternion.
  ///
  /// If `q` is not finite, `q.real` is `.nan`.
  public var real: RealType {
    @_transparent
    get { isFinite ? w : .nan }

    @_transparent
    set { w = newValue }
  }

  /// The imaginary part of this quaternion.
  ///
  /// If `q` is not finite, `q.imaginary` is `.nan` in all lanes.
  public var imaginary: (x: RealType, y: RealType, z: RealType) {
    @_transparent
    get { isFinite ? (x,y,z) : (.nan,.nan,.nan) }

    @_transparent
    set { (x,y,z) = newValue }
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
    Quaternion(real: 0, imaginary: 0,0,0)
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
    Quaternion(real: 1, imaginary: 0,0,0)
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
    Quaternion(real: 0, imaginary: 1,0,0)
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
    Quaternion(real: 0, imaginary: 0,1,0)
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
    Quaternion(real: 0, imaginary: 0,0,1)
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
    Quaternion(real: .infinity, imaginary: 0,0,0)
  }

  /// The conjugate of this quaternion.
  @_transparent
  public var conjugate: Quaternion {
    Quaternion(real: w, imaginary: -x,-y,-z)
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
    x.isFinite && y.isFinite && z.isFinite && w.isFinite
  }

  /// True if this value is normal.
  ///
  /// A quaternion is normal if it is finite and *any* of its real or imaginary
  /// components are normal. A floating-point number representing one of the
  /// components is normal if its exponent allows a full-precision representation.
  ///
  /// See also:
  /// -
  /// - `.isFinite`
  /// - `.isSubnormal`
  /// - `.isZero`
  /// - `.isPure`
  @_transparent
  public var isNormal: Bool {
    isFinite && (x.isNormal || y.isNormal || z.isNormal || w.isNormal)
  }

  /// True if this value is subnormal.
  ///
  /// A quaternion is subnormal if it is finite, not normal, and not zero. When
  /// the result of a computation is subnormal, underflow has occurred and the
  /// result generally does not have full precision.
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
    x.isZero && y.isZero && z.isZero && w.isZero
  }

  /// True if this value is only defined by the imaginary part (`real == .zero`)
  @_transparent
  public var isPure: Bool {
    w.isZero
  }
}

// MARK: - Additional Initializers
extension Quaternion {
  /// The quaternion with specified real part and zero imaginary part.
  ///
  /// Equivalent to `Quaternion(real: real, imaginary: 0,0,0)`.
  @inlinable
  public init(_ real: RealType) {
    self.init(real: real, imaginary: 0,0,0)
  }

  /// The quaternion with specified imaginary part and zero real part.
  ///
  /// Equivalent to `Quaternion(real: 0, imaginary: imaginary)`.
  @inlinable
  public init(imaginary x: RealType, _ y: RealType, _ z: RealType) {
    self.init(real: 0, imaginary: x, y, z)
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
    let x = RealType(other.x)
    let y = RealType(other.y)
    let z = RealType(other.z)
    let w = RealType(other.w)
    self.init(real: w, imaginary: x, y, z)
  }

  /// `other`, if it can be represented exactly in this type; otherwise `nil`.
  @inlinable
  public init?<Other: BinaryFloatingPoint>(exactly other: Quaternion<Other>) {
    guard
        let x = RealType(exactly: other.x),
        let y = RealType(exactly: other.y),
        let z = RealType(exactly: other.z),
        let w = RealType(exactly: other.w)
    else { return nil }
    self.init(real: w, imaginary: x, y, z)
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
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z && lhs.w == rhs.w
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
      hasher.combine(x)
      hasher.combine(y)
      hasher.combine(z)
      hasher.combine(w)
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
    let x = try unkeyedContainer.decode(RealType.self)
    let y = try unkeyedContainer.decode(RealType.self)
    let z = try unkeyedContainer.decode(RealType.self)
    let w = try unkeyedContainer.decode(RealType.self)
    self.init(real: w, imaginary: x, y, z)
  }
}

extension Quaternion: Encodable where RealType: Encodable {
  public func encode(to encoder: Encoder) throws {
    var unkeyedContainer = encoder.unkeyedContainer()
    try unkeyedContainer.encode(x)
    try unkeyedContainer.encode(y)
    try unkeyedContainer.encode(z)
    try unkeyedContainer.encode(w)
  }
}

// MARK: - Formatting
extension Quaternion: CustomStringConvertible {
  public var description: String {
    guard isFinite else {
        return "inf"
    }
    return "(\(w), \(x), \(y), \(z))"
  }
}

extension Quaternion: CustomDebugStringConvertible {
  public var debugDescription: String {
    let x = String(reflecting: self.x)
    let y = String(reflecting: self.y)
    let z = String(reflecting: self.z)
    let w = String(reflecting: self.w)
    return "Quaternion<\(RealType.self)>(real: \(w), imaginary: \(x), \(y), \(z))"
  }
}
