//===--- InitFromBinaryFloatingPoint754.swift -----------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import Foundation
@testable import BigIntModule

// MARK: - Assertions

/// BigInt(🐰)
private func assertBigInt<T: BinaryFloatingPoint>(_ d: T,
                                                  _ expected: BigInt,
                                                  _ message: String? = nil,
                                                  file: StaticString,
                                                  line: UInt) {
  let result = BigInt(d)
  let message = message.map { ": \($0)" } ?? ""
  XCTAssertEqual(result,
                 expected,
                 "BigInt(\(d))\(message)",
                 file: file,
                 line: line)
}

/// BigInt(exactly: 🐰)
private func assertExactlyBigInt<T: BinaryFloatingPoint>(_ d: T,
                                                         _ expected: BigInt,
                                                         _ message: String? = nil,
                                                         file: StaticString,
                                                         line: UInt) {
  let result = BigInt(exactly: d)
  let message = message.map { ": \($0)" } ?? ""
  XCTAssertEqual(result,
                 expected,
                 "BigInt(exactly: \(d))\(message)",
                 file: file,
                 line: line)
}

/// BigInt(exactly: 🐰) == nil
private func assertExactlyBigIntIsNil<T: BinaryFloatingPoint>(_ d: T,
                                                              _ message: String? = nil,
                                                              file: StaticString,
                                                              line: UInt) {
  let result = BigInt(exactly: d)
  let message = message.map { ": \($0)" } ?? ""
  XCTAssertNil(result,
               "BigInt(exactly: \(d))\(message)",
               file: file,
               line: line)
}

// MARK: - Data

private let signs: [FloatingPointSign] = [.plus, .minus]

// MARK: - Tests

/// Based on 'IEEE-754 2008 Floating point specification'.
/// Binary part; no decimals; no TensorFloat-32; no unums/posits.
/// 2019 is also available, but I'm poor… 🤷.
final class InitFromBinaryFloatingPoint754: XCTestCase {

  // MARK: - Zero, infinity, Batman, subnormal

  // F | Exponent | Result
  // --+----------+------------------
  // 0 | 0        | Signed 0
  // _ | 0        | Subnormal numbers
  // 0 | all 1    | Infinity
  // _ | all 1    | NaNs
  //
  // * Fractional part of the significand

  func test_zero() {
    func test<T: BinaryFloatingPoint>(type: T.Type,
                                      file: StaticString = #file,
                                      line: UInt = #line) {
      let zeros = [+T.zero, -T.zero]
      let expected = BigInt()

      for zero in zeros {
        assertBigInt(zero, expected, file: file, line: line)
        assertExactlyBigInt(zero, expected, file: file, line: line)

        let up = zero.nextUp
        assert(up.isSubnormal)
        assertBigInt(up, expected, file: file, line: line)
        assertExactlyBigIntIsNil(up, file: file, line: line)

        let down = zero.nextDown
        assert(down.isSubnormal)
        assertBigInt(down, expected, file: file, line: line)
        assertExactlyBigIntIsNil(down, file: file, line: line)
      }

      let half = T(1) / T(2)
      assertBigInt(+half, expected, file: file, line: line)
      assertBigInt(-half, expected, file: file, line: line)
      assertExactlyBigIntIsNil(+half, file: file, line: line)
      assertExactlyBigIntIsNil(-half, file: file, line: line)
    }

    test(type: Float.self)
    test(type: Double.self)
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    test(type: Float80.self)
#endif
  }

  func test_infinity() {
    func test<T: BinaryFloatingPoint>(type: T.Type,
                                      file: StaticString = #file,
                                      line: UInt = #line) {
      // BigInt(plus) will crash
      let plus = +T.infinity
      assertExactlyBigIntIsNil(plus, file: file, line: line)

      // BigInt(minus) will crash
      let minus = -T.infinity
      assertExactlyBigIntIsNil(minus, file: file, line: line)
    }

    test(type: Float.self)
    test(type: Double.self)
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    test(type: Float80.self)
#endif
  }

