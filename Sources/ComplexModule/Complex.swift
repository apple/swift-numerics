//===--- Complex.swift ----------------------------------------*- swift -*-===//
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

/// A complex number represented by real and imaginary parts.
///
/// TODO: introductory text on complex numbers
///
/// Implementation notes:
/// -
/// This type does not provide heterogeneous real/complex arithmetic,
/// not even the natural vector-space operations like real * complex.
/// There are two reasons for this choice: first, Swift broadly avoids
/// mixed-type arithmetic when the operation can be adequately expressed
/// by a conversion and homogeneous arithmetic. Second, with the current
/// typechecker rules, it would lead to undesirable ambiguity in common
/// expressions (see README.md for more details).
///
/// Unlike C's `_Complex` and C++'s `std::complex<>` types, we do not
/// attempt to make meaningful semantic distinctions between different
/// representations of infinity or NaN. Any Complex value with at least
/// one non-finite component is simply "non-finite". In as much as
/// possible, we use the semantics of the point at infinity on the
/// Riemann sphere for such values. This approach simplifies the number of
/// edge cases that need to be considered for multiplication, division, and
/// the elementary functions considerably.
///
/// `.magnitude` does not return the Euclidean norm; it uses the "infinity
/// norm" (`max(|real|,|imaginary|)`) instead. There are two reasons for this
/// choice: first, it's simply faster to compute on most hardware. Second,
/// there exist values for which the Euclidean norm cannot be represented
/// (consider a number with `.real` and `.imaginary` both equal to
/// `RealType.greatestFiniteMagnitude`; the Euclidean norm would be
/// `.sqrt(2) * .greatestFiniteMagnitude`, which overflows). Using
/// the infinity norm avoids this problem entirely without significant
/// downsides. You can access the Euclidean norm using the `length`
/// property.
@frozen
public struct Complex<RealType> where RealType: Real {
  //  A note on the `x` and `y` properties
  //
  //  `x` and `y` are the names we use for the raw storage of the real and
  //  imaginary components of our complex number. We also provide public
  //  `.real` and `.imaginary` properties, which wrap this storage and
  //  fixup the semantics for non-finite values.
  
  /// The real component of the value.
  @usableFromInline @inline(__always)
  internal var x: RealType
  
  /// The imaginary part of the value.
  @usableFromInline @inline(__always)
  internal var y: RealType
  
  /// A complex number constructed by specifying the real and imaginary parts.
  @_transparent
  public init(_ real: RealType, _ imaginary: RealType) {
    x = real
    y = imaginary
  }
}

// MARK: - Basic properties
extension Complex {
  /// The real part of this complex value.
  ///
  /// If `z` is not finite, `z.real` is `.nan`.
  public var real: RealType {
    @_transparent
    get { isFinite ? x : .nan }

    @_transparent
    set { x = newValue }
  }
  
  /// The imaginary part of this complex value.
  ///
  /// If `z` is not finite, `z.imaginary` is `.nan`.
  public var imaginary: RealType {
    @_transparent
    get { isFinite ? y : .nan }

    @_transparent
    set { y = newValue }
  }
  
  /// The additive identity, with real and imaginary parts both zero.
  ///
  /// See also:
  /// -
  /// - .one
  /// - .i
  /// - .infinity
  @_transparent
  public static var zero: Complex {
    Complex(0, 0)
  }
  
  /// The multiplicative identity, with real part one and imaginary part zero.
  ///
  /// See also:
  /// -
  /// - .zero
  /// - .i
  /// - .infinity
  @_transparent
  public static var one: Complex {
    Complex(1, 0)
  }
  
  /// The imaginary unit.
  ///
  /// See also:
  /// -
  /// - .zero
  /// - .one
  /// - .infinity
  @_transparent
  public static var i: Complex {
    Complex(0, 1)
  }
  
  /// The point at infinity.
  ///
  /// See also:
  /// -
  /// - .zero
  /// - .one
  /// - .i
  @_transparent
  public static var infinity: Complex {
    Complex(.infinity, 0)
  }
  
  /// The complex conjugate of this value.
  @_transparent
  public var conjugate: Complex {
    Complex(x, -y)
  }
  
  /// True if this value is finite.
  ///
  /// A complex value is finite if neither component is an infinity or nan.
  ///
  /// See also:
  /// -
  /// - `.isNormal`
  /// - `.isSubnormal`
  /// - `.isZero`
  @_transparent
  public var isFinite: Bool {
    x.isFinite && y.isFinite
  }
  
