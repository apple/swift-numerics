//===--- RoundingRule.swift -----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift Numerics project authors
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
public enum RoundingRule {
  /// Produces the closest representable value that is less than or equal
  /// to the value being rounded.
  ///
  /// This is the default rounding mode for integer shifts, including the
  /// shift operators defined in the standard library.
  case down
  
  /// Produces the closest representable value that is greater than or equal
  /// to the value being rounded.
  case up
  
  /// Produces the closest representable value whose magnitude is less than
  /// or equal to that of the value being rounded.
  case towardZero
  
  /// Produces the closest representable value whose magnitude is greater than
  /// or equal to that of the value being rounded.
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
  case toOdd
  
  /// Produces the representable value that is closest to the value being
  /// rounded. If two values are equally close, the one that has greater
  /// magnitude is returned.
  case toNearestOrAwayFromZero
  
  /// Produces the representable value that is closest to the value being
  /// rounded. If two values are equally close, the one whose least
  /// significant bit is not set is returned.
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
  case stochastically
  
  /// If the value being rounded is representable, that value is returned.
  /// Otherwise, a precondition failure occurs.
  case requireExact
}
