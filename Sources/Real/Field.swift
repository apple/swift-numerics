//===--- Field.swift ------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// TODO: refining Numeric is slightly annoying because Numeric has the
// magnitude property and associated type, which doesn't quite make sense
// for all fields. However, simply picking magnitude = self in those cases
// is probably a sensible workaround, so this isn't catastrophic. Still,
// slightly annoying.

/// A type modeling an algebraic field.
///
/// This protocol refines `Numeric`, adding division and reciprocal operations.
public protocol Field: Numeric {
  
  static func /=(a: inout Self, b: Self)
  
  static func /(a: Self, b: Self) -> Self
  
  /// The (approximate) reciprocal (mulitplicative inverse) of this number, if one is representable.
  ///
  /// If reciprocal is non-nil, you can replace division by self with multiplication by reciprocal and
  /// either get exact the same result (for finite fields) or approximately the same result up to a
  /// typical rounding error (for floating-point formats).
  ///
  /// If self is zero, or if a reciprocal would overflow or underflow such that it cannot be accurately
  /// represented, the result is nil. Implementations should be *conservative*; it is OK to return
  /// nil even in some cases where a reciprocal can be represented. For this reason, a default
  /// implementation that simply always returns nil is provided.
  var reciprocal: Self? { get }
}

extension Field {
  @_transparent
  public static func /(a: Self, b: Self) -> Self {
    var result = a
    result /= b
    return result
  }
  
  public var reciprocal: Self? {
    return nil
  }
}