  // https://www.youtube.com/watch?v=EtoMN_xi-AM
  func test_nanana_Batman() {
    // There is a catch in this:
    // The IEEE-754 2008 -> '6.2.1 NaN encodings in binary formats' specifies the
    // proper encoding, but AFAIK it is not enforced and may be platform dependent
    // (because in IEEE-754 1985 it was 'left to the implementor’s discretion').
    // This is why we will use Swift.Float.nan and not construct it by hand.
    //
    // DO NOT use high 'significand' bits for payload! This is where encoding
    // should be if we are fully IEEE-754 2008 compliant.

    func addPayload<T: BinaryFloatingPoint>(_ nan: T, payload: T.RawSignificand) -> T {
      assert(nan.isNaN)
      return T(
        sign: nan.sign,
        exponentBitPattern: nan.exponentBitPattern,
        significandBitPattern: nan.significandBitPattern | payload
      )
    }

    func test<T: BinaryFloatingPoint>(type: T.Type,
                                      file: StaticString = #file,
                                      line: UInt = #line) {
      // BigInt(qNaN) will crash
      let qNaN = T.nan
      let qNaNPayload = addPayload(qNaN, payload: 101)
      assertExactlyBigIntIsNil(qNaN, file: file, line: line)
      assertExactlyBigIntIsNil(qNaNPayload, file: file, line: line)

      // BigInt(sNaN) will crash
      let sNaN = T.signalingNaN
      let sNaNPayload = addPayload(sNaN, payload: 101)
      assertExactlyBigIntIsNil(sNaN, file: file, line: line)
      assertExactlyBigIntIsNil(sNaNPayload, file: file, line: line)
    }

    test(type: Float.self)
    test(type: Double.self)
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    test(type: Float80.self)
#endif
  }

  func test_subnormal() {
    func test<T: BinaryFloatingPoint>(type: T.Type,
                                      file: StaticString = #file,
                                      line: UInt = #line) {
      let zero = BigInt()
      // Remember that significand = 0 is reserved for '0'!
      let significands = [
        1,
        T.RawSignificand(1) << (T.significandBitCount / 2),
        T.significandAll1
      ]

      for (sign, significand) in CartesianProduct(signs, significands) {
        let d = T(sign: sign, exponentBitPattern: 0, significandBitPattern: significand)
        assert(d.isSubnormal)

        // Check if Swift works as expected
        assert(Int(d) == 0)
        assert(Int(exactly: d) == nil)

        let message = "\(sign), significand: \(significand)"
        assertBigInt(d, zero, message, file: file, line: line)
        assertExactlyBigIntIsNil(d, message, file: file, line: line)
      }
    }

    test(type: Float.self)
    test(type: Double.self)
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    test(type: Float80.self)
#endif
  }

  // MARK: - Normal

  struct PredefinedTestCase<T: BinaryFloatingPoint> {
    let name: String
    let value: T
    let expected: BigInt
    let exactly: BigInt?
  }

  func test_predefinedCases() {
    typealias TC = PredefinedTestCase

    func test<T: BinaryFloatingPoint>(type: T.Type,
                                      file: StaticString = #file,
                                      line: UInt = #line) {
      let gfmUnpack = Unpack(T.greatestFiniteMagnitude)
      assert(gfmUnpack.isInteger)
      let gfm = gfmUnpack.whole

      let testCases = [
        TC(name: "+π", value: +T.pi, expected: +3, exactly: nil),
        TC(name: "-π", value: -T.pi, expected: -3, exactly: nil),
        TC(name: "+ulpOfOne", value: +T.ulpOfOne, expected: 0, exactly: nil),
        TC(name: "-ulpOfOne", value: -T.ulpOfOne, expected: 0, exactly: nil),
        TC(name: "+leastNonzeroMagnitude", value: +T.leastNonzeroMagnitude, expected: 0, exactly: nil),
        TC(name: "-leastNonzeroMagnitude", value: -T.leastNonzeroMagnitude, expected: 0, exactly: nil),
        TC(name: "+leastNormalMagnitude", value: +T.leastNormalMagnitude, expected: 0, exactly: nil),
        TC(name: "-leastNormalMagnitude", value: -T.leastNormalMagnitude, expected: 0, exactly: nil),
        TC(name: "+greatestFiniteMagnitude", value: +T.greatestFiniteMagnitude, expected: +gfm, exactly: +gfm),
        TC(name: "-greatestFiniteMagnitude", value: -T.greatestFiniteMagnitude, expected: -gfm, exactly: -gfm),
      ]

      for testCase in testCases {
        let d = testCase.value
        let message = testCase.name

        assertBigInt(d, testCase.expected, message, file: file, line: line)

        if let exactly = testCase.exactly {
          assertExactlyBigInt(d, exactly, message, file: file, line: line)
        } else {
          assertExactlyBigIntIsNil(d, message, file: file, line: line)
        }
      }
    }

    test(type: Float.self)
    test(type: Double.self)
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    test(type: Float80.self)
#endif
  }

