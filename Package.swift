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
    .library(name: "Complex", targets: ["Complex"]),
    .library(name: "ElementaryFunctions", targets: ["ElementaryFunctions"]),
    .library(name: "Numerics", targets: ["Numerics"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "Complex", dependencies: ["ElementaryFunctions"]),
    .target(name: "ElementaryFunctions", dependencies: ["NumericsShims"]),
    .target(name: "Numerics", dependencies: ["Complex", "ElementaryFunctions"]),
    .target(name: "NumericsShims", dependencies: []),
    
    .testTarget(name: "ComplexTests", dependencies: ["Complex"]),
    .testTarget(name: "ElementaryFunctionTests", dependencies: ["ElementaryFunctions"]),
  ]
)