  /// True if this value is normal.
  ///
  /// A complex number is normal if it is finite and *either* the real or
  /// imaginary component is normal. A floating-point number representing
  /// one of the components is normal if its exponent allows a full-precision
  /// representation.
  ///
  /// See also:
  /// -
  /// - `.isFinite`
  /// - `.isSubnormal`
  /// - `.isZero`
  @_transparent
  public var isNormal: Bool {
    isFinite && (x.isNormal || y.isNormal)
  }
  
  /// True if this value is subnormal.
  ///
  /// A complex number is subnormal if it is finite, not normal, and not zero.
  /// When the result of a computation is subnormal, underflow has occurred and
  /// the result generally does not have full precision.
  ///
  /// See also:
  /// -
  /// - `.isFinite`
  /// - `.isNormal`
  /// - `.isZero`
  @_transparent
  public var isSubnormal: Bool {
    isFinite && !isNormal && !isZero
  }
  
  /// True if this value is zero.
  ///
  /// A complex number is zero if *both* the real and imaginary components
  /// are zero.
  ///
  /// See also:
  /// -
  /// - `.isFinite`
  /// - `.isNormal`
  /// - `.isSubnormal`
  @_transparent
  public var isZero: Bool {
    x == 0 && y == 0
  }
  
  /// The ∞-norm of the value (`max(abs(real), abs(imaginary))`).
  ///
  /// If you need the Euclidean norm (a.k.a. 2-norm) use the `length` or
  /// `lengthSquared` properties instead.
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
    return max(abs(x), abs(y))
  }
  
  /// A "canonical" representation of the value.
  ///
  /// For normal complex numbers with a RealType conforming to
  /// BinaryFloatingPoint (the common case), the result is simply this value
  /// unmodified. For zeros, the result has the representation (+0, +0). For
  /// infinite values, the result has the representation (+inf, +0).
  ///
  /// If the RealType admits non-canonical representations, the x and y
  /// components are canonicalized in the result.
  ///
  /// This is mainly useful for interoperation with other languages, where
  /// you may want to reduce each equivalence class to a single representative
  /// before passing across language boundaries, but it may also be useful
  /// for some serialization tasks. It's also a useful implementation detail
  /// for some primitive operations.
  @_transparent
  public var canonicalized: Self {
    if isZero { return .zero }
    if isFinite { return self.multiplied(by: 1) }
    return .infinity
  }
}

// MARK: - Additional Initializers
extension Complex {
  /// The complex number with specified real part and zero imaginary part.
  ///
  /// Equivalent to `Complex(real, 0)`.
  @inlinable
  public init(_ real: RealType) {
    self.init(real, 0)
  }
  
  /// The complex number with specified imaginary part and zero real part.
  ///
  /// Equivalent to `Complex(0, imaginary)`.
  @inlinable
  public init(imaginary: RealType) {
    self.init(0, imaginary)
  }
  
  /// The complex number with specified real part and zero imaginary part.
  ///
  /// Equivalent to `Complex(RealType(real), 0)`.
  @inlinable
  public init<Other: BinaryInteger>(_ real: Other) {
    self.init(RealType(real), 0)
  }
  
  /// The complex number with specified real part and zero imaginary part,
  /// if it can be constructed without rounding.
  @inlinable
  public init?<Other: BinaryInteger>(exactly real: Other) {
    guard let real = RealType(exactly: real) else { return nil }
    self.init(real, 0)
  }
  
  public typealias IntegerLiteralType = Int
  
  @inlinable
  public init(integerLiteral value: Int) {
    self.init(RealType(value))
  }
}

extension Complex where RealType: BinaryFloatingPoint {
  /// `other` rounded to the nearest representable value of this type.
  @inlinable
  public init<Other: BinaryFloatingPoint>(_ other: Complex<Other>) {
    self.init(RealType(other.x), RealType(other.y))
  }
  
  /// `other`, if it can be represented exactly in this type; otherwise `nil`.
  @inlinable
  public init?<Other: BinaryFloatingPoint>(exactly other: Complex<Other>) {
    guard let x = RealType(exactly: other.x),
          let y = RealType(exactly: other.y) else { return nil }
    self.init(x, y)
  }
}

// MARK: - Conformance to Hashable and Equatable
//
// The Complex type identifies all non-finite points (waving hands slightly,
// we identify all NaNs and infinites as the point at infinity on the Riemann
// sphere).
extension Complex: Hashable {
  @_transparent
  public static func ==(a: Complex, b: Complex) -> Bool {
    // Identify all numbers with either component non-finite as a single
    // "point at infinity".
    guard a.isFinite || b.isFinite else { return true }
    // For finite numbers, equality is defined componentwise. Cases where
    // only one of a or b is infinite fall through to here as well, but this
    // expression correctly returns false for them so we don't need to handle
    // them explicitly.
    return a.x == b.x && a.y == b.y
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
    } else {
      hasher.combine(RealType.infinity)
    }
  }
}

