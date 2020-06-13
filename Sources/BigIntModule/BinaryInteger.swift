//===--- BinaryInteger.swift ----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension BinaryInteger {
  @inlinable
  internal mutating func _invert() {
    self = ~self
  }
}

extension BinaryInteger {
  /// Returns the greatest common divisor (gcd) of two values.
  ///
  /// - Parameters:
  ///   - a: A value.
  ///   - b: Another value.
  /// - Returns: The greatest common divisor (gcd) of `a` and `b`; the result is
  ///   always non-negative.
  @inlinable
  public static func gcd(_ a: Self, _ b: Self) -> Self {
    // An iterative version of Stein's algorithm.
    if a == 0 { return Self(b.magnitude) } // gcd(0, b) == abs(b)
    if b == 0 { return Self(a.magnitude) } // gcd(a, 0) == abs(a)
    var a = a.magnitude, b = b.magnitude, shift = 0
    while ((a | b) & 1) == 0 {
      a >>= 1
      b >>= 1
      shift += 1
    }
    // Now, shift is equal to log2(k), where k is the greatest power of 2
    // dividing a and b.
    while (a & 1) == 0 { a >>= 1 } // Now, a is odd.
    repeat {
      while (b & 1) == 0 { b >>= 1 } // Now, b is odd.
      if a > b { swap(&a, &b) } // Now, a < b.
      b -= a
    } while b != 0
    // Restore common factors of 2.
    return Self(a << shift)
  }
  
  /// Returns the lowest common multiple (lcm) of two values.
  ///
  /// - Parameters:
  ///   - a: A value.
  ///   - b: Another value.
  /// - Returns: The lowest common multiple (lcm) of `a` and `b`; the result is
  ///   always non-negative.
  @inlinable
  public static func lcm(_ a: Self, _ b: Self) -> Self {
    if a == 0 || b == 0 { return 0 }
    let a = a.magnitude, b = b.magnitude
    return Self(a / .gcd(a, b) * b)
  }
  
  /// Returns the result of raising a value `base` to the power of another value
  /// `exponent`, rounded toward zero if `exponent` is negative.
  ///
  /// - Parameters:
  ///   - base: The base to be raised to the power of `exponent`.
  ///   - exponent: The exponent by which to raise `base`.
  /// - Returns: The result of raising `base` to the power of `exponent`,
  ///   rounded toward zero if `exponent` is negative.
  @inlinable
  public static func pow(_ base: Self, _ exponent: Self) -> Self {
    var x = base, n = exponent
    if Self.isSigned && n < 0 {
      x = 1 / x
      n = 0 - n
    } else if n == 0 {
      return 1
    }
    // Exponentiate by iterative squaring.
    var y = 1 as Self
    while n > 1 {
      if n & 1 == 1 {
        y *= x
      }
      x *= x
      n >>= 1
    }
    return x * y
  }
  
  /// Returns the square root of a value, rounded toward zero.
  ///
  /// If `x` is negative, a runtime error may occur.
  ///
  /// - Parameter x: The non-negative value of which to compute the square root.
  /// - Returns: The square root of `x`, rounded toward zero.
  @inlinable
  public static func sqrt(_ x: Self) -> Self {
    precondition(!Self.isSigned || x >= 0)
    var shift = x.bitWidth - 1
    shift -= shift % 2

    var x = x
    var result = 0 as Self
    while shift >= 0 {
      result *= 2
      let temporary = 2 * result + 1
      if temporary <= x >> shift {
        x -= temporary << shift
        result += 1
      }
      shift -= 2
    }
    return result
  }
}

