//===--- Scale.swift ------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2025 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// Policy: deliberately not using the * and / operators for these at the
// moment, because then there's an ambiguity in expressions like 2*z; is
// that Complex(2) * z or is it RealType(2) * z? This is especially
// problematic in type inference: suppose we have:
//
//   let a: RealType = 1
//   let b = 2*a
//
// what is the type of b? If we don't have a type context, it's ambiguous.
// If we have a Complex type context, then b will be inferred to have type
// Complex! Obviously, that doesn't help anyone.

extension Complex {
  /// The result of multiplying this value by the real number `a`.
  ///
  /// Equivalent to `self * Complex(a)`, but may be computed more efficiently.
  @inlinable @inline(__always)
  public func multiplied(by a: RealType) -> Complex {
    Complex(x*a, y*a)
  }
  
  /// The result of dividing this value by the real number `a`.
  ///
  /// More efficient than `self / Complex(a)`. May not produce exactly the
  /// same result, but will always be more accurate if they differ.
  @inlinable @inline(__always)
  public func divided(by a: RealType) -> Complex {
    Complex(x/a, y/a)
  }
}
