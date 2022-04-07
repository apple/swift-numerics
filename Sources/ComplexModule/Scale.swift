//===--- Scale.swift ------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2021 Apple Inc. and the Swift Numerics project authors
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
//
// TODO: figure out if there's some way to avoid these surprising results
// and turn these into operators if/when we have it.
// (https://github.com/apple/swift-numerics/issues/12)
extension Complex {
  /// `self` scaled by `a`.
  @usableFromInline @_transparent
  internal func multiplied(by a: RealType) -> Complex {
    // This can be viewed in two different ways, which are mathematically
    // equivalent: either we are computing `self * Complex(a)` (i.e.
    // converting `a` to be a complex value, and then using the complex
    // multiplication) or we are using the scalar product of the vector
    // space structure: `Complex(a*real, a*imaginary)`.
    //
    // Although these two interpretations are _mathematically_ equivalent,
    // they will generate different representations of the point at
    // infinity in general. For example, suppose `self` is represented by
    // `(infinity, 0)`. Then `self * Complex(1)` would evaluate as
    // `(1*infinity - 0*0, 0*infinity + 1*0) = (infinity, nan)`, but
    // the vector space interpretation produces `(infinity, 0)`. This does
    // not matter much, because these are two representations of the same
    // semantic value, but note that one requires four multiplies and two
    // additions, while the one we use requires only two real multiplications.
    Complex(x*a, y*a)
  }
  
  /// `self` unscaled by `a`.
  @usableFromInline @_transparent
  internal func divided(by a: RealType) -> Complex {
    // See implementation notes for `multiplied` above.
    Complex(x/a, y/a)
  }
}
