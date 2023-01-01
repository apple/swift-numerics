// swift-tools-version:5.4
//===--- Package.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019-2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import PackageDescription

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
      exclude: ["README.md"]
    ),
    
    .target(
      name: "IntegerUtilities",
      dependencies: [],
      exclude: ["README.md"]
    ),
    
    .target(
      name: "Numerics",
      dependencies: ["ComplexModule", "IntegerUtilities", "RealModule"],
      exclude: ["README.md"]
    ),
    
    .target(
      name: "RealModule",
      dependencies: ["_NumericsShims"],
      exclude: ["README.md"]
    ),
    
    // MARK: - Implementation details
    .target(
      name: "_NumericsShims",
      exclude: ["README.md"],
      linkerSettings: [.linkedLibrary("m", .when(platforms: [.linux, .android]))]
    ),
    
    .target(
      name: "_TestSupport",
      dependencies: ["Numerics"]
    ),
    
    // MARK: - Unit test bundles
    .testTarget(
      name: "ComplexTests",
      dependencies: ["ComplexModule", "RealModule", "_TestSupport"]
    ),
    
    .testTarget(
      name: "IntegerUtilitiesTests",
      dependencies: ["IntegerUtilities", "_TestSupport"]
    ),
    
    .testTarget(
      name: "RealTests",
      dependencies: ["RealModule", "_TestSupport"]
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
