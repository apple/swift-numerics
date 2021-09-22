//===--- Rounding.swift ---------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

public enum RoundingRule {
  case down
  case up
  case towardZero
  case awayFromZero
//     toEven
  case toOdd
//     toNearestOrDown
//     toNearestOrUp
//     toNearestOrTowardZero
  case toNearestOrAwayFromZero
  case toNearestOrEven
//     toNearestOrOdd
  case stochastic
  case trap
}

extension BinaryInteger {
  public func shifted<Count: BinaryInteger>(
    right count: Count,
    rounding rule: RoundingRule = .down
  ) -> Self {
    // Easiest case: count is zero or negative, so shift is always exact;
    // delegate to the normal >> operator.
    if count <= 0 { return self >> count }
    if count >= bitWidth {
      // Note: what follows would cause an infinite loop if bitWidth <= 1.
      // This will essentially never happen, but in the highly unlikely event
      // that we encounter such a case, we promote to Int8, do the shift, and
      // then convert back to the appropriate result type.
      if bitWidth <= 1 {
        return Self(Int8(self).shifted(right: count, rounding: rule))
      }
      // That pathological case taken care of, we can now handle over-wide
      // shifts by first shifting all but bitWidth - 1 bits with sticky
      // rounding, and then shifting the remaining bitWidth - 1 bits with
      // the desired rounding mode.
      let count = count - Count(bitWidth - 1)
      var floor = self >> count
      let frac = self - (floor << count)
      if frac != 0 { floor |= 1 } // insert sticky bit
      return floor.shifted(right: bitWidth - 1, rounding: rule)
    }
    // Now we are in the happy case: 0 < count < bitWidth, which makes all
    // the math to handle rounding simpler.
    //
    // TODO: If we were really, really careful about overflow, some of these
    // could be made simpler. E.g. mathematically round up is implemented here
    // via:
    //
    //   floor = self >> count
    //   mask = 1 << count - 1
    //   frac = self & mask
    //   return floor + (frac == 0 ? 0 : 1)
    //
    // _if_ we didn't have to worry about intermediate overflow (either because
    // self is bounded away from .max or because we don't have a fixed-width
    // type), then we could use the following instead:
    //
    //   mask = 1 << count - 1
    //   return (self + mask) >> count
    //
    // However, self + mask can overflow, e.g. if we're shifting .max by 1:
    //
    //   mask = 1 << 1 - 1 = 1
    //   self + mask = .max + 1 // uh-oh
    //
    // This cannot occur for arbitrary-precision numbers, so we could use
    // the simpler expressions for those (but those are precisely the cases
    // where performance does not matter). More interesting, we could promote
    // fixed-width numbers to a wider type, preventing this intermediate
    // overflow and allowing us to use the simpler expressions much of the
    // time. We could also explicitly _detect_ the overflow if it happens and
    // patch up the result, though this is a little bit tricky because
    // addingReportingOverflow does not exist on BinaryInteger. Hence, this
    // is a TODO for the future.
    let mask = Magnitude(1) << count - 1
    let frac = Magnitude(truncatingIfNeeded: self) & mask
    let floor = self >> count
    let ceiling = floor + (frac == 0 ? 0 : 1)
    switch rule {
    case .down:
      return floor
    case .up:
      return ceiling
    case .towardZero:
      return self > 0 ? floor : ceiling
    case .awayFromZero:
      return self < 0 ? floor : ceiling
    case .toOdd:
      return floor | (frac == 0 ? 0 : 1)
    case .toNearestOrAwayFromZero:
      let round = mask >> 1 + (self > 0 ? 1 : 0)
      return floor + Self((round + frac) >> count)
    case .toNearestOrEven:
      let round = mask >> 1 + Magnitude(floor & 1)
      return floor + Self((round + frac) >> count)
    case .stochastic:
      // TODO: it's unfortunate that we can't specify a custom random source
      // for the stochastic rounding rule, but I don't see a nice way to have
      // that share the API with the other rounding rules, because we'd then
      // have to take the RNG in-out. The same problem applies to rounding
      // with dithering. We should consider adding a stateful rounding API
      // down the road to support those use cases.
      //
      // In theory, u01 should be Self.random(in: 0 ..< onesBit), but the
      // random(in:) method does not exist on BinaryInteger. This is
      // (arguably) good, though, because there's actually no reason to
      // generate large amounts of randomness just to implement stochastic
      // rounding for bigints; we can cap it at word-size, which is way
      // more than needed to generate high-quality results.
      let u01 = UInt.random(in: 0 ... .max)
      if count < UInt.bitWidth {
        // count is small, so u01 & mask is representable as both UInt
        // and Self, regardless of what type Self actually is.
        return floor + Self(((u01 & UInt(mask)) + UInt(frac)) >> count)
      }
      // count is large, so Self is a type larger than UInt. Do the shift
      // for frac in two stages so we can do the rounding work in UInt:
      let smallFrac = UInt(truncatingIfNeeded: frac >> (count - Count(UInt.bitWidth)))
      let (_, carry) = smallFrac.addingReportingOverflow(u01)
      return floor + (carry ? 1 : 0)
    case .trap:
      precondition(frac == 0, "shift was not exact.")
      return floor
    }
  }
}
