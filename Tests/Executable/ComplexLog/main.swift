//===--- main.swift -------------------------------------------*- swift -*-===//
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
import _TestSupport

#if DEBUG
fatalError("Run this test in Release configuration")
#else

var componentError = Double(Float.ulpOfOne/2)
var complexError = Double(Float.ulpOfOne/2)
var componentMaxInput = Complex<Float>.zero
var complexMaxInput = Complex<Float>.zero

func test(_ z: Complex<Float>) {
  let tst = Complex.log(z)
  // TODO: we _should_ be able to say Complex<Double>(z), but that goes through
  // the slow, generic path for BinaryFloatingPoint conversion; once we get
  // that resolved in the standard library, we can replace the conversion on
  // this and the next line. Currently it dominate testing time if we do that.
  let ref = Complex.log(Complex(Double(z.real), Double(z.imaginary)))
  if tst == Complex(Float(ref.real), Float(ref.imaginary)) { return }
  let thisError = relativeError(tst, ref)
  if thisError > complexError {
    complexMaxInput = z
    complexError = thisError
  }
  let thisComponentError = componentwiseError(tst, ref)
  if thisComponentError > componentError {
    componentMaxInput = z
    componentError = thisComponentError
  }
}

func testWithSymmetries(_ x: Float, _ y: Float) {
  test(Complex( x, y))
  test(Complex( y, x))
  test(Complex(-y, x))
  test(Complex(-x, y))
  test(Complex(-x,-y))
  test(Complex(-y,-x))
  test(Complex( y,-x))
  test(Complex( x,-y))
}

// The hardest to evaluate cases for log are those close to the unit circle,
// where log(z) is nearly zero. We want to have plausibly dense test coverage
// close to the circle.
let radii: [Float] = [0.9,
                      0.95,
                      0.99,
                      0.999,
                      0.9999,
                      1 - 10 * .ulpOfOne,
                      1,
                      1 + 10 * .ulpOfOne,
                      1.0001,
                      1.001,
                      1.01,
                      1.05,
                      1.1]

for r in radii {
  for x in Interval(from: 1/Float.sqrt(2), to: r) {
    // Generate the two y values that put us closest to the circle of radius r
    let base = Double.sqrt(Double(r).addingProduct(Double(-x), Double(x)))
    let a, b: Float
    if Double(Float(base)) < base { a = Float(base); b = a.nextUp }
    else { b = Float(base); a = b.nextDown }
    testWithSymmetries(x, a)
    testWithSymmetries(x, b)
  }
}

// Away from the unit circle is "easy" but we still want to get some coverage.
// Generate 1 million uniform random points inside the circle, and then test
// both z and 1/z.
var g = SystemRandomNumberGenerator()
var count = 0
while count < 1_000_000 {
  let z = Complex<Float>(.random(in: -1 ... 1, using: &g), .random(in: -1 ... 1, using: &g))
  if z.length > 1 { continue }
  count += 1
  test(z)
  test(1/z)
}

print("Worst complex norm error seen for log was \(complexError)")
print("For input \(complexMaxInput).")
print("Reference result: \(Complex.log(Complex<Double>(complexMaxInput)))")
print(" Observed result: \(Complex.log(complexMaxInput))")

print("Worst componentwise error seen for log was \(componentError)")
print("For input \(componentMaxInput).")
print("Reference result: \(Complex.log(Complex<Double>(componentMaxInput)))")
print(" Observed result: \(Complex.log(componentMaxInput))")

#endif
