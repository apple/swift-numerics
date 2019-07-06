// swift-tools-version:5.0
//===--- Package.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
  name: "swift-numerics",
  products: [
    .library(name: "Complex", targets: ["Complex"]),
    .library(name: "ElementaryFunctions", targets: ["ElementaryFunctions"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "Complex", dependencies: ["ElementaryFunctions"]),
    .target(name: "ElementaryFunctions", dependencies: ["NumericsShims"]),
    .target(name: "NumericsShims", dependencies: []),
    
    .testTarget(name: "ComplexTests", dependencies: ["Complex"]),
    .testTarget(name: "ElementaryFunctionTests", dependencies: ["ElementaryFunctions"]),
  ]
)
