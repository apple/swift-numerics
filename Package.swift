// swift-tools-version:5.5
//===--- Package.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2021 Apple Inc. and the Swift Numerics project authors
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
    .library(name: "BigIntModule", targets: ["BigIntModule"]),
    .library(name: "ComplexModule", targets: ["ComplexModule"]),
    .library(name: "Numerics", targets: ["Numerics"]),
    .library(name: "RealModule", targets: ["RealModule"]),
  ],
  
  targets: [
    // MARK: - Public API
    .target(
      name: "BigIntModule",
      dependencies: [],
      exclude: excludedFilenames
    ),
    
    .target(
      name: "ComplexModule",
      dependencies: ["RealModule"],
      exclude: excludedFilenames
    ),
    
    .target(
      name: "IntegerUtilities",
      dependencies: [],
      exclude: excludedFilenames
    ),
    
    .target(
      name: "Numerics",
      dependencies: ["ComplexModule", "IntegerUtilities", "RealModule", "BigIntModule"],
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
      name: "BigIntTests",
      dependencies: ["BigIntModule"]
    ),
    
    .testTarget(
      name: "ComplexTests",
      dependencies: ["_TestSupport"],
      exclude: ["CMakeLists.txt"]
    ),
    
    .testTarget(
      name: "IntegerUtilitiesTests",
      dependencies: ["IntegerUtilities", "_TestSupport"],
      exclude: ["CMakeLists.txt"]
    ),
    
    .testTarget(
      name: "RealTests",
      dependencies: ["_TestSupport"],
      exclude: ["CMakeLists.txt"]
    ),
    
    // MARK: - Test executables
    .executableTarget(
      name: "ComplexLog",
      dependencies: ["Numerics", "_TestSupport"],
      path: "Tests/Executable/ComplexLog"
    ),
    
    .executableTarget(
      name: "ComplexLog1p",
      dependencies: ["Numerics", "_TestSupport"],
      path: "Tests/Executable/ComplexLog1p"
    )
  ]
)
