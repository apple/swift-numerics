//===--- ArithmeticBenchmarkTests.swift -----------------------*- swift -*-===//
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
import Complex

// For CComplex and shims
import NumericsShims

extension Complex where RealType == Double {
  @_transparent
  init(_ other: CComplex) {
    self = unsafeBitCast(other, to: Complex<Double>.self)
  }
  @_transparent
  var ctype: CComplex {
    unsafeBitCast(self, to: CComplex.self)
  }
}

let wellScaledDoubles: [Complex<Double>] = (0 ..< 1000).map { _ in
  Complex(length: Double.random(in: 0.5 ..< 2.0),
          phase: Double.random(in: -.pi ..< .pi))!
}

let poorlyScaledDoubles: [Complex<Double>] = (0 ..< 1000).map { _ in
  Complex(
    length: Double(sign: .plus,
                   exponent: .random(in: -970 ... 1023),
                   significand: .random(in: 1 ..< 2)),
    phase: Double.random(in: -.pi ..< .pi)
  )!
}

final class ArithmeticBenchmarkTests: XCTestCase {
  
  func testDivision() {
    let divisor = wellScaledDoubles[0]
    var sum = Complex<Double>.zero
    measure {
      for _ in 0 ..< 100 {
        sum = wellScaledDoubles.reduce(into: sum) { $0 += $1 / divisor }
      }
    }
    print(sum)
  }
  
  func testReciprocal() {
    let recip = wellScaledDoubles[0].reciprocal!
    var sum = Complex<Double>.zero
    measure {
      for _ in 0 ..< 100 {
        sum = wellScaledDoubles.reduce(into: sum) { $0 += $1 * recip }
      }
    }
    print(sum)
  }
  
  func testDivisionC() {
    let divisor = wellScaledDoubles[0].ctype
    var sum = Complex<Double>.zero
    measure {
      for _ in 0 ..< 100 {
        sum = wellScaledDoubles.reduce(into: sum) {
          $0 += Complex(libm_cdiv($1.ctype, divisor))
        }
      }
    }
    print(sum)
  }
  
  func testMultiplication() {
    let multiplicand = wellScaledDoubles[0]
    var sum = Complex<Double>.zero
    measure {
      for _ in 0 ..< 100 {
        sum = wellScaledDoubles.reduce(into: sum) { $0 += $1 * multiplicand }
      }
    }
    print(sum)
  }
  
  func testMultiplicationC() {
    let multiplicand = wellScaledDoubles[0].ctype
    var sum = Complex<Double>.zero
    measure {
      for _ in 0 ..< 100 {
        sum = wellScaledDoubles.reduce(into: sum) {
          $0 += Complex(libm_cmul($1.ctype, multiplicand))
        }
      }
    }
    print(sum)
  }
  
  func testDivisionPoorScaling() {
    let divisor = poorlyScaledDoubles[0]
    var sum = Complex<Double>.zero
    measure {
      for _ in 0 ..< 100 {
        sum = poorlyScaledDoubles.reduce(into: sum) { $0 += $1 / divisor }
      }
    }
    print(sum)
  }
  
  func testDivisionPoorScalingC() {
    let divisor = poorlyScaledDoubles[0].ctype
    var sum = Complex<Double>.zero
    measure {
      for _ in 0 ..< 100 {
        sum = poorlyScaledDoubles.reduce(into: sum) {
          $0 += Complex(libm_cdiv($1.ctype, divisor))
        }
      }
    }
    print(sum)
  }
  
  func testMultiplicationPoorScaling() {
    let multiplicand = poorlyScaledDoubles[0]
    var sum = Complex<Double>.zero
    measure {
      for _ in 0 ..< 100 {
        sum = poorlyScaledDoubles.reduce(into: sum) { $0 += $1 * multiplicand }
      }
    }
    print(sum)
  }
  
  func testMultiplicationPoorScalingC() {
    let multiplicand = poorlyScaledDoubles[0].ctype
    var sum = Complex<Double>.zero
    measure {
      for _ in 0 ..< 100 {
        sum = poorlyScaledDoubles.reduce(into: sum) {
          $0 += Complex(libm_cmul($1.ctype, multiplicand))
        }
      }
    }
    print(sum)
  }
}