  // MARK: - Normal - unpack

  /// Destruct normal (non 0) floating point number into `BigInt`.
  ///
  /// `7.0/3.0 = 2⅓` will be encoded as:
  /// - whole: `2`
  /// - fractionNumerator:   `1501199875790166`
  /// - fractionDenominator: `4503599627370496`
  ///
  /// Note that: `1501199875790166/4503599627370496 = 0.333333333333 ≈ ⅓`.
  ///
  /// `T` is a phantom type that denotes the precision.
  struct Unpack<T: BinaryFloatingPoint> {

    let whole: BigInt
    let fractionNumerator: BigInt
    let fractionDenominator: BigInt

    var isInteger: Bool {
      return self.fractionNumerator == 0
    }

    init(_ d: T) {
      assert(d.isFinite && !d.isSubnormal)

      // Significand is encoded as 1.significandBitPattern:
      // - '1' is implicit and does not exist in 'significandBitPattern'
      //   (except for Float80, but whatever…)
      // - 'significandBitPattern' represents a fraction of 'significandDenominator'
      let significandDenominator = BigInt(1) << T.significandBitCount
      let significandRestored1 = significandDenominator
      let significandFraction = BigInt(d.significandBitPattern)
      let significand = significandRestored1 | significandFraction

      // Proper equation is:
      // value = (-1 ** sign) * 1.significandBitPattern * (2 ** exponent) =
      //       = (-1 ** sign) * significand/significandDenominator * (2 ** exponent) =
      //       = (-1 ** sign) * (significand << exponent) / significandDenominator
      //
      // 'numerator' calculation is prone to overflow.
      // If only we had an 'Int' representation that does not overflow…
      let sign: BigInt = d.sign == .plus ? 1 : -1
      let numerator = sign * (significand << d.exponent)
      let (q, r) = numerator.quotientAndRemainder(dividingBy: significandDenominator)

      self.whole = q
      self.fractionNumerator = r
      self.fractionDenominator = significandDenominator
    }
  }

  /// Produce elements according to `element = previousElement * K`.
  ///
  /// `K` is chosen, so that the whole `range` is filled (which means that `K>1`).
  /// Obviously, this means that the spacing between elements will gradually increase.
  struct GeometricSample<T: BinaryFloatingPoint>: Sequence {

    let lowerBound: T
    let upperBound: T
    let count: Int
    private let K: T

    init(lowerBound: T, upperBound: T, count: Int) {
      assert(upperBound > lowerBound)
      assert(!lowerBound.isZero, "Geometric series starting with 0?")
      self.lowerBound = lowerBound
      self.upperBound = upperBound
      self.count = count

      // lowerBound * K*K*…*K ≈ upperBound ->
      // lowerBound * (K**count) ≈ upperBound ->
      // K**count ≈ upperBound/lowerBound ->
      // K ≈ count√(upperBound/lowerBound)
      let span = upperBound / lowerBound
      let root = T(1) / T(count)
      self.K = Self.pow(span, root)
      assert(self.K > 1)
    }

    private static func pow<T: BinaryFloatingPoint>(_ d: T, _ p: T) -> T {
      if (T.self == Float.self) { return Foundation.pow(d as! Float, p as! Float) as! T }
      if (T.self == Double.self) { return Foundation.pow(d as! Double, p as! Double) as! T }
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
      if (T.self == Float80.self) { return Foundation.pow(d as! Float80, p as! Float80) as! T }
#endif
      fatalError("You used 'pow' on \(T.self). It is not very effective.")
    }

    func makeIterator() -> AnyIterator<T> {
      var index = 0

      return AnyIterator {
        if index == count {
          return nil
        }

        // Using 'pow' has better precision than multiplying the previous element.
        let element = self.lowerBound * Self.pow(self.K, T(index))
        index += 1

        let isLast = !element.isFinite || element > self.upperBound
        return isLast ? upperBound : element
      }
    }
  }

