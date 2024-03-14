//===--- RoundingRule.swift -----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021 - 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// A rule that defines how to select one of the two representable results
/// closest to a given value.
///
/// [Wikipedia](https://en.wikipedia.org/wiki/Rounding#Rounding_to_integer)
/// provides a good overview of different rounding rules.
///
/// Examples using rounding to integer to illustrate the various options:
/// ```
///  value |     down     |      up      |  towardZero  | awayFromZero |
/// =======+==============+==============+==============+==============+
///   1.5  |       1      |       2      |       1      |       2      |
/// -------+--------------+--------------+--------------+--------------+
///  -0.5  |      -1      |       0      |       0      |      -1      |
/// -------+--------------+--------------+--------------+--------------+
///   0.3  |       0      |       1      |       0      |       1      |
/// -------+--------------+--------------+--------------+--------------+
///    2   |       2      |       2      |       2      |       2      |
/// -------+--------------+--------------+--------------+--------------+
///
///  value |    toOdd     | toNearestOrAwayFromZero |  toNearestOrEven |
/// =======+==============+=========================+==================+
///   1.5  |       1      |            2            |         2        |
/// -------+--------------+-------------------------+------------------+
///  -0.5  |      -1      |           -1            |         0        |
/// -------+--------------+-------------------------+------------------+
///   0.3  |       1      |            0            |         0        |
/// -------+--------------+-------------------------+------------------+
///    2   |       2      |            2            |         2        |
/// -------+--------------+-------------------------+------------------+
///
///  value |    stochastically     |  requireExact  |
/// =======+=======================+================+
///   1.5  |     50% 1, 50% 2      |      trap      |
/// -------+-----------------------+----------------+
///  -0.5  |    50% -1, 50% 0      |      trap      |
/// -------+-----------------------+----------------+
///   0.3  |     70% 0, 30% 1      |      trap      |
/// -------+-----------------------+----------------+
///    2   |          2            |        2       |
/// -------+-----------------------+----------------+
/// ```
public enum RoundingRule {
  /// Produces the closest representable value that is less than or equal
  /// to the value being rounded.
  ///
  /// This is the default rounding mode for integer shifts, including the
  /// shift operators defined in the standard library. 
  ///
  /// Examples:
  /// - `(-4).divided(by: 3, rounding: .down)` is `-2`, because –2 is the
  /// largest integer less than –4/3 = –1.3̅
  /// - `5.shifted(rightBy: 1, rounding: .down)` is `2`, because 2 is the
  /// largest integer less than 5/2 = 2.5.
  case down
  
  /// Produces the closest representable value that is greater than or equal
  /// to the value being rounded.
  ///
  /// Examples:
  /// - `(-4).divided(by: 3, rounding: .up)` is `-1`, because –1 is the
  /// smallest integer greater than –4/3 = –1.3̅
  /// - `5.shifted(rightBy: 1, rounding: .up)` is `3`, because 3 is the
  /// smallest integer greater than 5/2 = 2.5.
  case up
  
  /// Produces the closest representable value whose magnitude is less than
  /// or equal to that of the value being rounded.
  ///
  /// Examples:
  /// - `(-4).divided(by: 3, rounding: .towardZero)` is `-1`, because –1
  /// is the closest integer to –4/3 = –1.3̅ with smaller magnitude.
  /// - `5.shifted(rightBy: 1, rounding: .towardZero)` is `2`, because 2
  /// is the closest integer to 5/2 = 2.5 with smaller magnitude.
  case towardZero
  
  /// Produces the closest representable value whose magnitude is greater
  /// than or equal to that of the value being rounded.
  ///
  /// Examples:
  /// - `(-4).divided(by: 3, rounding: .awayFromZero)` is `-2`, because –2
  /// is the closest integer to –4/3 = –1.3̅ with greater magnitude.
  /// - `5.shifted(rightBy: 1, rounding: .awayFromZero)` is `3`, because 3
  /// is the closest integer to 5/2 = 2.5 with greater magnitude.
  case awayFromZero
  
