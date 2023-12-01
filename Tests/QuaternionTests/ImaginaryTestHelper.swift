//===--- ImaginaryTestHelper.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019-2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

extension SIMD3 where Scalar: FloatingPoint {
  /// Returns a vector with .ulpOfOne in all lanes
  static var ulpOfOne: Self {
    Self(repeating: .ulpOfOne)
  }

  /// Returns a vector with nan in all lanes
  static var nan: Self {
    SIMD3(repeating: .nan)
  }

  /// Returns true if all lanes are NaN
  var isNaN: Bool {
    x.isNaN && y.isNaN && z.isNaN
  }
}
