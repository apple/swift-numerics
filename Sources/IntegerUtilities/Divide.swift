//===--- Divide.swift -----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension BinaryInteger {
  /// `self` divided by `other`, rounding the result according to `rule`.
  ///
  /// The default rounding rule is `.down`, which _is not the same_ as the
  /// behavior of the `/` operator from the Swift standard library, but is
  /// chosen because it generally produces a more useful remainder. To
  /// match the behavior of `/`, use the `.towardZero` rounding mode.
  ///
  /// Be aware that if the type is unsigned, the remainder of the division
  /// may not be representable when a non-default rounding mode is used:
  /// ```
  ///
  /// ```
  /// For signed types, the remainder is always representable.
  @inlinable
  public func divided(
    by other: Self,
    rounding rule: RoundingRule = .down
  ) -> Self {
    // "Normal divsion" rounds toward zero, so we get self = q*other + r
    // with |r| < |other| and r matching the sign of self.
    let q = self / other
    let r = self - q*other
    // In every rounding mode, the result is the same when the result is
    // exact.
    if r == 0 { return q }
    // From this point forward, we can assume r != 0.
    //
    // To get the quotient and remainder rounded as directed by rule, we
    // will adjust q and r. Note that the quotient is either q-1 or q (if
    // q is negative) or q or q+1 (if q is positive), because q has been
    // rounded toward zero.
    //
    // If we subtract 1 from q, we add other to r to compensate, because:
    //
    //   self = q*other + r
    //        = (q-1)*other + (r+other)
    //
    // Similarly, if we add 1 to q, we subtract other from r to compensate.
    switch rule {
    case .down:
      // For rounding down, we want to have r match the sign of other
      // rather than self; this means that if the signs of r and other
      // disagree, we have to adjust q downward and r to match.
      if other.signum() != r.signum() { return q-1 }
      return q
    case .up:
      // For rounding up, we want to have r have the opposite sign of
      // other; if not, we adjust q upward and r to match.
      if other.signum() == r.signum() { return q+1 }
      return q
    case .towardZero:
      // This is exactly what the `/` operator did for us.
      return q
    case .toOdd:
      // If q is already odd, we're done.
      if q._lowWord & 1 == 1 { return q }
      // Otherwise, q is even but inexact; it was originally rounded toward
      // zero, so rounding away from zero instead will make it odd.
      fallthrough
    case .awayFromZero:
      // To round away from zero, we apply the adjustments for both down
      // and up.
      if other.signum() != r.signum() { return q-1 }
      return q+1
    case .toNearestOrAwayFromZero:
      // For round to nearest or away, the condition we want to satisfy is
      // |r| <= |other/2|, with sign(q) != sign(r) when equality holds.
      if r.magnitude < other.magnitude.shifted(rightBy: 1, rounding: .up) {
        return q
      }
      // The (q,r) we have does not satisfy the to nearest or away condition;
      // round away from zero to choose the other representative of (q, r).
      if other.signum() != r.signum() { return q-1 }
      return q+1
    case .toNearestOrEven:
      // For round to nearest or away, the condition we want to satisfy is
      // |r| <= |other/2|, with q even when equality holds.
      if r.magnitude >  other.magnitude.shifted(rightBy: 1, rounding: .down) ||
          2*r.magnitude == other.magnitude && q._lowWord & 1 == 1 {
        if (other > 0) != (r > 0) { return q-1 }
        return q+1
      }
      return q
    case .stochastically:
      var qhi: UInt64
      var rhi: UInt64
      if other.magnitude <= UInt64.max {
        qhi = UInt64(other.magnitude)
        rhi = UInt64(r.magnitude)
      } else {
        // TODO: this is untested currently.
        let qmag = other.magnitude
        let shift = qmag._msb - 1
        qhi = UInt64(truncatingIfNeeded: qmag >> shift)
        rhi = UInt64(truncatingIfNeeded: r.magnitude >> shift)
      }
      let (sum, car) = rhi.addingReportingOverflow(.random(in: 0 ..< qhi))
      if car || sum >= qhi {
        if (other > 0) != (r > 0) { return q-1 }
        return q+1
      }
      return q
    case .requireExact:
      preconditionFailure("Division was not exact.")
    }
  }
  
  // TODO: make this API and make it possible to implement more
  // efficiently. Customization point on new/revised integer
  // protocol? Shouldn't have to go through .words.
  @usableFromInline
  internal var _msb: Int {
    // a == 0 is never used for division, because this is called
    // on the divisor which cannot be zero as a precondition; if
    // this becomes API, the behavior for this case will have to
    // be defined.
    assert(self != 0)
    // Because self is non-zero, mswIndex is guaranteed to exist,
    // hence force-unwrap is appropriate.
    let mswIndex = words.lastIndex { $0 != 0 }!
    let mswBits = UInt.bitWidth * words.distance(from: words.startIndex, to: mswIndex)
    return mswBits + (UInt.bitWidth - words[mswIndex].leadingZeroBitCount - 1)
  }
}

extension SignedInteger {
  /// Divides `self` by `other`, rounding the quotient according to `rule`,
  /// and returns both the remainder.
  ///
  /// The default rounding rule is `.down`, which _is not the same_ as the
  /// behavior of the `%` operator from the Swift standard library, but is
  /// chosen because it generally produces a more useful remainder. To
  /// match the behavior of `%`, use the `.towardZero` rounding mode.
  @inlinable
  public func remainder(
    dividingBy other: Self,
    rounding rule: RoundingRule = .down
  ) -> Self {
    return self.divided(by: other, rounding: rule).remainder
  }
  
