//===--- Complex.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

@_exported import ElementaryFunctions

/// A complex number represented by real and imaginary parts.
///
/// TODO: introductory text on complex numbers
///
/// Implementation notes:
///
/// Unlike C _Complex and C++ std::complex<> types, which attempt to define
/// meaningful fine-grained semantics for complex values with one or both
/// components infinite or nan, we simply treat all such values as a single
/// equivalence class. This simplifies defining multiplication and division
/// considerably, with almost no loss in expressive power.
@_fixed_layout
public struct Complex<RealType> where RealType: Real {
  /// The real part of this complex value.
  @usableFromInline
  internal var x: RealType
  
  /// The imaginary part of this complex value.
  @usableFromInline
  internal var y: RealType
  
  /// A complex number constructed by specifying the real and imaginary parts.
  @inlinable
  public init(_ real: RealType, _ imag: RealType) {
    x = real
    y = imag
  }
  
  /// The real part of this complex value if it is a finite number, or `nan` if it is not.
  public var real: RealType {
    @inlinable
    get { isFinite ? x : .nan }
  }
  
  /// The imaginary part of this complex value if it is a finite number, or `nan` if it is not.
  public var imag: RealType {
    @inlinable
    get { isFinite ? y : .nan }
  }
}

// MARK: - Additional Initializers
extension Complex {
  /// The complex number with specified real part and zero imaginary part.
  @inlinable
  public init(_ real: RealType) {
    self.init(real, 0)
  }
  
  /// The complex number with specified imaginary part and zero real part.
  @inlinable
  public init(imag: RealType) {
    self.init(0, imag)
  }
  
  /// The complex number with specified real part and zero imaginary part.
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
    guard let real = RealType(exactly: other.x),
          let imag = RealType(exactly: other.y) else { return nil }
    self.init(real, imag)
  }
}

// MARK: - Conformance to Hashable and Equatable
//
// The Complex type identifies all non-finite points (waving hands slightly,
// we identify all NaNs and infinites as the point at infinity on the Riemann
// sphere).
extension Complex: Hashable {
  @inlinable
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
  
  @inlinable
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
// The synthesized conformance works correction for this protocol, unlike
// Hashable and Equatable; all we need to do is specify that we conform.
// FloatingPoint does not refine Codable, so this is a conditional conformance.
extension Complex: Codable where RealType: Codable {
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

extension Complex: CustomDebugStringConvertible where RealType: CustomDebugStringConvertible {
  public var debugDescription: String {
    "Complex<\(RealType.self)>(\(x.debugDescription), \(y.debugDescription))"
  }
}

// MARK: - Basic properties
extension Complex {
  @inlinable
  public static var zero: Complex {
    Complex(0, 0)
  }
  
  @inlinable
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
  @inlinable
  public static var i: Complex {
    Complex(0, 1)
  }
  
  /// A value representing the point at infinity.
  @inlinable
  public static var infinity: Complex {
    Complex(.infinity, 0)
  }
  
  /// The complex conjugate of this value.
  @inlinable
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
  @inlinable
  public var isFinite: Bool {
    x.isFinite && y.isFinite
  }
  
  /// True if this value is normal.
  ///
  /// A complex number is normal if it is finite and *either* the real or imaginary component is normal.
  /// A floating-point number representing one of the components is normal if its exponent allows a full-
  /// precision representation.
  ///
  /// See also:
  /// -
  /// - `.isFinite`
  /// - `.isSubnormal`
  /// - `.isZero`
  @inlinable
  public var isNormal: Bool {
    isFinite && (x.isNormal || y.isNormal)
  }
  
  /// True if this value is subnormal.
  ///
  /// A complex number is subnormal if it is finite, not normal, and not zero. When the result of a
  /// computation is subnormal, underflow has occured and the result generally does not have full
  /// precision.
  /// See also:
  /// -
  /// - `.isFinite`
  /// - `.isNormal`
  /// - `.isZero` 
  @inlinable
  public var isSubnormal: Bool {
    isFinite && !isNormal && !isZero
  }
  
