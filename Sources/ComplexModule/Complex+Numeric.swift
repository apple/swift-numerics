//===--- Complex+Numeric.swift --------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Complex: Numeric {
  
  @_transparent
  public static func *(z: Complex, w: Complex) -> Complex {
    return Complex(z.x*w.x - z.y*w.y, z.x*w.y + z.y*w.x)
  }
  
  @_transparent
  public static func *=(z: inout Complex, w: Complex) {
    z = z * w
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
  
  /// The ∞-norm of the value (`max(abs(real), abs(imaginary))`).
  ///
  /// If you need the Euclidean norm (a.k.a. 2-norm) use the `length` or
  /// `lengthSquared` properties instead.
  ///
  /// Edge cases:
  /// - If `z` is not finite, `z.magnitude` is `.infinity`.
  /// - If `z` is zero, `z.magnitude` is `0`.
  /// - Otherwise, `z.magnitude` is finite and non-zero.
  ///
  /// See also `.length` and `.lengthSquared`.
  @_transparent
  public var magnitude: RealType {
    guard isFinite else { return .infinity }
    return max(abs(x), abs(y))
  }
}
