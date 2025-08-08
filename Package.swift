// swift-tools-version:5.9
//===--- Package.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2025 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import PackageDescription

let excludedFilenames = ["CMakeLists.txt", "README.md"]

let package = Package(
  
  name: "swift-numerics",
  products: [
    .library(name: "ComplexModule", targets: ["ComplexModule"]),
    .library(name: "Numerics", targets: ["Numerics"]),
    .library(name: "RealModule", targets: ["RealModule"]),
  ],
  
  targets: [
    // MARK: - Public API
    .target(
      name: "ComplexModule",
      dependencies: ["RealModule"],
      exclude: excludedFilenames
    ),
    
    .target(
      name: "Numerics",
      dependencies: ["ComplexModule", "RealModule"],
      exclude: excludedFilenames
    ),
    
    .target(
      name: "RealModule",
      dependencies: ["_NumericsShims"],
      exclude: excludedFilenames,
      linkerSettings: [
        .linkedLibrary("m", .when(platforms: [.linux, .android]))
      ]
    ),
    
    // MARK: - Implementation details
    .target(
      name: "_NumericsShims",
      exclude: excludedFilenames
    ),
    
    .target(
      name: "_TestSupport",
      dependencies: ["Numerics"],
      exclude: ["CMakeLists.txt"]
    ),
    
    // MARK: - Unit test bundles
    .testTarget(
      name: "ComplexTests",
      dependencies: ["_TestSupport"],
      exclude: ["CMakeLists.txt"]
    ),
    
    .testTarget(
      name: "RealTests",
      dependencies: ["_TestSupport"],
      exclude: ["CMakeLists.txt"]
    )
  ]
)
