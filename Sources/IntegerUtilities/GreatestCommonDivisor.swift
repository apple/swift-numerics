//===--- GreatestCommonDivisor.swift --------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021-2024 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// The [greatest common divisor][gcd] of `a` and `b`.
///
/// If both inputs are zero, the result is zero. If one input is zero, the
/// result is the absolute value of the other input.
///
/// [gcd]: https://en.wikipedia.org/wiki/Greatest_common_divisor
@inlinable
public func gcd<T: BinaryInteger>(_ a: T, _ b: T) -> T.Magnitude {
	var x = a
	var y = b

	if x.magnitude < y.magnitude {
		swap(&x, &y)
	}

	// Euclidean algorithm for GCD. It's worth using Lehmer instead for larger
	// integer types, but for now this is good and dead-simple and faster than
	// the other obvious choice, the binary algorithm.
	while y != 0 {
		(x, y) = (y, x % y)
	}

	return x.magnitude
}
