//===--- Complex.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2021 Apple Inc. and the Swift Numerics project authors
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
///
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
  
  /// The raw representation of the real part of this value.
  @_transparent
  public var _rawX: RealType { x }
  
  /// The raw representation of the imaginary part of this value.
  @_transparent
  public var _rawY: RealType { y }
}
  
extension Complex {
  /// The imaginary unit.
  ///
  /// See also `.zero`, `.one` and `.infinity`.
  @_transparent
  public static var i: Complex {
    Complex(0, 1)
  }
  
  /// The point at infinity.
  ///
  /// See also `.zero`, `.one` and `.i`.
  @_transparent
  public static var infinity: Complex {
    Complex(.infinity, 0)
  }
  
  /// True if this value is finite.
  ///
  /// A complex value is finite if neither component is an infinity or nan.
  ///
  /// See also `.isNormal`, `.isSubnormal` and `.isZero`.
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
  /// See also `.isFinite`, `.isSubnormal` and `.isZero`.
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
  /// See also `.isFinite`, `.isNormal` and `.isZero`.
  @_transparent
  public var isSubnormal: Bool {
    isFinite && !isNormal && !isZero
  }
  
  /// True if this value is zero.
  ///
  /// A complex number is zero if *both* the real and imaginary components
  /// are zero.
  ///
  /// See also `.isFinite`, `.isNormal` and `isSubnormal`.
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
  
  /// The complex number with specified imaginary part and zero real part.
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
