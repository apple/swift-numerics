//===--- Midpoint.swift ---------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// The average of `a` and `b`, rounded to an integer according to `rule`.
///
/// Unlike commonly seen expressions such as `(a+b)/2` or `(a+b) >> 1` or
/// `a + (b-a)/2` (all of which may overflow for fixed-width integers),
/// this function never overflows, and the result is guaranteed to be
/// representable in the result type.
///
/// The default rounding rule is `.down`, which matches the behavior of
/// `(a + b) >> 1` when that expression does not overflow. Rounding
/// `.towardZero` matches the behavior of `(a + b)/2` when that expression
/// does not overflow. All other rounding modes are supported.
///
/// Rounding `.down` is generally most efficient; if you do not have a
/// reason to chose a specific other rounding rule, you should use the
/// default. 
@inlinable
public func midpoint<T: BinaryInteger>(
  _ a: T,
  _ b: T,
  rounding rule: RoundingRule = .down
) -> T {
  // Isolate bits in a + b with weight 2, and those with weight 1.
  let twos = a & b
  let ones = a ^ b
  let floor = twos + ones >> 1
  let frac = ones & 1
  switch rule {
  case .down:
    return floor
  case .up:
    return floor + frac
  case .towardZero:
    return floor + (floor < 0 ? frac : 0)
  case .toNearestOrAwayFromZero:
    fallthrough
  case .awayFromZero:
    return floor + (floor >= 0 ? frac : 0)
  case .toNearestOrEven:
    return floor + (floor & frac)
  case .toOdd:
    return floor + (~floor & frac)
  case .stochastically:
    return floor + (Bool.random() ? frac : 0)
  case .requireExact:
    precondition(frac == 0)
    return floor
  }
}

/// The average of `a` and `b`, rounded to an integer according to `rule`.
///
/// Unlike commonly seen expressions such as `(a+b)/2` or `(a+b) >> 1` or
/// `a + (b-a)/2` (all of which may overflow), this function never overflows,
/// and the result is guaranteed to be representable in the result type.
///
/// The default rounding rule is `.down`, which matches the behavior of
/// `(a + b) >> 1` when that expression does not overflow. Rounding
/// `.towardZero` matches the behavior of `(a + b)/2` when that expression
/// does not overflow. All other rounding modes are supported.
///
/// Rounding `.down` is generally most efficient; if you do not have a
/// reason to chose a specific other rounding rule, you should use the
/// default.
@inlinable
public func midpoint<T: FixedWidthInteger>(
  _ a: T,
  _ b: T,
  rounding rule: RoundingRule = .down
) -> T {
  // Isolate bits in a + b with weight 2, and those with weight 1
  let twos = a & b
  let ones = a ^ b
  let floor = twos &+ ones >> 1
  let frac = ones & 1
  switch rule {
  case .down:
    return floor
  case .up:
    return floor &+ frac
  case .towardZero:
    return floor &+ (floor < 0 ? frac : 0)
  case .toNearestOrAwayFromZero:
    fallthrough
  case .awayFromZero:
    return floor &+ (floor >= 0 ? frac : 0)
  case .toNearestOrEven:
    return floor &+ (floor & frac)
  case .toOdd:
    return floor &+ (~floor & frac)
  case .stochastically:
    return floor &+ (Bool.random() ? frac : 0)
  case .requireExact:
    precondition(frac == 0)
    return floor
  }
}

