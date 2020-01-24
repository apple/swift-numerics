//===--- RealTestSupport.swift --------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import NumericsReal

#if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
typealias TestLiteralType = Float80
#else
typealias TestLiteralType = Double
#endif

@discardableResult
func assertClose<T>(
  _ expected: TestLiteralType,
  _ observed: T,
  allowedError: T = 16,
  file: StaticString = #file,
  line: UInt = #line
) -> T where T: BinaryFloatingPoint {
  // Shortcut relative-error check if we got the sign wrong; it's OK to
  // underflow to zero, but we do not want to allow going right through
  // zero and getting the sign wrong.
  guard observed.sign == expected.sign else {
    print("Sign was wrong: expected \(expected) but saw \(observed).")
    XCTFail(file: file, line: line)
    return .infinity
  }
  if observed.isNaN && expected.isNaN { return 0 }
  // If T(expected) is zero or infinite, and matches observed, the error
  // is zero.
  let expectedT = T(expected)
  if observed.isZero && expectedT.isZero { return 0 }
  if observed.isInfinite && expectedT.isInfinite { return 0 }
  // Special-case where only one of expectedT or observed is infinity.
  // Artificially knock everything down a binade, treat actual infinity as
  // the base of the next binade up.
  func topBinade(signOf x: T) -> T {
    T(signOf: x, magnitudeOf: T.greatestFiniteMagnitude.binade)
  }
  if observed.isInfinite {
    return assertClose(
      expected/2, topBinade(signOf: observed),
      allowedError: allowedError, file: file, line: line
    )
  }
  if expectedT.isInfinite {
    return assertClose(
      TestLiteralType(topBinade(signOf: expectedT)), observed/2,
      allowedError: allowedError, file: file, line: line
    )
  }
  // Compute error in ulp, compare to tolerance.
  let absoluteError = (TestLiteralType(observed) - expected).magnitude
  let scale = max(expectedT.magnitude, T.leastNormalMagnitude).ulp
  let ulps = T(absoluteError/TestLiteralType(scale))
  if ulps > allowedError {
    print("ULP error was unacceptably large: expected \(expected) but saw \(observed) (\(ulps)-ulp error).")
    XCTFail(file: file, line: line)
  }
  return ulps
}

func assertClose<T>(
  _ expected: TestLiteralType,
  _ observed: T,
  allowedError: T = 16,
  worstError: inout T,
  file: StaticString = #file,
  line: UInt = #line
) where T: BinaryFloatingPoint {
  worstError = max(worstError, assertClose(
    expected, observed, allowedError: allowedError, file: file, line: line
  ))
}
