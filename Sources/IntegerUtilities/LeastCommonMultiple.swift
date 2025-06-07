//===--- LeastCommonMultiple.swift --------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021-2025 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// The [least common multiple][lcm] of `a` and `b`.
///
/// If either input is zero, the result is zero.
///
/// The result must be representable within its type.
///
/// [lcm]: https://en.wikipedia.org/wiki/Least_common_multiple
@inlinable
public func lcm<T: BinaryInteger>(_ a: T, _ b: T) -> T {
	guard (a != 0) && (b != 0) else {
		return 0
	}

	let lcm = a.magnitude / gcd(a, b) * b.magnitude

	guard let result = T(exactly: lcm) else {
		fatalError("LCM \(lcm) is not representable as \(T.self).")
	}

	return result
}

/// The [least common multiple][lcm] of `a` and `b`.
///
/// If either input is zero, the result is zero.
///
/// Throws `LeastCommonMultipleOverflowError` containing the full width result if it is not representable within its type.
///
/// [lcm]: https://en.wikipedia.org/wiki/Least_common_multiple
@inlinable
public func lcm<T: FixedWidthInteger>(_ a: T, _ b: T) throws(LeastCommonMultipleOverflowError<T>) -> T {
	guard (a != 0) && (b != 0) else {
		return 0
	}

	let reduced = a.magnitude / gcd(a, b)

	// We optimize for the non-throwing case
	let (partialValue, overflow) = reduced.multipliedReportingOverflow(by: b.magnitude)

	guard !overflow, let result = T(exactly: partialValue) else {
		let fullWidth = reduced.multipliedFullWidth(by: b.magnitude)

		throw LeastCommonMultipleOverflowError(high: fullWidth.high, low: fullWidth.low)
	}

	return result
}


/// Error thrown by `lcm<FixedWidthInteger>`.
///
/// `high` and `low` can be combined into a double width integer to access the result.
///
/// For example a `LeastCommonMultipleOverflowError<Int8>` contains the result as `Int16(error.high) << 8 | Int16(error.low)`
public struct LeastCommonMultipleOverflowError<T: FixedWidthInteger>: Error, Equatable {
	public let high: T.Magnitude
	public let low: T.Magnitude

	public init(high: T.Magnitude, low: T.Magnitude) {
		self.high = high
		self.low = low
	}
}

extension LeastCommonMultipleOverflowError: Sendable where T.Magnitude: Sendable { }