extension BinaryInteger {
  /// Returns the [modular multiplicative inverse][wiki] of this value with
  /// respect to a positive modulus.
  ///
  /// If this value and the modulus are not relatively prime (co-prime), then
  /// this value is not invertible and the result is `nil`.
  ///
  /// Given the product `ax` obtained by multiplying the value `a` by its
  /// modular multiplicative inverse `x`, the modulus divides `ax - 1` evenly:
  ///
  ///     let a = 3
  ///     let x = a.inverse(mod: 7)
  ///     // x == 5
  ///
  ///     let ax = a * x
  ///     let remainder = (ax - 1) % 7
  ///     // remainder == 0
  ///
  /// - Parameter modulus: The modulus, which must be greater than zero.
  /// - Returns: The modular multiplicative inverse of this value with respect
  ///   to `modulus`, or `nil` if this value and `modulus` are not relatively
  ///   prime (co-prime).
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Modular_multiplicative_inverse
  // @inlinable
  public func inverse(modulo modulus: Self) -> Self? {
    precondition(modulus > 0, "Modulus must be greater than zero")
    // Compute the modular inverse by the extended Euclidean algorithm.
    var r1 = modulus.magnitude
    var r2 = magnitude
    var t1 = 0 as Magnitude
    var t2 = 1 as Magnitude
    var i = 0
    // Since `r1` is non-negative, `t2` is negative when `t1` is positive (and
    // vice versa). However, `Self` and/or `Magnitude` may be unsigned types, so
    // we can't use signed arithmetic.
    //
    // We can instead compute and store only magnitudes, keeping track of the
    // number of iterations to account for the alternating sequence of signs.
    // (Note that we _add_ the product `temporary.quotient * t2` to `t1`.)
    while r2 != 0 {
      let temporary = r1.quotientAndRemainder(dividingBy: r2)
      (r1, r2) = (r2, temporary.remainder)
      (t1, t2) = (t2, t1 + temporary.quotient * t2)
      i += 1
    }
    guard r1 == 1 else { return nil }
    guard t1 != 0 else { return Self(t1) }
    // If `i` is a multiple of two (`(i & 1) == 0`), then we should compute
    // `t1 = modulus.magnitude - t1` (since, if we were using signed arithmetic,
    // `t1` would be negative).
    //
    // If `self` is negative (`Self.isSigned && self < 0`), then we should also
    // compute `t1 = modulus.magnitude - t1`.
    //
    // These two operations cancel out if both conditions hold true, so we use
    // a logical XOR to test if we should subtract `Self(t1)` from `modulus`.
    return ((i & 1) == 0) != (Self.isSigned && self < 0)
      ? modulus - Self(t1)
      : Self(t1)
  }
  
  /// Returns the remainder after raising a value `base` to the power of another
  /// value `exponent`, then dividing by a positive modulus ([modular
  /// exponentiation][wiki]).
  ///
  /// If `exponent` is negative, then the result is equivalent to the remainder
  /// after raising the modular multiplicative inverse of `base` to the power of
  /// `-exponent`, then dividing by the modulus.
  ///
  /// If `exponent` is negative and `base` is not invertible modulo `modulus`,
  /// then the result is `nil`.
  ///
  /// - Parameters:
  ///   - base: The base to be raised to the power of `exponent`.
  ///   - exponent: The exponent by which to raise `base`.
  ///   - modulus: The modulus, which must be greater than zero.
  /// - Returns: The remainder after raising `base` to the power of `exponent`,
  ///   then dividing by `modulus`, or `nil` if `exponent` is negative and
  ///   `base` is not invertible modulo `modulus`.
  ///
  /// [wiki]: https://en.wikipedia.org/wiki/Modular_exponentiation
  // @inlinable
  public static func pow(
    _ base: Self, _ exponent: Self, modulo modulus: Self
  ) -> Self? {
    precondition(modulus > 0, "Modulus must be greater than zero")
    // Exponentiate by the right-to-left binary method.
    if modulus == 1 { return 0 }
    var x = base % modulus, n = exponent
    if Self.isSigned && n < 0 {
      guard let inverse = x.inverse(modulo: modulus) else { return nil }
      x = inverse
      n = 0 - n
    }
    var result = 1 as Self
    while n > 0 {
      if n & 1 == 1 {
        result *= x
        result %= modulus
      }
      x *= x
      x %= modulus
      n >>= 1
    }
    return result
  }
}