// MARK: - Conformance to Codable
// FloatingPoint does not refine Codable, so this is a conditional conformance.
extension Complex: Decodable where RealType: Decodable {
  public init(from decoder: Decoder) throws {
    var unkeyedContainer = try decoder.unkeyedContainer()
    let x = try unkeyedContainer.decode(RealType.self)
    let y = try unkeyedContainer.decode(RealType.self)
    self.init(x, y)
  }
}

extension Complex: Encodable where RealType: Encodable {
  public func encode(to encoder: Encoder) throws {
    var unkeyedContainer = encoder.unkeyedContainer()
    try unkeyedContainer.encode(x)
    try unkeyedContainer.encode(y)
  }
}

// MARK: - Formatting
extension Complex: CustomStringConvertible {
  public var description: String {
    guard isFinite else {
      return "inf"
    }
    return "(\(x), \(y))"
  }
}

extension Complex: CustomDebugStringConvertible {
  public var debugDescription: String {
    "Complex<\(RealType.self)>(\(String(reflecting: x)), \(String(reflecting: y)))"
  }
}

// MARK: - Operations for working with polar form
extension Complex {
  
  /// The Euclidean norm (a.k.a. 2-norm, `sqrt(real*real + imaginary*imaginary)`).
  ///
  /// This property takes care to avoid spurious over- or underflow in
  /// this computation. For example:
  ///
  ///     let x: Float = 3.0e+20
  ///     let x: Float = 4.0e+20
  ///     let naive = sqrt(x*x + y*y) // +Inf
  ///     let careful = Complex(x, y).length // 5.0e+20
  ///
  /// Note that it *is* still possible for this property to overflow,
  /// because the length can be as much as sqrt(2) times larger than
  /// either component, and thus may not be representable in the real type.
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
    let naive = lengthSquared
    guard naive.isNormal else { return carefulLength }
    return .sqrt(naive)
  }
  
  //  Internal implementation detail of `length`, moving slow path off
  //  of the inline function. Note that even `carefulLength` can overflow
  //  for finite inputs, but only when the result is outside the range
  //  of representable values.
  @usableFromInline
  internal var carefulLength: RealType {
    guard isFinite else { return .infinity }
    return .hypot(x, y)
  }
  
  /// The squared length `(real*real + imaginary*imaginary)`.
  ///
  /// This property is more efficient to compute than `length`, but is
  /// highly prone to overflow or underflow; for finite values that are
  /// not well-scaled, `lengthSquared` is often either zero or
  /// infinity, even when `length` is a finite number. Use this property
  /// only when you are certain that this value is well-scaled.
  ///
  /// For many cases, `.magnitude` can be used instead, which is similarly
  /// cheap to compute and always returns a representable value.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.magnitude`
  @_transparent
  public var lengthSquared: RealType {
    x*x + y*y
  }
  
  @available(*, unavailable, renamed: "lengthSquared")
  public var unsafeLengthSquared: RealType { lengthSquared }
  
  /// The phase (angle, or "argument").
  ///
  /// Returns the angle (measured above the real axis) in radians. If
  /// the complex value is zero or infinity, the phase is not defined,
  /// and `nan` is returned.
  ///
  /// Edge cases:
  /// -
  /// If the complex value is zero or non-finite, phase is `nan`.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.polar`
  /// - `init(r:θ:)`
  @inlinable
  public var phase: RealType {
    guard isFinite && !isZero else { return .nan }
    return .atan2(y: y, x: x)
  }
  
  /// The length and phase (or polar coordinates) of this value.
  ///
  /// Edge cases:
  /// -
  /// If the complex value is zero or non-finite, phase is `.nan`.
  /// If the complex value is non-finite, length is `.infinity`.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.phase`
  /// - `init(r:θ:)`
  public var polar: (length: RealType, phase: RealType) {
    (length, phase)
  }
  
  /// Creates a complex value specified with polar coordinates.
  ///
  /// Edge cases:
  /// -
  /// - Negative lengths are interpreted as reflecting the point through the
  ///   origin, i.e.:
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
  /// - `.phase`
  /// - `.polar`
  @inlinable
  public init(length: RealType, phase: RealType) {
    if phase.isFinite {
      self = Complex(.cos(phase), .sin(phase)).multiplied(by: length)
    } else {
      precondition(
        length.isZero || length.isInfinite,
        "Either phase must be finite, or length must be zero or infinite."
      )
      self = Complex(length)
    }
  }
}
