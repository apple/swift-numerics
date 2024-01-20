//===--- BinaryFloatingPoint+Extensions.swift -----------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension BinaryFloatingPoint {

  static var bias: Int { (1 << (exponentBitCount - 1)) - 1 }

  static var exponentMask: RawExponent { (1 << exponentBitCount) - 1 }
  static var exponentAll1: RawExponent { (~0) & exponentMask }

  // Note that `Float80.significandBitCount` is `63`, even though `64 bits`
  // are actually used (`Float80` explicitly stores the leading integral bit).
  static var significandMask: RawSignificand { (1 << Self.significandBitCount) - 1 }
  static var significandAll1: RawSignificand { (~0) & significandMask }

  var nextAwayFromZero: Self {
    switch self.sign {
    case .plus: return self.nextUp
    case .minus: return self.nextDown
    }
  }

  var nextTowardZero: Self {
    switch self.sign {
    case .plus: return self.nextDown
    case .minus: return self.nextUp
    }
  }
}
