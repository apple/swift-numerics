//===--- Compound.swift ---------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

//  This file implements the operation that IEEE 754-2019 calls `compound`:
//
//      compound(x, n) = (1+x)ⁿ
//
//  and the closely-related
//
//      compoundMinusOne(x, n) = (1+x)ⁿ - 1
//
//  Following the precedent set by `log(onePlus:)` and `expMinusOne(_:)`, these
//  are spelled `pow(onePlus:_:)` and `powMinusOne(onePlus:_:)` in Swift.
//
//  Implementation notes
//  --------------------
//
//  The obvious implementation is:
//
//      exp(Self(n) * log(onePlus: x))
//
//  but this is unnecessarily inaccurate. `log(onePlus:)` carries a relative
//  error of about ulpOfOne; multiplying by n turns that into an *absolute*
//  error of about n * |log1p(x)| * ulpOfOne in the argument to `exp`, and
//  `exp` converts an absolute error e in its argument into a relative error
//  of about e in its result. The net effect is that the naive expression
//  loses roughly log2(n) bits of precision, which makes it unsuitable for
//  the most common use of this operation--compound interest over many
//  periods, where n is large and an accurate result actually matters.
//
//  Instead we evaluate (1+x)ⁿ by binary exponentiation, carrying the
//  intermediate results in double-Self arithmetic (an unevaluated sum of two
//  values of type Self, giving us about twice the working precision of Self).
//  Because 1+x is represented exactly as a double-Self value to begin with,
//  and each double-Self multiply is accurate to about ulpOfOne², the total
//  relative error after the log2(n) steps of binary exponentiation is
//  bounded by roughly log2(n) * ulpOfOne², which is far below ulpOfOne for
//  every representable n. The results are therefore very nearly always
//  correctly rounded.
//
//  This also makes `powMinusOne(onePlus:_:)` accurate essentially for free:
//  the leading term of the double-Self result cancels against 1, and the
//  trailing term supplies the digits that cancellation would otherwise have
//  destroyed.

//  A double-Self value `head + tail`, with |tail| <= ulp(head)/2.
//
//  These helpers are deliberately minimal; they implement only the two
//  operations that binary exponentiation requires (multiplication and
//  reciprocal), and only for the well-scaled positive values that arise in
//  this file. They are not a general-purpose extended-precision type.

/// The product `a * b`, rounded to double-Self precision.
@inline(__always)
private func _twoMul<T: Real>(
  _ a: (head: T, tail: T), _ b: (head: T, tail: T)
) -> (head: T, tail: T) {
  let p = Augmented.product(a.head, b.head)
  //  If the leading product is not finite, or flushed to zero, the error
  //  term is meaningless; propagate the leading term alone. Per the analysis
  //  in `_compound` below, this only happens when the exact result overflows
  //  or underflows, so no information is lost by doing so.
  guard p.head.isNormal else { return (p.head, 0) }
  //  Neglecting a.tail*b.tail costs us only about ulpOfOne³.
  let cross = a.head*b.tail + a.tail*b.head
  let s = Augmented.sum(large: p.head, small: p.tail + cross)
  return (s.head, s.tail)
}

/// The reciprocal `1/a`, rounded to double-Self precision.
///
/// `a.head` must be finite, normal and non-zero.
@inline(__always)
private func _twoRecip<T: Real>(
  _ a: (head: T, tail: T)
) -> (head: T, tail: T) {
  let r = 1/a.head
  let p = Augmented.product(a.head, r)
  //  p.head is within a couple ulp of 1, so `1 - p.head` is exact by
  //  Sterbenz' lemma, and e is a good approximation to 1 - a*r.
  let e = ((1 - p.head) - p.tail) - a.tail*r
  //  One Newton step: 1/a ≈ r + r*(1 - a*r).
  let s = Augmented.sum(large: r, small: r*e)
  return (s.head, s.tail)
}

extension Real {
  /// (1+x) raised to the nth power.
  ///
  /// This operation computes simple compound interest: a principal of 1
  /// earning a rate of `x` per period, held for `n` periods, grows to
  /// `pow(onePlus: x, n)`.
  ///
  /// This is more accurate than `pow(1+x, n)` when `x` is small, because
  /// `1+x` rounds away the low-order digits of `x` before the power is
  /// taken, while this function does not. For example, at `Double`
  /// precision, a rate so small that `1+x` rounds to exactly 1:
  /// ```
  /// let x = 0x1.0p-60         // a very small rate
  /// Double.pow(1+x, 3650)     // 1.0, all information about x is lost
  /// Double.pow(onePlus: x, 3650)
  /// // 1.000000000000003, accurate
  /// ```
  ///
  /// IEEE 754 calls this operation `compound`. See also
  /// ``powMinusOne(onePlus:_:)``, which is more accurate still when the
  /// result is close to 1, as well as
  /// ``ElementaryFunctions/pow(_:_:)-9imp6`` and
  /// ``ElementaryFunctions/log(onePlus:)``.
  ///
  /// Edge cases:
  ///
  /// - `pow(onePlus: x, 0)` is 1 for every `x >= -1`, including infinity.
  /// - `pow(onePlus: -1, n)` is `+0` for `n > 0` and `+infinity` for `n < 0`,
  ///   matching repeated multiplication or division by zero.
  /// - `pow(onePlus: .infinity, n)` is `+infinity` for `n > 0` and `+0` for
  ///   `n < 0`.
  /// - The result is `NaN` if `x < -1` or `x` is `NaN`, for every `n`
  ///   including zero. (1+x)ⁿ is not real-valued for `x < -1` and
  ///   non-integral exponents, and IEEE 754 specifies a domain error for
  ///   this case.
  public static func pow(onePlus x: Self, _ n: Int) -> Self {
    //  Exponent zero is 1 everywhere the operation is defined.
    guard n != 0 else { return x >= -1 ? 1 : .nan }
    //  Also rejects NaN, since all comparisons against NaN are false.
    guard x >= -1 else { return .nan }
    guard x > -1 else { return n > 0 ? 0 : .infinity }
    guard x < .infinity else { return n > 0 ? .infinity : 0 }
    let r = _compound(onePlus: x, n)
    return r.head + r.tail
  }