  /// True if this value is zero.
  ///
  /// A complex number is zero if *both* the real and imaginary components are zero.
  ///
  /// See also:
  /// -
  /// - `.isFinite`
  /// - `.isNormal`
  /// - `.isSubnormal`
  @inlinable
  public var isZero: Bool {
    x == 0 && y == 0
  }
  
  /// The ∞-norm of the value (`max(abs(real), abs(imag))`).
  ///
  /// If you need the euclidean norm (a.k.a. 2-norm) use the `length` or `unsafeLengthSquared`
  /// properties instead.
  ///
  /// Edge cases:
  /// -
  /// If a complex value is not finite, `.magnitude` is `infinity`.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.unsafeLengthSquared`
  @inlinable
  public var magnitude: RealType {
    guard isFinite else { return .infinity }
    return max(abs(x), abs(y))
  }
}

// MARK: - Operations for working with polar form
extension Complex {
  
  /// The euclidean norm (a.k.a. 2-norm, `sqrt(real*real + imag*imag)`).
  ///
  /// This property takes care to avoid spurious over- or underflow in this computation. For example:
  ///
  ///     let x: Float = 3.0e+20
  ///     let x: Float = 4.0e+20
  ///     let naive = sqrt(x*x + y*y) // +Inf
  ///     let careful = Complex(x, y).length // 5.0e+20
  ///
  /// Note that it *is* still possible for this property to overflow, because the length can be as much
  /// as sqrt(2) times larger than either component, and thus may not be representable in the real type.
  ///
  /// For most use cases, you can use the cheaper `.magnitude` property (which computes the
  /// ∞-norm) instead, which always produces a representable result.
  ///
  /// Edge cases:
  /// -
  /// If a complex value is not finite, its `.length` is `infinity`.
  ///
  /// See also:
  /// -
  /// - `.magnitude`
  /// - `.unsafeLengthSquared`
  /// - `.phase`
  /// - `.polar`
  /// - `init(r:θ:)`
  @inlinable
  public var length: RealType {
    let naive = unsafeLengthSquared
    guard naive.isNormal else { return carefulLength }
    return .sqrt(naive)
  }
  
  @usableFromInline
  internal var carefulLength: RealType {
    guard isFinite else { return .infinity }
    return .hypot(x, y)
  }
  
  /// The squared length `(real*real + imag*imag)`.
  ///
  /// This property is more efficient to compute than `length`, but is prone to overflow or underflow;
  /// for finite values that are not well-scaled, `unsafeLengthSquared` is often either zero or
  /// infinity, even when `length` is a finite number. Use this property only when you are certain that
  /// this value is well-scaled.
  ///
  /// For many cases, `.magnitude` can be used instead, which is also cheap to compute and always
  /// returns a representable value.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.magnitude`
  @inlinable
  public var unsafeLengthSquared: RealType {
    x*x + y*y
  }
  
  /// The phase (angle, or "argument").
  ///
  /// Returns the angle (measured above the real axis) in radians. If the complex value is zero
  /// or infinity, the phase is not defined, and `nan` is returned.
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
  /// If the complex value is zero or non-finite, phase is `.nan`. If the complex value is non-finite,
  /// the length is `.infinity`.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.phase`
  /// - `init(r:θ:)`
  public var polar: (length: RealType, phase: RealType) {
    (length, phase)
  }
  
  /// Constructs a complex value from polar coordinates.
  ///
  /// Edge cases:
  /// -
  /// If the phase is non-finite, but length is finite, this initializer fails and returns nil. In all other cases,
  /// a non-nil value is constructed.
  ///
  /// See also:
  /// -
  /// - `.length`
  /// - `.phase`
  /// - `.polar`
  public init?(length: RealType, phase: RealType) {
    guard phase.isFinite else {
      // There's no way to make sense of finite magnitude and non-finite phase.
      if length.isFinite { return nil }
      // r is infinite so phase doesn't matter.
      self = .infinity
      return
    }
    self.init(length * .cos(phase), length * .sin(phase))
  }
}