  func test_unpack() {
    func test<T: BinaryFloatingPoint>(type: T.Type,
                                      file: StaticString = #file,
                                      line: UInt = #line) {
      let samples = GeometricSample(
        lowerBound: T(1),
        upperBound: T.greatestFiniteMagnitude,
        count: 2_000
      )

      for d in samples {
        let unpack = Unpack(d)
        assertBigInt(+d, +unpack.whole, file: file, line: line)
        assertBigInt(-d, -unpack.whole, file: file, line: line)

        if unpack.isInteger {
          assertExactlyBigInt(+d, +unpack.whole, file: file, line: line)
          assertExactlyBigInt(-d, -unpack.whole, file: file, line: line)
        } else {
          assertExactlyBigIntIsNil(+d, file: file, line: line)
          assertExactlyBigIntIsNil(-d, file: file, line: line)
        }
      }
    }

    test(type: Float.self)
    test(type: Double.self)
#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    test(type: Float80.self)
#endif
  }

  // MARK: - Normal - spacing

  // === IEEE_754_SPACING_NOTE ===
  // The spacing of the numbers in the range from [2**n, 2**(n+1)) is 2**(n−F)
  // where F = significand bit width without the implicit 1
  //           (for Float80 it is an explicit 1, but whatever…).
  //
  // Example for Double (significand has 52 bits explicitly stored):
  // - 2**51 to 2**52 - spacing = 1/2
  // - 2**52 to 2**53 - spacing = 1; exactly integers
  // - 2**53 to 2**54 - spacing = 2; everything is multiplied by 2 -> only even numbers

  /// Equally spaced samples over all of the positive integers with a given
  /// `exponent` exactly representable by a given `T`.
  ///
  /// We start from `lowerBound = 2**exponent` and produce values according to
  /// `lowerBound + N * spacing` formula. `N` is calculated, so that the samples
  /// are spread evenly across the whole range.
  ///
  /// Please read IEEE_754_SPACING_NOTE above.
  struct SampleExactlyRepresentableIntegers<T: BinaryFloatingPoint>: Sequence {

    struct Element {
      private let n: BigInt
      private let d: T

      init(_ n: BigInt, _ d: T) {
        self.n = n
        self.d = d
      }

      func withSign(_ sign: FloatingPointSign) -> (n: BigInt, d: T) {
        switch sign {
        case .plus:  return (+self.n, +self.d)
        case .minus: return (-self.n, -self.d)
        }
      }
    }

    /// Distance between exactly representable integers for a given `T` and `exponent`.
    /// If 'exponent < T.significandBitCount' then 'spacing = 1'.
    let spacing: BigInt
    /// Sample lower bound (included in result).
    let lowerBound: BigInt
    /// Sample upper bound (excluded in result).
    let upperBound: BigInt
    /// Number of produced samples.
    let count: BigInt
    /// Distance between each sample.
    private let sampleInterval: BigInt

    // Equation from a IEEE_754_SPACING_NOTE (see above).
    // Will round <1 spacing to 1.
    static func calculateSpacing(exponent: Int) -> BigInt {
      let F = T.significandBitCount
      return Swift.max(1, 1 << (exponent - F))
    }

    init(exponent: Int, count: BigInt) {
      self.count = count
      self.spacing = Self.calculateSpacing(exponent: exponent)

      // Powers of 2 are exactly representable in 'T' (up to some point).
      self.lowerBound = BigInt(1) << exponent
      self.upperBound = lowerBound << 1

      // Below we do: ((range / spacing) / count) * spacing.
      // You may be tempted to remove 'spacing' from this equation (/ then *),
      // but remember that in integer arithmetic '(n/a)*a' does not always give 'n'!
      let totalSpacesCount = (self.upperBound - self.lowerBound) / spacing
      let sampleIntervalInSpaces = totalSpacesCount / count
      assert(sampleIntervalInSpaces != 0, "Got \(totalSpacesCount) values, requested \(count) count")
      self.sampleInterval = sampleIntervalInSpaces * spacing
    }

    func makeIterator() -> AnyIterator<Element> {
      var index: BigInt = 0

      return AnyIterator {
        if index == self.count {
          return nil
        }

        let n = self.lowerBound + index * self.sampleInterval
        assert(self.lowerBound <= n && n < self.upperBound)

        guard let d = T(exactly: n) else {
          fatalError("\(n) is not exactly representable as \(T.self)")
        }

        index += 1 // Important!
        return Element(n, d)
      }
    }
  }

