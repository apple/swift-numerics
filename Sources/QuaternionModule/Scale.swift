//===--- Scale.swift ------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2022 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// Policy: deliberately not using the * and / operators for these at the
// moment, because then there's an ambiguity in expressions like 2*p; is
// that Quaternion(2) * p or is it RealType(2) * p? This is especially
// problematic in type inference: suppose we have:
//
//   let a: RealType = 1
//   let b = 2*a
//
// what is the type of b? If we don't have a type context, it's ambiguous.
// If we have a Quaternion type context, then b will be inferred to have type
// Quaternion! Obviously, that doesn't help anyone.
//
// TODO: figure out if there's some way to avoid these surprising results
// and turn these into operators if/when we have it.
// (https://github.com/apple/swift-numerics/issues/12)
extension Quaternion {
  /// `self` scaled by `scalar`.
  @usableFromInline @_transparent
  internal func multiplied(by scalar: RealType) -> Quaternion {
    Quaternion(from: components * scalar)
  }

  /// `self` unscaled by `scalar`.
  @usableFromInline @_transparent
  internal func divided(by scalar: RealType) -> Quaternion {
    Quaternion(from: components / scalar)
  }
}