  /// If the value being rounded is representable, that value is returned.
  /// Otherwise, whichever of the two closest representable values has its
  /// least significant bit set is returned.
  ///
  /// This is also called _sticky rounding_, and it is useful as an
  /// implementation detail because it has the property that if we do
  /// rounding in two steps, first to intermediate precision p₁ with .toOdd,
  /// then to the final precision p₂ with any other rounding mode, the result
  /// we get is the same as if we rounded directly to p₂ in the desired mode
  /// so long as p₂ + 1 < p₁. Other rounding modes do not have this property,
  /// and admit _double roundings_ when interoperating with some modes.
  ///
  /// Examples:
  /// - `(-4).divided(by: 3, rounding: .toOdd)` is `-1`, because –4/3 = –1.3̅
  /// is not an exact integer, and –1 is the closest odd integer.
  /// - `4.shifted(rightBy: 1, rounding: .toOdd)` is `2`,
  /// even though 2 is even, because 4/2 is exactly 2 and no rounding occurs.
  case toOdd
  
  /// Produces the representable value that is closest to the value being
  /// rounded. If two values are equally close, the one that has greater
  /// magnitude is returned.
  ///
  /// Examples:
  /// - `(-4).divided(by: 3, rounding: .toNearestOrAwayFromZero)`
  /// is `-1`, because –4/3 = –1.3̅ is closer to –1 than it is to –2.
  ///
  /// - `5.shifted(rightBy: 1, rounding: .toNearestOrAwayFromZero)` is `3`,
  /// because 5/2 = 2.5 is equally close to 2 and 3, and 3 is further away
  /// from zero.
  case toNearestOrAwayFromZero
  
  /// Produces the representable value that is closest to the value being
  /// rounded. If two values are equally close, the one whose least
  /// significant bit is not set is returned.
  ///
  /// Examples:
  /// - `(-4).divided(by: 3, rounding: .toNearestOrEven)`
  /// is `-1`, because –4/3 = –1.3̅ is closer to –1 than it is to –2.
  ///
  /// - `5.shifted(rightBy: 1, rounding: .toNearestOrEven)` is `2`,
  /// because 5/2 = 2.5 is equally close to 2 and 3, and 2 is even.
  case toNearestOrEven
  
  /// Adds a uniform random value from [0, d) to the value being rounded,
  /// where d is the distance between the two closest representable values,
  /// then rounds the sum downwards.
  ///
  /// Unlike all the other rounding modes, this mode is _not deterministic_;
  /// repeated calls to rounding operations with this mode will generally
  /// produce different results. There is a tradeoff implicit in using this
  /// mode: you can sacrifice _reproducible_ results to get _more accurate_
  /// results in aggregate. For a contrived but illustrative example, consider
  /// the following:
  /// ```
  /// let data = Array(repeating: 1, count: 100)
  /// let result = data.reduce(0) {
  ///   $0 + $1.divided(by: 3, rounding: rule)
  /// }
  /// ```
  /// because 1/3 is always the same value between 0 and 1, any
  /// deterministic rounding rule must produce either 0 or 100 for
  /// this computation. But rounding `stochastically` will
  /// produce a value close to 33. The _error_ of the computation
  /// is smaller, but the result will now change between runs of the
  /// program.
  ///
  /// For this simple case a better solution would be to add the
  /// values first, and then divide. This gives a result that is both
  /// reproducible _and_ accurate:
  /// ```
  /// let result = data.reduce(0, +)/3
  /// ```
  /// but this isn't always possible in more sophisticated scenarios,
  /// and in those cases this rounding rule may be useful.
  ///
  /// Examples:
  /// - `(-4).divided(by: 3, rounding: .stochastically)`
  /// will be –1 with probability 2/3 and –2 with probability 1/3.
  /// - `5.shifted(rightBy: 1, rounding: .stochastically)`
  /// will be 2 with probability 1/2 and 3 with probability 1/2.
  case stochastically
  
  /// If the value being rounded is representable, that value is returned.
  /// Otherwise, a precondition failure occurs.
  ///
  /// Examples:
  /// - `(-4).divided(by: 3, rounding: .requireExact)` will trap,
  /// because –4/3 = –1.3̅ is not an integer.
  case requireExact
}