  /// (1+x) raised to the nth power, minus 1.
  ///
  /// This operation computes the *interest earned* by a principal of 1
  /// at a rate of `x` per period held for `n` periods, as opposed to
  /// ``pow(onePlus:_:)``, which computes the resulting balance.
  ///
  /// When the result is close to zero--that is, when `x*n` is small--the
  /// expression `pow(onePlus: x, n) - 1` suffers catastrophic cancellation
  /// and loses accuracy. This function does not:
  /// ```
  /// let x = 0x1.0p-60
  /// Double.pow(onePlus: x, 8) - 1  // 0.0, every digit is lost
  /// Double.powMinusOne(onePlus: x, 8)
  /// // 6.938893903907228e-18, accurate
  /// ```
  ///
  /// See also ``pow(onePlus:_:)`` and
  /// ``ElementaryFunctions/expMinusOne(_:)``.
  ///
  /// Edge cases:
  ///
  /// - `powMinusOne(onePlus: x, 0)` is 0 for every `x >= -1`.
  /// - `powMinusOne(onePlus: -1, n)` is `-1` for `n > 0` and `+infinity`
  ///   for `n < 0`.
  /// - `powMinusOne(onePlus: .infinity, n)` is `+infinity` for `n > 0` and
  ///   `-1` for `n < 0`.
  /// - The result is `NaN` if `x < -1` or `x` is `NaN`, for every `n`
  ///   including zero.
  public static func powMinusOne(onePlus x: Self, _ n: Int) -> Self {
    guard n != 0 else { return x >= -1 ? 0 : .nan }
    guard x >= -1 else { return .nan }
    guard x > -1 else { return n > 0 ? -1 : .infinity }
    guard x < .infinity else { return n > 0 ? .infinity : -1 }
    let r = _compound(onePlus: x, n)
    //  If the power overflowed, the result is infinity; subtracting one
    //  cannot bring it back into range, and the error term is meaningless
    //  (computing `head + tail` would produce infinity - infinity = NaN).
    guard r.head.isFinite else { return r.head }
    //  r.head is within an ulp of the true (1+x)ⁿ, so if it lies in [1/2, 2]
    //  then `r.head - 1` is exact by Sterbenz' lemma and no accuracy is lost
    //  here. Outside that range the subtraction may round, but then the
    //  result is not close to zero and the rounding is harmless.
    let s = Augmented.sum(large: r.head, small: -1)
    return s.head + (s.tail + r.tail)
  }

  /// (1+x)ⁿ evaluated in double-Self arithmetic.
  ///
  /// `x` must be finite with `x > -1`, and `n` must be non-zero.
  @inline(__always)
  internal static func _compound(
    onePlus x: Self, _ n: Int
  ) -> (head: Self, tail: Self) {
    //  1+x is representable exactly as a double-Self value, which is the
    //  whole reason this operation exists as a distinct function.
    let onePlusX = Augmented.sum(1, x)
    //  For a negative exponent, take the reciprocal of the base up front
    //  rather than of the result. Both are accurate, but inverting first
    //  cannot overflow or underflow spuriously: see below.
    var base = n < 0
      ? _twoRecip((onePlusX.head, onePlusX.tail))
      : (head: onePlusX.head, tail: onePlusX.tail)
    var result = (head: Self(1), tail: Self(0))
    //  Use the magnitude so that n = Int.min does not trap on negation.
    var m = n.magnitude
    //  Binary exponentiation. Because base > 0, every intermediate value
    //  lies between 1 and the final result, so this cannot overflow or
    //  underflow unless the exact result does:
    //
    //  - `result` is a product of a subset of the squares, so it always
    //    lies between 1 and baseᵐ.
    //  - the largest square formed is base^(2^k) for 2^k <= m, which
    //    likewise lies between 1 and baseᵐ.
    while true {
      if m & 1 == 1 { result = _twoMul(result, base) }
      m >>= 1
      if m == 0 { break }
      base = _twoMul(base, base)
    }
    return result
  }
}
