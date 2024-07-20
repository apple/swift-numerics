//===--- DivideWithRounding.swift -----------------------------*- swift -*-===//
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
  /// chosen because it generally produces a more useful remainder. In
  /// particular, when `b` is positive, the remainder is always positive.
  /// To match the behavior of `/`, use the `.towardZero` rounding mode.
  ///
  /// Note that the remainder of division is not always representable in an
  /// unsigned type if a rounding rule other than `.down`, `.towardZero`, or
  /// `.requireExact` is used. For example:
  ///
  ///     let a: UInt = 5
  ///     let b: UInt = 3
  ///     let q = a.divided(by: b, rounding: .up) // 2
  ///     let r = a - b*q // 5 - 3*2 overflows UInt.
  ///
  /// For this reason, there is no `remainder(dividingBy:rounding:)`
  /// operation defined on `BinaryInteger`. Signed integers do not have
  /// this problem, so it is defined on the `SignedInteger` protocol
  /// instead, as is an overload of `divided(by:rounding:)` that returns
  /// both quotient and remainder.
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
      
    case .awayFromZero:
      break
      
    case .toNearestOrDown:
      if r.magnitude > other.magnitude.shifted(rightBy: 1, rounding: .down) ||
          2*r.magnitude == other.magnitude && other.signum() != r.signum() {
        break
      }
      return q
      
    case .toNearestOrUp:
      if r.magnitude > other.magnitude.shifted(rightBy: 1, rounding: .down) ||
          2*r.magnitude == other.magnitude && other.signum() == r.signum() {
        break
      }
      return q
      
    case .toNearestOrZero:
      if r.magnitude <= other.magnitude.shifted(rightBy: 1, rounding: .down) {
        return q
      }
      // Otherwise, round q away from zero.
      
    case .toNearestOrAway:
      if r.magnitude < other.magnitude.shifted(rightBy: 1, rounding: .up) {
        return q
      }
      
    case .toNearestOrEven:
      // First guarantee that |r| <= |other/2|; if not we have to round away
      // instead, so break to do that.
      if r.magnitude > other.magnitude.shifted(rightBy: 1, rounding: .down) ||
         2*r.magnitude == other.magnitude && !q.isMultiple(of: 2) {
        break
      }
      return q
      
    case .toOdd:
      // If q is already odd, we have the correct result.
      if q._lowWord & 1 == 1 { return q }
      
    case .stochastically:
      let bmag = other.magnitude
      let rmag = r.magnitude
      var bhi: UInt64
      var rhi: UInt64
      if other.magnitude <= UInt64.max {
        bhi = UInt64(bmag)
        rhi = UInt64(rmag)
      } else {
        let shift = bmag._msb - 63
        bhi = UInt64(truncatingIfNeeded: bmag >> shift)
        rhi = UInt64(truncatingIfNeeded: rmag >> shift)
      }
      let (sum, car) = rhi.addingReportingOverflow(.random(in: 0 ..< bhi))
      if sum < bhi && !car { return q }
      
    case .requireExact:
      preconditionFailure("Division was not exact.")
    }
    
    // We didn't have the right result, so round q away from zero.
    return other.signum() == r.signum() ? q+1 : q-1
  }
  
  // TODO: make this API and make it possible to implement more efficiently.
  // Customization point on new/revised integer protocol? Shouldn't have to
  // go through .words.
  
  /// The index of the most-significant set bit.
  ///
  /// - Precondition: self is assumed to be non-zero (should be changed
  ///   if/when this becomes API).
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
  /// and returns the remainder.
  ///
  /// The default rounding rule is `.down`, which _is not the same_ as the
  /// behavior of the `%` operator from the Swift standard library, but is
  /// chosen because it generally produces a more useful remainder. To
  /// match the behavior of `%`, use the `.towardZero` rounding mode.
  ///
  /// - Precondition: `other` cannot be zero.
  @inlinable
  public func remainder(
    dividingBy other: Self,
    rounding rule: RoundingRule = .down
  ) -> Self {
    // Produce correct remainder for the .min/-1 case, rather than trapping.
    if other == -1 { return 0 }
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
  /// of any existing use sites. To call this method, you must explicitly
  /// bind the result to a tuple:
  ///
  ///     // This calls BinaryInteger's method, which returns only
  ///     // the quotient.
  ///     let result = 5.divided(by: 3, rounding: .up) // 2
  ///
  ///     // This calls SignedInteger's method, which returns both
  ///     // the quotient and remainder.
  ///     let (q, r) = 5.divided(by: 3, rounding: .up) // (q = 2, r = -1)
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
      return other.signum() == r.signum() ? (q, r) : (q-1, r+other)
      
    case .up:
      // For rounding up, we want to have r have the opposite sign of
      // other; if not, we adjust q upward and r to match.
      return other.signum() == r.signum() ? (q+1, r-other) : (q, r)
      
    case .towardZero:
      // This is exactly what the `/` operator did for us.
      return (q, r)
      
    case .awayFromZero:
      break
      
    case .toNearestOrDown:
      // If |r| < |other/2|, we already rounded q to nearest. If the are
      // equal and q is negative, then we already broke the tie in the right
      // direction. However, we don't have access to the before-rounding q,
      // which may have rounded up to zero, losing the sign information, so
      // we have to look at other and r instead.
      if 2*r.magnitude  < other.magnitude ||
         2*r.magnitude == other.magnitude && other.signum() == r.signum() {
        return (q, r)
      }
      
    case .toNearestOrUp:
      // If |r| < |other/2|, we already rounded q to nearest. If the are
      // equal and q is non-negative, then we already broke the tie in the
      // right direction.
      if 2*r.magnitude  < other.magnitude ||
         2*r.magnitude == other.magnitude && other.signum() != r.signum() {
        return (q, r)
      }
      
    case .toNearestOrZero:
      // Check first if |r| <= |other/2|. If this holds, we have already
      // rounded q correctly. Because we're working with magnitudes, we can
      // safely compute 2r without worrying about overflow, even for fixed-
      // width types, because r cannot be .min (because |r| < |other| by
      // construction).
      if 2*r.magnitude <= other.magnitude {
        return (q, r)
      }
      
    case .toNearestOrAway:
      // Check first if |r| < |other/2|. If this holds, we already rounded
      // q to nearest.
      if 2*r.magnitude < other.magnitude {
        return (q, r)
      }
      
    case .toNearestOrEven:
      // If |r| < |other/2|, we already rounded q to nearest. If the are
      // equal and q is even, then we already broke the tie in the right
      // direction.
      if 2*r.magnitude  < other.magnitude ||
         2*r.magnitude == other.magnitude && q.isMultiple(of: 2) {
        return (q, r)
      }
      
    case .toOdd:
      // If q is already odd, we have the correct result.
      if q._lowWord & 1 == 1 { return (q, r) }
      
    case .stochastically:
      let bmag = other.magnitude
      let rmag = r.magnitude
      var bhi: UInt64
      var rhi: UInt64
      if other.magnitude <= UInt64.max {
        bhi = UInt64(bmag)
        rhi = UInt64(rmag)
      } else {
        let shift = bmag._msb - 63
        bhi = UInt64(truncatingIfNeeded: bmag >> shift)
        rhi = UInt64(truncatingIfNeeded: rmag >> shift)
      }
      let (sum, car) = rhi.addingReportingOverflow(.random(in: 0 ..< bhi))
      if sum < bhi && !car { return (q, r) }
      
    case .requireExact:
      preconditionFailure("Division was not exact.")
    }
    
    // Fallthrough behavior is to round q away from zero and adjust r to
    // match.
    return other.signum() == r.signum() ? (q+1, r-other) : (q-1, r+other)
  }
}

/// `a = quotient*b + remainder`, with `remainder >= 0`.
///
/// When `a` and `b` are both positive, `quotient` is `a/b` and `remainder`
/// is `a%b`.
///
/// Rounding the quotient so that the remainder is non-negative is called
/// "Euclidean division". This is not a _rounding rule_, as `quotient`
/// cannot be determined from the unrounded value `a/b`; we need to also
/// know the sign of `a` or `b` or `r` to know which way to round. Because
/// of this, is not present in the `RoundingRule` enum and uses a separate
/// API from the other division operations.
///
/// - Parameters:
///   - a: The dividend
///   - b: The divisor
///
/// - Precondition: `b` must be non-zero, and the quotient `a/b` must be
///   representable. In particular, if `T` is a signed fixed-width integer
///   type, then `euclideanDivision(T.min, -1)` will trap, because `-T.min`
///   is not representable.
///
/// - Returns: `(quotient, remainder)`, with `0 <= remainder < b.magnitude`.
func euclideanDivision<T>(_ a: T, _ b: T) -> (quotient: T, remainder: T)
where T: SignedInteger
{
  a.divided(by: b, rounding: a >= 0 ? .towardZero : .awayFromZero)
}
