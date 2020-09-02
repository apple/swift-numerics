//===--- Error.swift ------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Numerics

func relativeError(_ tst: Float, _ ref: Double) -> Double {
  let scale = max(ref.magnitude, Double(Float.leastNormalMagnitude))
  let error = (Double(tst) - ref).magnitude
  return error / scale
}

func componentwiseError(_ tst: Complex<Float>, _ ref: Complex<Double>) -> Double {
  return max(relativeError(tst.real, ref.real),
             relativeError(tst.imaginary, ref.imaginary))
}

func relativeError(_ tst: Complex<Float>, _ ref: Complex<Double>) -> Double {
  let scale = max(ref.magnitude, Double(Float.leastNormalMagnitude))
  let error = (Complex<Double>(tst) - ref).magnitude
  return error / scale
}
