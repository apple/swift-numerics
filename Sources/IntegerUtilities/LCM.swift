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

/// The least common multiple of passed values.
///
/// TODO
///
/// [wiki]: https://en.wikipedia.org/wiki/Least_common_multiple
@inlinable
public func lcm<T: BinaryInteger>(_ a: T, _ n: T...) -> T {
    _lcm(a, n.reduce(1, _lcm(_:_:)))
}

@inlinable
internal func _lcm<T: BinaryInteger>(_ a: T, _ b: T) -> T {
    
    // Using the gcd algorithm with accounting
    // for possible overflow of x*y
    let x = T(a.magnitude)
    let y = T(b.magnitude)
    
    let z = gcd(x, y)
    
    guard z != 0 else { return 0 }
    
    return x * (y / z)
}
