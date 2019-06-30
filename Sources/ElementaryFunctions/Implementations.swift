//===--- Implementations.swift --------------------------------*- swift -*-===//
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

//  While `Real` does not provide any additional customization points,
//  it does allow us to default the implementation of a few operations,
//  and also provides `signGamma`.
extension Real {
  // Most math libraries do not provide exp10, so we need a default impl.
  @_transparent
  public static func exp10(_ x: Self) -> Self {
    return pow(10, x)
  }
  
  @_transparent
  public static func root(_ x: Self, _ n: Int) -> Self {
    guard x >= 0 || n % 2 != 0 else { return .nan }
    // TODO: this implementation is not quite correct, because n may be
    // rounded in conversion to Self. This only effects very extreme cases,
    // so we'll leave it alone for now.
    return Self(signOf: x, magnitudeOf: pow(x.magnitude, 1/Self(n)))
  }
  
  /// The sign of the gamma function, Γ(x).
  ///
  /// For `x >= 0`, `signGamma(x)` is `.plus`. For negative `x`, `signGamma(x)` is `.plus`
  /// when `x` is an integer, and otherwise it is `.minus` whenver `trunc(x)` is even, and `.plus`
  /// when `trunc(x)` is odd.
  ///
  /// This function is mainly used together with `logGamma`, which computes the logarithm of the
  /// absolute value of Γ(x), to recover the sign information.
  ///
  /// See also:
  /// -
  /// - `gamma()`
  /// - `logGamma()`
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
  
  @_transparent
  public static func sqrt(_ x: Self) -> Self {
    return x.squareRoot()
  }
}