  // Please read IEEE_754_SPACING_NOTE above.
  func test_integerSpacing_by1() {
    // In '2**T.significandBitCount' range using 'd.next' to go away from 0
    // will increment integer by 1.

    spacingWhereNextGoesUpByInteger(type: Float.self,
                                    exponent: Float.significandBitCount,
                                    spacing: 1)

    spacingWhereNextGoesUpByInteger(type: Double.self,
                                    exponent: Double.significandBitCount,
                                    spacing: 1)

#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    spacingWhereNextGoesUpByInteger(type: Float80.self,
                                    exponent: Float80.significandBitCount,
                                    spacing: 1)
#endif
  }

  // Please read IEEE_754_SPACING_NOTE above.
  func test_integerSpacing_by2() {
    // In '2**(T.significandBitCount+1)' range using 'd.next' to go away from 0
    // will increment integer by 2.

    spacingWhereNextGoesUpByInteger(type: Float.self,
                                    exponent: Float.significandBitCount + 1,
                                    spacing: 2)

    spacingWhereNextGoesUpByInteger(type: Double.self,
                                    exponent: Double.significandBitCount + 1,
                                    spacing: 2)

#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    spacingWhereNextGoesUpByInteger(type: Float80.self,
                                    exponent: Float80.significandBitCount + 1,
                                    spacing: 2)
#endif
  }

  // Please read IEEE_754_SPACING_NOTE above.
  func test_integerSpacing_by4() {
    // In '2**(T.significandBitCount+2)' range using 'd.next' to go away from 0
    // will increment integer by 4.

    spacingWhereNextGoesUpByInteger(type: Float.self,
                                    exponent: Float.significandBitCount + 2,
                                    spacing: 4)

    spacingWhereNextGoesUpByInteger(type: Double.self,
                                    exponent: Double.significandBitCount + 2,
                                    spacing: 4)

#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    spacingWhereNextGoesUpByInteger(type: Float80.self,
                                    exponent: Float80.significandBitCount + 2,
                                    spacing: 4)
