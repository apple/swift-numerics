//===--- LCM.swift --------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// The least common multiple of a given list of values.
///
/// If no values are provided, the result is zero.
///
/// TODO
///
/// [wiki]: https://en.wikipedia.org/wiki/Least_common_multiple
@inlinable
public func lcm<T: BinaryInteger>(_ n: T...) -> T {
    guard let first = n.first else { return 0 }
    guard n.count > 1 else { return first}
    
    return n.reduce(first, _lcm)
}

@inlinable
internal func _lcm<T: BinaryInteger>(_ a: T, _ b: T) -> T {
    let x = T(a.magnitude)
    let y = T(b.magnitude)
    
    let z = gcd(x, y)
    
    guard z != 0 else { return 0 }
    
    return x * (y / z)
}