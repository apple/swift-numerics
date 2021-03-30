//===--- Formatting.swift -------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// Specify separators to insert during formatting.
public struct SeparatorFormatting: Hashable {
  /// The separator character to use.
  public var separator: Character?

  /// The spacing between separators.
  public var spacing: Int

  public init(separator: Character? = nil, spacing: Int = 3) {
    self.separator = separator
    self.spacing = spacing
  }

  // TODO: Consider modeling `none` as `nil` separator formatting...

  /// No separators.
  public static var none: SeparatorFormatting {
    SeparatorFormatting()
  }

  /// Insert `separator` every `n`characters.
  public static func every(
    _ n: Int, separator: Character
  ) -> SeparatorFormatting {
    SeparatorFormatting(separator: separator, spacing: n)
  }

  /// Insert `separator` every thousands.
  public static func thousands(separator: Character) -> SeparatorFormatting {
    .every(3, separator: separator)
  }
}

public protocol FixedWidthIntegerFormatter {
  func format<I: FixedWidthInteger, OS: TextOutputStream>(_: I, into: inout OS)
}
extension FixedWidthIntegerFormatter {
  public func format<I: FixedWidthInteger>(_ x: I) -> String {
    var result = ""
    self.format(x, into: &result)
    return result
  }
}