  /// Divides `self` by `other`, rounding the quotient according to `rule`,
  /// and returns both the quotient and remainder.
  ///
  /// The default rounding rule is `.down`, which _is not the same_ as the
  /// behavior of the `/` operator from the Swift standard library, but is
  /// chosen because it generally produces a more useful remainder. To
  /// match the behavior of `/`, use the `.towardZero` rounding mode.
  ///
  /// Because the default rounding mode does not match Swift's standard
  /// library, this function is a disfavored overload of `divided(by:)`
  /// instead of using the name `quotientAndRemainder(dividingBy:)`, which
  /// would shadow the standard library operation and change the behavior
  /// of any existing use sites.
  @inlinable @inline(__always) @_disfavoredOverload
  public func divided(
    by other: Self,
    rounding rule: RoundingRule = .down
  ) -> (quotient: Self, remainder: Self) {
    // "Normal divsion" rounds toward zero, so we get self = q*other + r
    // with |r| < |other| and r matching the sign of self.
    let q = self / other
    let r = self - q*other
    // In every rounding mode, the result is the same when the result is
    // exact.
    if r == 0 { return (q, r) }
    // From this point forward, we can assume r != 0.
    //
    // To get the quotient and remainder rounded as directed by rule, we
    // will adjust q and r. Note that the quotient is either q-1 or q (if
    // q is negative) or q or q+1 (if q is positive), because q has been
    // rounded toward zero.
    //
    // If we subtract 1 from q, we add other to r to compensate, because:
    //
    //   self = q*other + r
    //        = (q-1)*other + (r+other)
    //
    // Similarly, if we add 1 to q, we subtract other from r to compensate.
    switch rule {
    case .down:
      // For rounding down, we want to have r match the sign of other
      // rather than self; this means that if the signs of r and other
      // disagree, we have to adjust q downward and r to match.
      if other.signum() != r.signum() { return (q-1, r+other) }
      return (q, r)
    case .up:
      // For rounding up, we want to have r have the opposite sign of
      // other; if not, we adjust q upward and r to match.
      if other.signum() == r.signum() { return (q+1, r-other) }
      return (q, r)
    case .towardZero:
      // This is exactly what the `/` operator did for us.
      return (q, r)
    case .toOdd:
      // If q is already odd, we're done.
      if q._lowWord & 1 == 1 { return (q, r) }
      // Otherwise, q is even but inexact; it was originally rounded toward
      // zero, so rounding away from zero instead will make it odd.
      fallthrough
    case .awayFromZero:
      // To round away from zero, we apply the adjustments for both down
      // and up.
      if other.signum() != r.signum() { return (q-1, r+other) }
      return (q+1, r-other)
    case .toNearestOrAwayFromZero:
      // For round to nearest or away, the condition we want to satisfy is
      // |r| <= |other/2|, with sign(q) != sign(r) when equality holds.
      if r.magnitude < other.magnitude.shifted(rightBy: 1, rounding: .up) {
        return (q, r)
      }
      // The (q,r) we have does not satisfy the to nearest or away condition;
      // round away from zero to choose the other representative of (q, r).
      if other.signum() != r.signum() { return (q-1, r+other) }
      return (q+1, r-other)
    case .toNearestOrEven:
      // For round to nearest or away, the condition we want to satisfy is
      // |r| <= |other/2|, with q even when equality holds.
      if r.magnitude >  other.magnitude.shifted(rightBy: 1, rounding: .down) ||
          2*r.magnitude == other.magnitude && q._lowWord & 1 == 1 {
        if (other > 0) != (r > 0) { return (q-1, r+other) }
        return (q+1, r-other)
      }
      return (q, r)
    case .stochastically:
      var qhi: UInt64
      var rhi: UInt64
      if other.magnitude <= UInt64.max {
        qhi = UInt64(other.magnitude)
        rhi = UInt64(r.magnitude)
      } else {
        // TODO: this is untested currently.
        let qmag = other.magnitude
        let shift = qmag._msb - 1
        qhi = UInt64(truncatingIfNeeded: qmag >> shift)
        rhi = UInt64(truncatingIfNeeded: r.magnitude >> shift)
      }
      let (sum, car) = rhi.addingReportingOverflow(.random(in: 0 ..< qhi))
      if car || sum >= qhi {
        if (other > 0) != (r > 0) { return (q-1, r+other) }
        return (q+1, r-other)
      }
      return (q, r)
    case .requireExact:
      preconditionFailure("Division was not exact.")
    }
  }
}

/// `a = quotient*b + remainder`, with `remainder >= 0`.
///
/// Rounding the quotient so that the remainder is non-negative is called
/// "Euclidean division". This is not a _rounding rule_, as `quotient`
/// cannot be determined just from the unrounded value `a/b`; we need to
/// also know the sign of either `a` or `b` to know which way to round.
/// Because of this, is not present in the `RoundingRule` enum and uses
/// a separate API from the other division operations.
///
/// - Parameters:
///   - a: The dividend
///   - b: The divisor, must be non-zero.
///
/// - Returns: `(quotient, remainder)`, with `0 <= remainder < b.magnitude`
///   if `quotient` is representable.
func euclideanDivision<T>(_ a: T, _ b: T) -> (quotient: T, remainder: T)
where T: SignedInteger
{
  a.divided(by: b, rounding: b >= 0 ? .down : .up)
}
