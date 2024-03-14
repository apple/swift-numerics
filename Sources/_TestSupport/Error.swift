//===--- Error.swift ------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2020 - 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import ComplexModule
import RealModule

public func relativeError(_ tst: Float, _ ref: Double) -> Double {
  let scale = max(ref.magnitude, Double(Float.leastNormalMagnitude))
  let error = (Double(tst) - ref).magnitude
  return error / scale
}

public func componentwiseError(_ tst: Complex<Float>, _ ref: Complex<Double>) -> Double {
  return max(relativeError(tst.real, ref.real),
             relativeError(tst.imaginary, ref.imaginary))
}

public func relativeError(_ tst: Complex<Float>, _ ref: Complex<Double>) -> Double {
  let scale = max(ref.magnitude, Double(Float.leastNormalMagnitude))
  let dtst = Complex(Double(tst.real), Double(tst.imaginary))
  let error = (dtst - ref).magnitude
  return error / scale
}
