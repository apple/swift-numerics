//===--- IntFormatting.swift ----------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// Specifies how an integer should be formatted.
///
/// The output of alignment is not meant for end-user consumption, use a
/// locale-rich formatter for that. This is meant for machine and programmer
/// use (e.g. log files, textual formats, or anywhere `printf` is used).
public struct IntegerFormatting: Hashable {
  /// The base to use for the string representation. `radix` must be at least 2 and at most 36.
  /// The default is 10.
  public var radix: Int

  /// Explicitly print a positive sign.TODO
  public var explicitPositiveSign: Bool

  /// Include the integer literal prefix for binary, octal, or hexadecimal bases.
  public var includePrefix: Bool

  /// Whether to use uppercase letters to represent numerals
  /// greater than 9 (default is to use lowercase)
  public var uppercase: Bool

  /// TODO: docs
  public var minDigits: Int

  /// The separator formatting options to use.
  public var separator: SeparatorFormatting

  public init(
    radix: Int = 10,
    explicitPositiveSign: Bool = false,
    includePrefix: Bool = true,
    uppercase: Bool = false,
    minDigits: Int = 1,
    separator: SeparatorFormatting = .none
  ) {
    precondition(radix >= 2 && radix <= 36)

    self.radix = radix
    self.explicitPositiveSign = explicitPositiveSign
    self.includePrefix = includePrefix
    self.uppercase = uppercase
    self.minDigits = minDigits
    self.separator = separator
  }

  /// Format as a decimal integer.
  public static func decimal(
    explicitPositiveSign: Bool = false,
    minDigits: Int = 1,
    separator: SeparatorFormatting = .none
  ) -> IntegerFormatting {
    return IntegerFormatting(
      radix: 10,
      explicitPositiveSign: explicitPositiveSign,
      minDigits: minDigits,
      separator: separator)
  }

  /// Format as a decimal integer.
  public static var decimal: IntegerFormatting { .decimal() }

  /// Format as a hexadecimal integer.
  public static func hex(
    explicitPositiveSign: Bool = false,
    includePrefix: Bool = true,
    uppercase: Bool = false,
    minDigits: Int = 1,
    separator: SeparatorFormatting = .none
  ) -> IntegerFormatting {
    return IntegerFormatting(
      radix: 16,
      explicitPositiveSign: explicitPositiveSign,
      includePrefix: includePrefix,
      uppercase: uppercase,
      minDigits: minDigits,
      separator: separator)
  }

  /// Format as a hexadecimal integer.
  public static var hex: IntegerFormatting { .hex() }

  /// Format as an octal integer.
  public static func octal(
    explicitPositiveSign: Bool = false,
    includePrefix: Bool = true,
    uppercase: Bool = false,
    minDigits: Int = 1,  // TODO: document if prefix is zero!
    separator: SeparatorFormatting = .none
  ) -> IntegerFormatting {
    IntegerFormatting(
      radix: 8,
      explicitPositiveSign: explicitPositiveSign,
      includePrefix: includePrefix,
      uppercase: uppercase,
      minDigits: minDigits,
      separator: separator)
  }

  /// Format as an octal integer.
  public static var octal: IntegerFormatting { .octal() }

  /// TODO: binary

}

extension IntegerFormatting {
  // On Prefixes
  //
  // `fprintf` has oddball prefix behaviors.
  //   * We want signed and unsigned prefixes (former cannot be easily emulated)
  //   * The precision-adjusting octal prefix won't be missed.
  //     * Nor the special case for minDigits == 0
  //   * We want a hexadecimal prefix to be printed if requested, even for
  //     the value 0.
  //   * We don't want to conflate prefix capitalization with hex-digit
  //     capitalization.
  //   * A binary prefix for radix 2 is nice to have
  //
  // Instead, we go with Swift literal syntax. If a prefix is requested,
  // and radix is:
  //   2: "0b1010"
  //   8: "0o1234"
  //  16: "0x89ab"
  //
  // This can be sensibly emulated using `fprintf` for unsigned types by just
  // adding it before the specifier.
  fileprivate var _prefix: String {
    guard includePrefix else { return "" }
    switch radix {
    case 2: return "0b"
    case 8: return "0o"
    case 16: return "0x"
    default: return ""
    }
  }
}

extension IntegerFormatting: FixedWidthIntegerFormatter {
  public func format<I: FixedWidthInteger, OS: TextOutputStream>(
    _ i: I, into os: inout OS
  ) {
    if i == 0 && self.minDigits == 0 {
      return
    }

    // Sign
    if I.isSigned {
      if i < 0 {
        os.write("-")
      } else if self.explicitPositiveSign {
        os.write("+")
      }
    }

    // Prefix
    os.write(self._prefix)

    // Digits
    let number = String(
      i.magnitude, radix: self.radix, uppercase: self.uppercase
    ).aligned(.right(columns: self.minDigits, fill: "0"))
    if let separator = self.separator.separator {
      var num = number
      num.intersperse(
        separator, every: self.separator.spacing, startingFrom: .end)
      os.write(num)
    } else {
      os.write(number)
    }
  }
}
