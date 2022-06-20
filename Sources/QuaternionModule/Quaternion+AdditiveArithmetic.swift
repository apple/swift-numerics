//===--- Quaternion+AdditiveArithmetic.swift ------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2022 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension Quaternion: AdditiveArithmetic {
  /// The additive identity, with real and *all* imaginary parts zero, i.e.:
  /// `0 + 0i + 0j + 0k`
  ///
  /// See also: `one`, `i`, `j`, `k`, `infinity`
  @_transparent
  public static var zero: Quaternion {
    Quaternion(from: SIMD4(repeating: 0))
  }

  @_transparent
  public static func + (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
    Quaternion(from: lhs.components + rhs.components)
  }

  @_transparent
  public static func - (lhs: Quaternion, rhs: Quaternion) -> Quaternion {
    Quaternion(from: lhs.components - rhs.components)
  }

  @_transparent
  public static func += (lhs: inout Quaternion, rhs: Quaternion) {
    lhs = lhs + rhs
  }

  @_transparent
  public static func -= (lhs: inout Quaternion, rhs: Quaternion) {
    lhs = lhs - rhs
  }
}
