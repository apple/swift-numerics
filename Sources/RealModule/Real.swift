//===--- Real.swift -------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// A type that models the real numbers.
///
/// Types conforming to this protocol provide the arithmetic and utility operations defined by
/// the `FloatingPoint` protocol, and provide all of the math functions defined by the
/// `ElementaryFunctions` and `RealFunctions` protocols. This protocol does not
/// add any additional conformances itself, but is very useful as a protocol against which to
/// write generic code. For example, we can naturally write a generic version of the a sigmoid
/// function:
/// ```
/// func sigmoid<T: Real>(_ x: T) -> T {
///   return 1/(1 + .exp(-x))
/// }
/// ```
/// See Also:
/// -
/// - `ElementaryFunctions`
/// - `RealFunctions`
/// - `AlgebraicField`
public protocol Real: FloatingPoint, RealFunctions, AlgebraicField {
}

//  While `Real` does not provide any additional customization points,
//  it does allow us to default the implementation of a few operations,
//  and also provides `signGamma`.
extension Real {
  // Most math libraries do not provide exp10, so we need a default implementation.
  @_transparent
  public static func exp10(_ x: Self) -> Self {
    return pow(10, x)
  }
  
  /// cos(x) - 1, computed in such a way as to maintain accuracy for small x.
  ///
  /// See also:
  /// -
  /// - `ElementaryFunctions.expMinusOne()`
  @_transparent
  public static func cosMinusOne(_ x: Self) -> Self {
    let sinxOver2 = sin(x/2)
    return -2*sinxOver2*sinxOver2
  }
  
  #if !os(Windows)
  public static func signGamma(_ x: Self) -> FloatingPointSign {
    // Gamma is strictly positive for x >= 0.
    if x >= 0 { return .plus }
    // For negative x, we arbitrarily choose to assign a sign of .plus to the
    // poles.
    let trunc = x.rounded(.towardZero)
    if x == trunc { return .plus }
    // Otherwise, signGamma is .minus if the integral part of x is even.
    return trunc.isEven ? .minus : .plus
  }
  
  //  Determines if this value is even, assuming that it is an integer.
  @inline(__always)
  private var isEven: Bool {
    if Self.radix == 2 {
      // For binary types, we can just check if x/2 is an integer. This works
      // because x/2 is always computed exactly.
      let half = self/2
      return half == half.rounded(.towardZero)
    } else {
      // For decimal types, it's not quite that simple, because x/2 is not
      // necessarily computed exactly. As an example, suppose that we had a
      // decimal type with a one digit significand, and self = 7. Then self/2
      // would round to 4, and we would (wrongly) conclude that it was an
      // integer, and hence that self was even.
      //
      // Instead, for decimal types, we check if 2*trunc(self/2) == self,
      // using an FMA; this is always correct; this approach works for any
      // radix, but the previous method is more efficient for radix == 2.
      let half = self/2
      return self.addingProduct(-2, half.rounded(.towardZero)) == 0
    }
  }
  #endif
  
  @_transparent
  public static func _mulAdd(_ a: Self, _ b: Self, _ c: Self) -> Self {
    a*b + c
  }
  
  @_transparent
  public static func sqrt(_ x: Self) -> Self {
    return x.squareRoot()
  }
  
  @inlinable
  public var reciprocal: Self? {
    let recip = 1/self
    if recip.isNormal || isZero || !isFinite {
      return recip
    }
    return nil
  }
}