#endif
  }

  // Please read IEEE_754_SPACING_NOTE above.
  func test_integerSpacing_galaxyFarFarAway() {
    // See the tests above for details.
    // Here we are at the very edge of the representable integers.
    // Only 'greatestFiniteMagnitude' is bigger.
    // Waaaay outside of the Int64 range, but I guess that's what BigInt is for.

    guard let floatSpacing = self.create("800000000000000000000", radix: 32) else {
      XCTFail()
      return
    }

    spacingWhereNextGoesUpByInteger(
      type: Float.self,
      exponent: Float.greatestFiniteMagnitude.exponent - 1,
      spacing: floatSpacing
    )

    let doubleSpacingString = "1" + String(repeating: "0", count: 194)
    guard let doubleSpacing = self.create(doubleSpacingString, radix: 32) else {
      XCTFail()
      return
    }

    spacingWhereNextGoesUpByInteger(
      type: Double.self,
      exponent: Double.greatestFiniteMagnitude.exponent - 1,
      spacing: doubleSpacing
    )

#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    // This number has 3264 digits with 32 radix.
    // We were not joking about this 'galaxy far far away'.
    let float80SpacingString = "g" + String(repeating: "0", count: 3263)
    guard let float80Spacing = self.create(float80SpacingString, radix: 32) else {
      XCTFail()
      return
    }

    spacingWhereNextGoesUpByInteger(
      type: Float80.self,
      exponent: Float80.greatestFiniteMagnitude.exponent - 1,
      spacing: float80Spacing
    )
#endif
  }

  private func create(_ s: String, radix: Int) -> BigInt? {
    return BigInt(s, radix: radix)
  }

  /// Spacing test where 'T.next[Up/Down]' moves to next integer.
  private func spacingWhereNextGoesUpByInteger<T: BinaryFloatingPoint>(
    type: T.Type,
    exponent: Int,
    spacing: BigInt,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    assert(spacing >= 1)

    let sample = SampleExactlyRepresentableIntegers<T>(exponent: exponent, count: 100)
    assert(sample.spacing == spacing)

    for (sign, element) in CartesianProduct(signs, Array(sample)) {
      let (n, d) = element.withSign(sign)
      assertBigInt(d, n, file: file, line: line)
      assertExactlyBigInt(d, n, file: file, line: line)

      // We chose exponent, so that the 'next' differs by 'spacing'.
      let awayN = n + (sign == .plus ? spacing : -spacing)
      let awayD = d.nextAwayFromZero
      assertBigInt(awayD, awayN, file: file, line: line)
      assertExactlyBigInt(awayD, awayN, file: file, line: line)

      // Going toward 0 is a little bit more difficult because:
      // if we are at the lowerBound (1 << exponent) then going toward 0 changes
      // the power of 2 which increases number density (spacing is smaller).
      let towardDecreasesPowerOf2 = n.magnitude == sample.lowerBound
      let towardSpacing = towardDecreasesPowerOf2 ?
        SampleExactlyRepresentableIntegers<T>.calculateSpacing(exponent: exponent - 1) :
        spacing

      let towardN = n + (sign == .plus ? -towardSpacing : towardSpacing)
      let towardD = d.nextTowardZero
      assertBigInt(towardD, towardN, file: file, line: line)

      // If old spacing was 1 and we lowered it, then it is now 0.5.
      // Any integer - 0.5 makes fraction which is not exactly representable by int.
      // If we had any other spacing (like 2/4/etc) then we still have int.
      let isTowardSpacingHalf = towardDecreasesPowerOf2 && spacing == 1
      if isTowardSpacingHalf {
        assertExactlyBigIntIsNil(towardD, file: file, line: line)
      } else {
        assertExactlyBigInt(towardD, towardN, file: file, line: line)
      }
    }
  }

  // Please read IEEE_754_SPACING_NOTE above.
  func test_integerSpacing_by¹౹₂() { // ½
    // In '2**(T.significandBitCount-1)' range using 'd.next' to go away from 0
    // will increment integer by 0.5.

    spacingWhereNextGoesUpByFraction(type: Float.self,
                                     exponent: Float.significandBitCount - 1)

    spacingWhereNextGoesUpByFraction(type: Double.self,
                                     exponent: Double.significandBitCount - 1)

#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    spacingWhereNextGoesUpByFraction(type: Float80.self,
                                     exponent: Float80.significandBitCount - 1)
#endif
  }

  // Please read IEEE_754_SPACING_NOTE above.
  func test_integerSpacing_by¹౹₄() { // ¼
    // In '2**(T.significandBitCount-2)' range using 'd.next' to go away from 0
    // will increment integer by 0.25.

    spacingWhereNextGoesUpByFraction(type: Float.self,
                                     exponent: Float.significandBitCount - 2)

    spacingWhereNextGoesUpByFraction(type: Double.self,
                                     exponent: Double.significandBitCount - 2)

#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
    spacingWhereNextGoesUpByFraction(type: Float80.self,
                                     exponent: Float80.significandBitCount - 2)
#endif
  }

  /// Spacing test where 'T.next[Up/Down]' moves by a fraction (not a whole integer).
  private func spacingWhereNextGoesUpByFraction<T: BinaryFloatingPoint>(
    type: T.Type,
    exponent: Int,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let sample = SampleExactlyRepresentableIntegers<T>(exponent: exponent, count: 100)

    for (sign, element) in CartesianProduct(signs, Array(sample)) {
      let (n, d) = element.withSign(sign)
      assertBigInt(d, n, file: file, line: line)
      assertExactlyBigInt(d, n, file: file, line: line)

      // We chose exponent, so that the 'next' differs by 1/2 or 1/4 etc.
      // This is not enough for 'next' to move to next integer,
      // so rounding stays the same. But now the 'exact' fails.
      let awayD = d.nextAwayFromZero
      assertBigInt(awayD, n, file: file, line: line)
      assertExactlyBigIntIsNil(awayD, file: file, line: line)

      // Going toward 0 decreases 'n' magnitude (obviously) and because the step
      // is <1 (for example 1/2 or 1/4) the number is not exactly representable.
      let towardN = n + (sign == .plus ? -1 : 1)
      let towardD = d.nextTowardZero
      assertBigInt(towardD, towardN, file: file, line: line)
      assertExactlyBigIntIsNil(towardD, file: file, line: line)
    }
  }
}
