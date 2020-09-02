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
import ArgumentParser
import Foundation

struct ComplexElementaryFunctions: ParsableCommand {
  func run() throws {
    // Walk grid points of the form (n + nπ/16 i) comparing Float and Double,
    // finding the worst componentwise and normwise errors for Float.
    let reals = (-100 ... 100).map { Float($0) }
    let imags = (-100 ... 100).map { Float($0) * .pi / 16 }
    var componentError = Double(Float.ulpOfOne)
    var complexError = Double(Float.ulpOfOne)
    var componentMaxInput = Complex<Float>.zero
    var complexMaxInput = Complex<Float>.zero
    for x in reals {
      for y in imags {
        let z = Complex(x, y)
        let tst = Complex.expMinusOne(z)
        let ref = Complex.expMinusOne(Complex<Double>(z))
        if tst == Complex<Float>(ref) { continue }
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
    }
    
    // Now sample randomly-generated points in an interesting strip along
    // the real axis.
    var g = SystemRandomNumberGenerator()
    for _ in 0 ..< 10_000 {
      let z = Complex(Float.random(in: -100 ... 100, using: &g),
                      Float.random(in: -2 * .pi ... 2 * .pi, using: &g))
      let tst = Complex.expMinusOne(z)
      let ref = Complex.expMinusOne(Complex<Double>(z))
      if tst == Complex<Float>(ref) { continue }
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
    
    print("Worst complex norm error seen for expMinusOne was \(complexError)")
    print("For input \(complexMaxInput).")
    print("Reference result: \(Complex.expMinusOne(Complex<Double>(complexMaxInput)))")
    print(" Observed result: \(Complex.expMinusOne(complexMaxInput))")
    
    print("Worst componentwise error seen for expMinusOne was \(componentError)")
    print("For input \(componentMaxInput).")
    print("Reference result: \(Complex.expMinusOne(Complex<Double>(componentMaxInput)))")
    print(" Observed result: \(Complex.expMinusOne(componentMaxInput))")
  }
}

ComplexElementaryFunctions.main()
