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

let excludedFilenames = ["CMakeLists.txt", "README.md"]

let package = Package(
  
  name: "swift-numerics",
  products: [
    .library(name: "ComplexModule", targets: ["ComplexModule"]),
    .library(name: "Numerics", targets: ["Numerics"]),
    .library(name: "QuaternionModule", targets: ["QuaternionModule"]),
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
      name: "IntegerUtilities",
      dependencies: [],
      exclude: excludedFilenames
    ),
    
    .target(
      name: "Numerics",
      dependencies: [
        "ComplexModule", "IntegerUtilities",
        "QuaternionModule", "RealModule"
      ],
      exclude: excludedFilenames
    ),

    .target(
      name: "QuaternionModule",
      dependencies: ["RealModule"]
    ),
    
    .target(
      name: "RealModule",
      dependencies: ["_NumericsShims"],
      exclude: excludedFilenames
    ),
    
    // MARK: - Implementation details
    .target(
      name: "_NumericsShims",
      dependencies: [],
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
      name: "IntegerUtilitiesTests",
      dependencies: ["IntegerUtilities"],
      exclude: ["CMakeLists.txt"]
    ),

    .testTarget(
      name: "QuaternionTests",
      dependencies: ["_TestSupport"]
    ),
    
    .testTarget(
      name: "RealTests",
      dependencies: ["_TestSupport"],
      exclude: ["CMakeLists.txt"]
    ),
    
    // MARK: - Test executables
    .target(
      name: "ComplexLog",
      dependencies: ["Numerics", "_TestSupport"],
      path: "Tests/Executable/ComplexLog"
    ),
    
    .target(
      name: "ComplexLog1p",
      dependencies: ["Numerics", "_TestSupport"],
      path: "Tests/Executable/ComplexLog1p"
    )
  ]
)
