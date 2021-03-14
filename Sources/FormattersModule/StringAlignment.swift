//===--- StringAlignment.swift --------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension String {
  /// Specify the alignment of  a string, for machine-formatting purposes
  ///
  /// The output of alignment is not meant for end-user consumption, use a
  /// locale-rich formatter for that. This is meant for machine and programmer
  /// use (e.g. log files, textual formats, or anywhere `printf` is used).
  ///
  /// NOTE: One `Character` is currently considered one column, though they
  /// may commonly be printed out differently. What is considered one or
  /// two columns is application-specific. The Unicode standard does not dictate this.
  ///
  /// TODO: We can consider adding a half-sensible approximation function,
  /// or even use a user-supplied function here.
  public struct Alignment: Hashable {
    /// The minimum number of characters
    public var minimumColumnWidth: Int

    /// Where to align
    public var anchor: CollectionBound

    /// The Character to use to reach `minimumColumnWidth`
    public var fill: Character

    public init(
      minimumColumnWidth: Int = 0,
      anchor: CollectionBound = .end,
      fill: Character = " "
    ) {
      self.minimumColumnWidth = minimumColumnWidth
      self.anchor = anchor
      self.fill = fill
    }

    /// Specify a right-aligned string.
    public static var right: Alignment { Alignment(anchor: .end) }

    /// Specify a left-aligned string.
    public static var left: Alignment { Alignment(anchor: .start) }

    /// No aligment requirements
    public static var none: Alignment { .right  }

    /// Specify a right-aligned string.
    public static func right(
      columns: Int = 0, fill: Character = " "
    ) -> Alignment {
      Alignment.right.columns(columns).fill(fill)
    }
    /// Specify a left-aligned string.
    public static func left(
      columns: Int = 0, fill: Character = " "
    ) -> Alignment {
      Alignment.left.columns(columns).fill(fill)
    }

    /// Specify the minimum number of columns.
    public func columns(_ i: Int) -> Alignment {
      var result = self
      result.minimumColumnWidth = i
      return result
    }

    public func fill(_ c: Character) -> Alignment {
      var result = self
      result.fill = c
      return result
    }
  }
}

extension StringProtocol {
  /// Align `self`, according to `align`.
  public func aligned(_ align: String.Alignment) -> String {
    var copy = String(self)
    copy.pad(to: align.minimumColumnWidth, using: align.fill, at: align.anchor.inverted)
    return copy
  }

  /// Indent `self` by `columns`, using `fill` (default space).
  public func indented(_ columns: Int, fill: Character = " ") -> String {
    String(repeating: fill, count: columns) + self
  }
}
