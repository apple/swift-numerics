// swift-tools-version:5.6
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
      name: "IntegerUtilities",
      dependencies: [],
      exclude: excludedFilenames
    ),
    
    .target(
      name: "Numerics",
      dependencies: ["ComplexModule", "IntegerUtilities", "RealModule"],
      exclude: excludedFilenames
    ),
    
    .target(
      name: "RealModule",
      dependencies: ["_NumericsShims"],
      exclude: excludedFilenames
    ),
    
    // MARK: - Implementation details
    .target(
      name: "_NumericsShims",
      exclude: excludedFilenames,
      linkerSettings: [.linkedLibrary("m", .when(platforms: [.linux, .android]))]
    ),
    
    .target(
      name: "_TestSupport",
      dependencies: ["Numerics"],
      exclude: ["CMakeLists.txt"]
    ),
    
    // MARK: - Unit test bundles
    .testTarget(
      name: "ComplexTests",
      dependencies: ["ComplexModule", "RealModule", "_TestSupport"],
      exclude: ["CMakeLists.txt"]
    ),
    
    .testTarget(
      name: "IntegerUtilitiesTests",
      dependencies: ["IntegerUtilities", "_TestSupport"],
      exclude: ["CMakeLists.txt"]
    ),
    
    .testTarget(
      name: "RealTests",
      dependencies: ["RealModule", "_TestSupport"],
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
    ),

    // MARK: - Plugins
    .plugin(
      name: "GenerateCMakeLists",
      capability: .command(
        intent: .custom(
          verb: "generate-cmake-lists",
          description: "Generate CMakeLists.txt"
        ), permissions: [
          .writeToPackageDirectory(
            reason: "Generate CMakeLists.txt"
          ),
        ]
      )
    ),

    .plugin(
      name: "GenerateWindowsMain",
      capability: .command(
        intent: .custom(
          verb: "generate-windows-main",
          description: "Generate WindowsMain.swift"
        ), permissions: [
          .writeToPackageDirectory(
            reason: "Generate WindowsMain.swift"
          ),
        ]
      )
    ),
  ]
)
