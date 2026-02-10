//===--- Complex.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2025 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule

// A [complex number](https://en.wikipedia.org/wiki/Complex_number).
// See Documentation.docc/Complex.md for more details.
@frozen
public struct Complex<RealType> where RealType: Real {
  //  A note on the `x` and `y` properties
  //
  //  `x` and `y` are the names we use for the raw storage of the real and
  //  imaginary components of our complex number. We also provide public
  //  `.real` and `.imaginary` properties, which wrap this storage and
  //  fixup the semantics for non-finite values.
  
  /// The storage for the real component of the value.
  @usableFromInline @inline(__always)
  internal var x: RealType
  
  /// The storage for the imaginary part of the value.
  @usableFromInline @inline(__always)
  internal var y: RealType
  
  /// A complex number constructed by specifying the real and imaginary parts.
  @_transparent
  public init(_ real: RealType, _ imaginary: RealType) {
    x = real
    y = imaginary
  }
}

extension Complex: Sendable where RealType: Sendable { }

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
  
  /// The raw representation of the value.
  ///
  /// Use this when you need the underlying RealType values,
  /// without fixup for NaN or infinity.
  public var rawStorage: (x: RealType, y: RealType) {
    @_transparent
    get { (x, y) }
    @_transparent
    set { (x, y) = newValue }
  }
  
  /// The raw representation of the real part of this value.
  @available(*, deprecated, message: "Use rawStorage")
  @_transparent
  public var _rawX: RealType { x }
  
  /// The raw representation of the imaginary part of this value.
  @available(*, deprecated, message: "Use rawStorage")
  @_transparent
  public var _rawY: RealType { y }
}
  
extension Complex {
  /// The imaginary unit.
  ///
  /// See also ``zero``, ``one`` and ``infinity``.
  @_transparent
  public static var i: Complex {
    Complex(0, 1)
  }
  
  /// The point at infinity.
  ///
  /// See also ``zero``, ``one`` and ``i``.
  @_transparent
  public static var infinity: Complex {
    Complex(.infinity, 0)
  }
  
  /// True if this value is finite.
  ///
  /// A complex value is finite if neither component is an infinity or nan.
  ///
  /// See also ``isNormal``, ``isSubnormal`` and ``isZero``.
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
  /// See also ``isFinite``, ``isSubnormal`` and ``isZero``.
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
  /// See also ``isFinite``, ``isNormal`` and ``isZero``.
  @_transparent
  public var isSubnormal: Bool {
    isFinite && !isNormal && !isZero
  }
  
  /// True if this value is zero.
  ///
  /// A complex number is zero if *both* the real and imaginary components
  /// are zero.
  ///
  /// See also ``isFinite``, ``isNormal`` and ``isSubnormal``.
  @_transparent
  public var isZero: Bool {
    x == 0 && y == 0
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
  
  /// The complex number with zero real part and specified imaginary part.
  ///
  /// Equivalent to `Complex(0, imaginary)`.
  @inlinable
  public init(imaginary: RealType) {
    self.init(0, imaginary)
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
