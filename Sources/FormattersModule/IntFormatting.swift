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

extension IntegerFormatting {

  // Returns a fprintf-compatible length modifier for a given argument type
  private static func _formatStringLengthModifier<I: FixedWidthInteger>(
    _ type: I.Type
  ) -> String? {
    // IEEE Std 1003.1-2017, length modifiers:

    switch type {
    //   hh - d, i, o, u, x, or X conversion specifier applies to (signed|unsigned) char
    case is CChar.Type: return "hh"
    case is CUnsignedChar.Type: return "hh"

    //   h  - d, i, o, u, x, or X conversion specifier applies to (signed|unsigned) short
    case is CShort.Type: return "h"
    case is CUnsignedShort.Type: return "h"

    case is CInt.Type: return ""
    case is CUnsignedInt.Type: return ""

    //   l  - d, i, o, u, x, or X conversion specifier applies to (signed|unsigned) long
    case is CLong.Type: return "l"
    case is CUnsignedLong.Type: return "l"

    //   ll - d, i, o, u, x, or X conversion specifier applies to (signed|unsigned) long long
    case is CLongLong.Type: return "ll"
    case is CUnsignedLongLong.Type: return "ll"

    default: return nil
    }
  }

  // TODO: Are we making these public yet?
  public func toFormatString<I: FixedWidthInteger>(
    _ align: String.Alignment = .none, for type: I.Type
  ) -> String? {
    // Based on IEEE Std 1003.1-2017

    // No separators supported
    guard separator == SeparatorFormatting.none else { return nil }

    // `d`/`i` is the only signed integral conversions allowed
    guard !type.isSigned || radix == 10 else { return nil }

    // IEEE: Each conversion specification is introduced by the '%' character
    // after which the following appear in sequence:
    //   1. Zero or more flags (in any order), which modify the meaning of
    //      the conversion specification.
    //   2. An optional minimum field width. If the converted value has fewer
    //      bytes than the field width, it shall be padded with <space>
    //      characters by default on the left; it shall be padded on the right
    //      if the left-adjustment flag ( '-' ), is given to the field width.
    //   3. An optional precision that gives the minimum number of digits to
    //      appear for the d, i, o, u, x, and X conversion specifiers ...
    //   4. An optional length modifier that specifies the size of the argument.
    //   5. A conversion specifier character that indicates the type of
    //      conversion to be applied.

    // Use Swift style prefixes rather than fprintf style prefixes
    var specification = "\(_prefix)%"

    //
    // 1. Flags
    //

    // Use `+` flag if signed, otherwise prefix a literal `+` for unsigned
    if explicitPositiveSign {
      // IEEE: `+` The result of a signed conversion shall always begin with a sign ( '+' or '-' )
      if type.isSigned {
        specification += "+"
      } else {
        specification.insert("+", at: specification.startIndex)
      }
    }

    // IEEE: `-` The result of the conversion shall be left-justified within the field. The
    //       conversion is right-justified if this flag is not specified.
    if align.anchor == .start {
      specification += "-"
    }

    // 2. Minimumn field width

    // Padding has to be space
    guard align.fill == " " else {
      // IEEE: `0` Leading zeros (following any indication of sign or base) are used to pad to
      //       the field width rather than performing space padding. If the '0' and '-' flags
      //       both appear, the '0' flag is ignored. If a precision is specified, the '0' flag
      //       shall be ignored.
      //
      // Commentary: `0` is when the user doesn't want to use precision (minDigits). This allows
      //             sign and prefix characters to be counted towards field width (they wouldn't be
      //             counted towards precision). This is more useful for floats, where precision is
      //             digits after the radix. We're already handling prefix ourselves; we choose not
      //             to support this functionality.
      //
      // TODO: consider providing a static function to emulate the behavior... (not everything).
      return nil
    }

    if align.minimumColumnWidth > 0 {
      specification += "\(align.minimumColumnWidth)"
    }

    // 3. Precision

    // Default precision for integers is 1, otherwise use the requested precision
    if minDigits != 1 {
      specification += ".\(minDigits)"
    }

    // 4. Length modifier
    guard let lengthMod = IntegerFormatting._formatStringLengthModifier(type) else { return nil }
    specification += lengthMod

    // 5. The conversion specifier
    switch radix {
    case 10:
      specification += "d"
    case 8:
      specification += "o"
    case 16:
      specification += uppercase ? "X" : "x"
    default: return nil
    }

    return specification
  }
}
