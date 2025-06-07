//===--- LeastCommonMultipleTests.swift ---------------------------------------*- swift -*-===//
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

@Suite("Least Common Multiple Tests")
struct LeastCommonMultipleTests {
	@Test("lcm<BinaryInteger>") func lcm_BinaryIntegerTest() async throws {
		func lcm<T: BinaryInteger>(_ a: T, _ b: T) -> T {
			IntegerUtilities.lcm(a,b)
		}

		#expect(lcm(1024, 0) == 0)
		#expect(lcm(0, 1024) == 0)
		#expect(lcm(0, 0) == 0)
		#expect(lcm(1024, 768) == 3072)
		#expect(lcm(768, 1024) == 3072)
		#expect(lcm(24, 18) == 72)
		#expect(lcm(18, 24) == 72)
		#expect(lcm(6930, 288) == 110880)
		#expect(lcm(288, 6930) == 110880)
		#expect(lcm(Int.max, 1) == Int.max)
		#expect(lcm(1, Int.max) == Int.max)

		//		#expect(processExitsWith: .failure) {
		//			lcm(Int.min, Int.min)
		//		}
		//		#expect(processExitsWith: .failure) {
		//			lcm(Int.min, 1)
		//		}
		//		#expect(processExitsWith: .failure) {
		//			lcm(1, Int.min)
		//		}
		//		#expect(processExitsWith: .failure) {
		//			lcm(Int.max, Int.max)
		//		}
	}

	@Test("lcm<FixedWidthInteger>") func lcm_FixedWidthIntegerTests() async throws {
		func lcm<T: FixedWidthInteger>(_ a: T, _ b: T) throws -> T {
			try IntegerUtilities.lcm(a,b)
		}

		#expect(try lcm(1024, 0) == 0)
		#expect(try lcm(0, 1024) == 0)
		#expect(try lcm(0, 0) == 0)
		#expect(try lcm(1024, 768) == 3072)
		#expect(try lcm(768, 1024) == 3072)
		#expect(try lcm(24, 18) == 72)
		#expect(try lcm(18, 24) == 72)
		#expect(try lcm(6930, 288) == 110880)
		#expect(try lcm(288, 6930) == 110880)
		#expect(try lcm(Int.max, 1) == Int.max)
		#expect(try lcm(1, Int.max) == Int.max)
		#expect(throws: LeastCommonMultipleOverflowError<Int>(high: 0, low: Int.min.magnitude)) {
			try lcm(Int.min, Int.min)
		}
		#expect(throws: LeastCommonMultipleOverflowError<Int>(high: 0, low: Int.min.magnitude)) {
			try lcm(Int.min, 1)
		}
		#expect(throws: LeastCommonMultipleOverflowError<Int>(high: 0, low: Int.min.magnitude)) {
			try lcm(1, Int.min)
		}
		#expect(throws: LeastCommonMultipleOverflowError<Int8>(high: 63, low: 128)) {
			try lcm(Int8.min, Int8.max)
		}
	}
}
