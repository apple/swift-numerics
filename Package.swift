// swift-tools-version:5.0
//===--- Package.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
  name: "swift-numerics",
  products: [
    .library(name: "NumericsComplex", targets: ["NumericsComplex"]),
    .library(name: "Numerics", targets: ["Numerics"]),
    .library(name: "NumericsReal", targets: ["NumericsReal"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "NumericsComplex", dependencies: ["NumericsReal"]),
    .target(name: "Numerics", dependencies: ["NumericsComplex", "NumericsReal"]),
    .target(name: "_NumericsShims", dependencies: []),
    .target(name: "NumericsReal", dependencies: ["_NumericsShims"]),
    
    .testTarget(name: "ComplexTests", dependencies: ["NumericsComplex", "_NumericsShims"]),
    .testTarget(name: "RealTests", dependencies: ["NumericsReal"]),
  ]
)
