//===--- FloatFormatting.swift --------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 - 2020 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//


/// Specifies how a float should be formatted.
///
/// The output of alignment is not meant for end-user consumption, use a
/// locale-rich formatter for that. This is meant for machine and programmer
/// use (e.g. log files, textual formats, or anywhere `printf` is used).
public struct FloatFormatting: Hashable {
  // NOTE: fprintf will read from C locale. Swift print uses dot.
  // We could consider a global var for the c locale's character.

  /// The radix character to use.
  public var radixPoint: Character

  /// Whether the include an explicit positive sign, if positive.
  public var explicitPositiveSign: Bool

  /// Whether to use uppercase (TODO: hex and/or exponent characters?)
  public var uppercase: Bool

  // Note: no includePrefix for FloatFormatting; it doesn't exist for
  // fprintf (%a always prints a prefix, %efg don't need one), so why
  // introduce it here.

  public enum Notation: Hashable {
    /// Swift's String(floating-point) formatting.
    case decimal

    /// Hexadecimal formatting. Only permitted for BinaryFloatingPoint types.
    case hex

    /// Prints all digits before the radix point, and `precision` digits following
    /// the radix point. If `precision` is zero, the radix point is omitted.
    ///
    /// Note that very large floating-point values may print quite a lot of digits
    /// when using this format, even if `precision` is zero--up to hundreds for
    /// `Double`, and thousands for `Float80`. Note also that this format is
    /// very likely to print non-zero values as all-zero. If either of these is a concern
    /// for your use, consider using `.optimal` or `.hybrid` instead.
    ///
    /// Systems may impose an upper bound on the number of digits that are
    /// supported following the radix point.
    ///
    /// This corresponds to C's `%f` formatting used with `fprintf`.
    case fixed(precision: Int32 = 6)

    /// Prints the number in the form [-]d.ddd...dde±dd, with `precision` significant
    /// digits following the radix point. Systems may impose an upper bound on the number
    /// of digits that are supported.
    ///
    /// This corresponds to C's `%e` formatting used with `fprintf`.
    case exponential(precision: Int32 = 6)

    /// Behaves like `.fixed` when the number is scaled close to 1.0, and like
    /// `.exponential` if it has a very large or small exponent.
    ///
    /// The corresponds to C's `%g` formatting used with `fprintf`.
    case hybrid(precision: Int32 = 6)
  }

  /// The notation to use. Swift's default formatting behavior corresponds to `.decimal`.
  public var notation: Notation

  /// The separator formatting options to use.
  public var separator: SeparatorFormatting

  public init(
    radixPoint: Character = ".",
    explicitPositiveSign: Bool = false,
    uppercase: Bool = false,
    notation: Notation = .decimal,
    separator: SeparatorFormatting = .none
  ) {
    self.radixPoint = radixPoint
    self.explicitPositiveSign = explicitPositiveSign
    self.uppercase = uppercase
    self.notation = notation
    self.separator = separator
  }

  /// Format as a decimal (Swift's default printing format).
  public static var decimal: FloatFormatting { .decimal() }

  /// Format as a decimal (Swift's default printing format).
  public static func decimal(
    radixPoint: Character = ".",
    explicitPositiveSign: Bool = false,
    uppercase: Bool = false,
    separator: SeparatorFormatting = .none
  ) -> FloatFormatting {
    return FloatFormatting(
      radixPoint: radixPoint,
      explicitPositiveSign: explicitPositiveSign,
      uppercase: uppercase,
      notation: .decimal,
      separator: separator
    )
  }

  /// Format as a hex float.
  public static var hex: FloatFormatting { .hex() }

  /// Format as a hex float.
  public static func hex(
    radixPoint: Character = ".",
    explicitPositiveSign: Bool = false,
    uppercase: Bool = false,
    separator: SeparatorFormatting = .none
  ) -> FloatFormatting {
    return FloatFormatting(
      radixPoint: radixPoint,
      explicitPositiveSign: explicitPositiveSign,
      uppercase: uppercase,
      notation: .hex,
      separator: separator
    )
  }
}

extension FloatFormatting {
  // Returns a fprintf-compatible length modifier for a given argument type
  private static func _formatStringLengthModifier<I: FloatingPoint>(
    _ type: I.Type
  ) -> String? {
    switch type {
    //   fprintf formatters promote Float to Double
    case is Float.Type: return ""
    case is Double.Type: return ""
    //   fprintf formatters use L for Float80
    case is Float80.Type: return "L"
    default: return nil
    }
  }

  // TODO: Are we making these public yet?
  public func toFormatString<I: FloatingPoint>(
    _ align: String.Alignment = .none, for type: I.Type
  ) -> String? {

    // No separators supported
    guard separator == SeparatorFormatting.none else { return nil }

    // Radix character simply comes from C locale, so require it be
    // default.
    guard radixPoint == "." else { return nil }

    // Make sure this is a type that fprintf supports.
    guard let lengthMod = FloatFormatting._formatStringLengthModifier(type) else { return nil }

    var specification = "%"

    // 1. Flags
    // IEEE: `+` The result of a signed conversion shall always begin with a sign ( '+' or '-' )
    if explicitPositiveSign {
      specification += "+"
    }

    // IEEE: `-` The result of the conversion shall be left-justified within the field. The
    //       conversion is right-justified if this flag is not specified.
    if align.anchor == .start {
      specification += "-"
    }

    // Padding has to be space
    guard align.fill == " " else {
      return nil
    }

    if align.minimumColumnWidth > 0 {
      specification += "\(align.minimumColumnWidth)"
    }

    // 3. Precision and conversion specifier.
    switch notation {
    case let .fixed(p):
      specification += "\(p)" + lengthMod + (uppercase ? "F" : "f")
    case let .exponential(p):
      specification += "\(p)" + lengthMod + (uppercase ? "E" : "e")
    case let .hybrid(p):
      specification += "\(p)" + lengthMod + (uppercase ? "G" : "g")
    case .hex:
      guard type.radix == 2 else { return nil }
      specification += lengthMod + (uppercase ? "A" : "a")
    default:
      return nil
    }

    return specification
  }
}
