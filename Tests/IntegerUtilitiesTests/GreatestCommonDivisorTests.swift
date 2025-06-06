<<<<<<< HEAD
//===--- GreatestCommonDivisorTests.swift ---------------------------------------*- swift -*-===//
=======
//===--- GCDTests.swift ---------------------------------------*- swift -*-===//
>>>>>>> 1660f6bdd8fe76f9e6d7157380512059f88e3686
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import IntegerUtilities
import Testing

<<<<<<< HEAD
@Suite("Greatest Common Divisor Tests")
struct GreatestCommonDivisorTests {
	@Test("gcd") func gcdTests() async throws {
=======
@Suite("GCD Tests")
struct GCDTests {
	@Test("gcd Tests") func gcdTests() async throws {
>>>>>>> 1660f6bdd8fe76f9e6d7157380512059f88e3686
		#expect(gcd(0, 0) == 0)
		#expect(gcd(0, 1) == 1)
		#expect(gcd(1, 0) == 1)
		#expect(gcd(0, -1) == 1)
		#expect(gcd(-1, 0) == 1)
		#expect(gcd(1, 1) == 1)
		#expect(gcd(1, 2) == 1)
		#expect(gcd(2, 2) == 2)
		#expect(gcd(4, 2) == 2)
		#expect(gcd(6, 8) == 2)
		#expect(gcd(77, 91) == 7)
		#expect(gcd(24, -36) == 12)
		#expect(gcd(-24, -36) == 12)
		#expect(gcd(51, 34) == 17)
		#expect(gcd(64, 96) == 32)
		#expect(gcd(-64, 96) == 32)
		#expect(gcd(4*7*19, 27*25) == 1)
		#expect(gcd(16*315, 11*315) == 315)
		#expect(gcd(97*67*53*27*8, 83*67*53*9*32) == 67*53*9*8)
		#expect(gcd(Int.min, 2) == 2)
		#expect(gcd(Int.max, Int.max) == Int.max)
<<<<<<< HEAD
		#expect(gcd(0, Int.min) == Int.min.magnitude)
		#expect(gcd(Int.min, 0) == Int.min.magnitude)
		#expect(gcd(Int.min, Int.min) == Int.min.magnitude)
=======

//		#expect(processExitsWith: .failure) {
//			gcd(0, Int.min)
//		}
//		#expect(processExitsWith: .failure) {
//			gcd(Int.min, 0)
//		}
//		#expect(processExitsWith: .failure) {
//			gcd(Int.min, Int.min)
//		}
	}

	@Test("greatestCommonDivisor Tests") func greatestCommonDivisorTests() async throws {
		#expect(try greatestCommonDivisor(0, 0) == 0)
		#expect(try greatestCommonDivisor(0, 1) == 1)
		#expect(try greatestCommonDivisor(1, 0) == 1)
		#expect(try greatestCommonDivisor(0, -1) == 1)
		#expect(try greatestCommonDivisor(-1, 0) == 1)
		#expect(try greatestCommonDivisor(1, 1) == 1)
		#expect(try greatestCommonDivisor(1, 2) == 1)
		#expect(try greatestCommonDivisor(2, 2) == 2)
		#expect(try greatestCommonDivisor(4, 2) == 2)
		#expect(try greatestCommonDivisor(6, 8) == 2)
		#expect(try greatestCommonDivisor(77, 91) == 7)
		#expect(try greatestCommonDivisor(24, -36) == 12)
		#expect(try greatestCommonDivisor(-24, -36) == 12)
		#expect(try greatestCommonDivisor(51, 34) == 17)
		#expect(try greatestCommonDivisor(64, 96) == 32)
		#expect(try greatestCommonDivisor(-64, 96) == 32)
		#expect(try greatestCommonDivisor(4*7*19, 27*25) == 1)
		#expect(try greatestCommonDivisor(16*315, 11*315) == 315)
		#expect(try greatestCommonDivisor(97*67*53*27*8, 83*67*53*9*32) == 67*53*9*8)
		#expect(try greatestCommonDivisor(Int.min, 2) == 2)
		#expect(try greatestCommonDivisor(Int.max, Int.max) == Int.max)
		#expect(throws: OverflowError(value: Int.min.magnitude)) {
			try greatestCommonDivisor(0, Int.min)
		}
		#expect(throws: OverflowError(value: Int.min.magnitude)) {
			try greatestCommonDivisor(Int.min, 0)
		}
		#expect(throws: OverflowError(value: Int.min.magnitude)) {
			try greatestCommonDivisor(Int.min, Int.min)
		}
>>>>>>> 1660f6bdd8fe76f9e6d7157380512059f88e3686
	}
}
