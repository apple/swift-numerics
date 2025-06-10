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

private func lcm_BinaryInteger<T: BinaryInteger>(_ a: T, _ b: T) -> T {
	IntegerUtilities.lcm(a,b)
}

@Suite("Least Common Multiple Tests")
struct LeastCommonMultipleTests {
	@Test("lcm<BinaryInteger>") func lcm_BinaryIntegerTest() async throws {

		#expect(lcm_BinaryInteger(1024, 0) == 0)
		#expect(lcm_BinaryInteger(0, 1024) == 0)
		#expect(lcm_BinaryInteger(0, 0) == 0)
		#expect(lcm_BinaryInteger(1024, 768) == 3072)
		#expect(lcm_BinaryInteger(768, 1024) == 3072)
		#expect(lcm_BinaryInteger(24, 18) == 72)
		#expect(lcm_BinaryInteger(18, 24) == 72)
		#expect(lcm_BinaryInteger(6930, 288) == 110880)
		#expect(lcm_BinaryInteger(288, 6930) == 110880)
		#expect(lcm_BinaryInteger(Int.max, 1) == Int.max)
		#expect(lcm_BinaryInteger(1, Int.max) == Int.max)

		#if compiler(>=6.2)
			try await #expect(
				#require(
					String(
						bytes:	#require(processExitsWith: .failure, observing: [\.standardErrorContent]) {
							_ = lcm_BinaryInteger(Int.min, Int.min)
						}.standardErrorContent,
						encoding: .utf8
					)
				).contains(
					"Fatal error: LCM 9223372036854775808 is not representable as Int."
				)
			)
			try await #expect(
				#require(
					String(
						bytes:	#require(processExitsWith: .failure, observing: [\.standardErrorContent]) {
							_ = lcm_BinaryInteger(Int.min, 1)
						}.standardErrorContent,
						encoding: .utf8
					)
				).contains(
					"Fatal error: LCM 9223372036854775808 is not representable as Int."
				)
			)
			try await #expect(
				#require(
					String(
						bytes:	#require(processExitsWith: .failure, observing: [\.standardErrorContent]) {
							_ = lcm_BinaryInteger(1, Int.min)
						}.standardErrorContent,
						encoding: .utf8
					)
				).contains(
					"Fatal error: LCM 9223372036854775808 is not representable as Int."
				)
			)
			await #expect(processExitsWith: .failure) {
				_ = lcm_BinaryInteger(Int8.min, Int8.max)
			}
		#endif
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
