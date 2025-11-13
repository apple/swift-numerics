//===--- Complex+Hashable.swift -------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2025 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import RealModule

extension Complex: Hashable {
  @_transparent
  public static func ==(a: Complex, b: Complex) -> Bool {
    // Identify all numbers with either component non-finite as a single
    // "point at infinity".
    guard a.isFinite || b.isFinite else { return true }
    // For finite numbers, equality is defined componentwise. Cases where
    // only one of a or b is infinite fall through to here as well, but this
    // expression correctly returns false for them so we don't need to handle
    // them explicitly.
    return a.x == b.x && a.y == b.y
  }
  
  @_transparent
  public func hash(into hasher: inout Hasher) {
    // There are two equivalence classes to which we owe special attention:
    // All zeros should hash to the same value, regardless of sign, and all
    // non-finite numbers should hash to the same value, regardless of
    // representation. The correct behavior for zero falls out for free from
    // the hash behavior of floating-point, but we need to use a
    // representative member for any non-finite values.
    if isFinite {
      hasher.combine(x)
      hasher.combine(y)
    } else {
      hasher.combine(RealType.infinity)
    }
  }
}
