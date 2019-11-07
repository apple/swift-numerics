//===--- ActivationFunctions.swift ----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

public protocol ActivationFunctions {
    
    ///
    /// An [activation function][wiki]. f(x) = max(0, x)
    ///
    /// See [this page][wiki-relu] for more information.
    ///
    /// [wiki]: https://en.wikipedia.org/wiki/Activation_function
    /// [wiki-relu]: https://en.wikipedia.org/wiki/Rectifier_(neural_networks)
    static func relu(_ x: Self) -> Self
    
    /// An [activation function][wiki]. f(x) = 1 / (exp(-x) + 1)
    ///
    /// See [this page][wiki-sigmoid] for more information.
    ///
    /// [wiki]: https://en.wikipedia.org/wiki/Activation_function
    /// [wiki-sigmoid]: https://en.wikipedia.org/wiki/Sigmoid_function
    static func sigmoid(_ x: Self) -> Self
    
}
