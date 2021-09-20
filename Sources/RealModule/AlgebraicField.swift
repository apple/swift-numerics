//===--- AlgebraicField.swift ---------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// A type modeling an algebraic [field]. Refines the `SignedNumeric` protocol,
/// adding division.
///
/// A field is a set on which addition, subtraction, multiplication, and
/// division are defined, and behave basically like those operations on
/// the real numbers. More precisely, a field is a commutative group under
/// its addition, the non-zero elements of the field form a commutative
/// group under its multiplication, and the distributive law holds.
///
/// Some common examples of fields include:
///
/// - the rational numbers
/// - the real numbers
/// - the complex numbers
/// - the integers modulo a prime
///
/// The most familiar example of a thing that is *not* a field is the integers.
/// This may be surprising, since integers seem to have addition, subtraction,
/// multiplication and division. Why don't they form a field?
///
/// Because integer multiplication does not form a group; it's commutative and
/// associative, but integers do not have multiplicative inverses.
/// I.e. if a is any integer other than 1 or -1, there is no integer b such
/// that a*b = 1. The existence of inverses is requried to form a field.
///
/// If a type `T` conforms to the `Real` protocol, then `T` and `Complex<T>`
/// both conform to `AlgebraicField`.
///
/// See Also:
/// -
/// - Real
/// - SignedNumeric
/// - Numeric
/// - AdditiveArithmetic
///
/// [field]: https://en.wikipedia.org/wiki/Field_(mathematics)
public protocol AlgebraicField: SignedNumeric {
  
  /// Replaces a with the (approximate) quotient `a/b`.
  static func /=(a: inout Self, b: Self)
  
  /// The (approximate) quotient `a/b`.
  static func /(a: Self, b: Self) -> Self
  
  /// The (approximate) reciprocal (multiplicative inverse) of this number,
  /// if it is representable.
  ///
  /// If reciprocal is non-nil, you can replace division by self with
  /// multiplication by reciprocal and either get exact the same result
  /// (for finite fields) or approximately the same result up to a typical
  /// rounding error (for floating-point formats).
  ///
  /// If self is zero and the type has no representation for infinity (as
  /// in a typical finite field implementation), or if a reciprocal would
  /// overflow or underflow such that it cannot be accurately represented,
  /// the result is nil.
  ///
  /// Note that `.zero.reciprocal`, somewhat surprisingly, is *not* nil
  /// for `Real` or `Complex` types, because these types have an
  /// `.infinity` value that acts as the reciprocal of `.zero`.
  ///
  /// If `b.reciprocal` is non-nil, you may be able to replace division by `b`
  /// with multiplication by this value. It is not advantageous to do this
  /// for an isolated division unless it is a compile-time constant visible
  /// to the compiler, but if you are dividing many values by a single
  /// denominator, this will often be a significant performance win.
  ///
  /// Note that this will slightly perturb results for fields with approximate
  /// arithmetic, such as real or complex types--using a normal division
  /// is generally more accurate--but no catastrophic loss of accuracy will
  /// result. For fields with exact arithmetic, the results are necessarily
  /// identical.
  ///
  /// A typical use case looks something like this:
  /// ```
  /// func divide<T: AlgebraicField>(data: [T], by divisor: T) -> [T] {
  ///   // If divisor is well-scaled, multiply by reciprocal.
  ///   if let recip = divisor.reciprocal {
  ///     return data.map { $0 * recip }
  ///   }
  ///   // Fallback on using division.
  ///   return data.map { $0 / divisor }
  /// }
  /// ```
  var reciprocal: Self? { get }
}

extension AlgebraicField {
  @_transparent
  public static func /(a: Self, b: Self) -> Self {
    var result = a
    result /= b
    return result
  }
  
  /// Implementations should be *conservative* with the reciprocal property;
  /// it is OK to return `nil` even in cases where a reciprocal could be
  /// represented. For this reason, a default implementation that simply
  /// always returns `nil` is correct, but conforming types should provide
  /// a better implementation if possible.
  public var reciprocal: Self? {
    return nil
  }
}
