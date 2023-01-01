//===--- GenerateCMakeLists.swift -----------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import Foundation
import PackagePlugin

let year: Int = Calendar(identifier: .iso8601).component(.year, from: Date())
let prefix: String =
"""
#[[
This source file is part of the Swift Numerics open source project

Copyright (c) \(year) Apple Inc. and the Swift Numerics project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
#]]

#[=============================================================================[
# This file can be automatically generated with the command:
# swift package --allow-writing-to-package-directory generate-cmake-lists
#]=============================================================================]
"""

@main
struct GenerateCMakeLists: CommandPlugin {

  func performCommand(
    context: PluginContext,
    arguments: [String]
  ) async throws {
    let targets = context.package.targets(
      ofType: SwiftSourceModuleTarget.self
    ).sorted(by: { $0.name < $1.name })

    for (targetsKind, subpath) in [
      ModuleKind.generic: "Sources",
      ModuleKind.test: "Tests",
    ] {
      let result = try generateCMakeLists(
        targets: targets.filter { $0.kind == targetsKind },
        targetsKind: targetsKind
      )
      let path = context.package.directory.appending(subpath, "CMakeLists.txt")
      try result.write(toFile: path.string, atomically: true, encoding: .utf8)
    }
  }

  func generateCMakeLists(
    targets: [SwiftSourceModuleTarget],
    targetsKind: ModuleKind
  ) throws -> String {
    precondition(targets.allSatisfy { $0.kind == targetsKind })
    var result = prefix
    result += "\n"
    if targetsKind == .test {
      result += "\n"
      result += "find_package(dispatch CONFIG QUIET)\n"
      result += "find_package(Foundation CONFIG QUIET)\n"
      result += "find_package(XCTest CONFIG QUIET)\n"
    }
    if targetsKind == .generic {
      result += "\n"
      result +=
"""
add_library(_NumericsShims INTERFACE)
target_include_directories(_NumericsShims INTERFACE
  _NumericsShims/include)
target_link_libraries(_NumericsShims INTERFACE
  $<$<PLATFORM_ID:Linux>:m>)
set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS _NumericsShims)
"""
      result += "\n"
    }
    for target in targets {
      result += "\n"
      result += try generateCMakeLists(target: target)
    }
    if targetsKind == .test {
      result += "\n"
      result += "add_executable(SwiftNumericsTestRunner\n"
      result += "  WindowsMain.swift)\n"
      result += "target_link_libraries(SwiftNumericsTestRunner PRIVATE"
      for target in targets {
        result += "\n  \(target.name)"
      }
      result += ")\n"
      result += "add_test(NAME SwiftNumericsTestRunner\n"
      result += "  COMMAND SwiftNumericsTestRunner)\n"
    }
    return result
  }

  func generateCMakeLists(
    target: SwiftSourceModuleTarget
  ) throws -> String {
    var linkedLibraries: [String] = []
    linkedLibraries += target.linkedLibraries
    linkedLibraries += target.dependencies.compactMap(\.name)
    if target.kind == .test {
      linkedLibraries.append("$<$<NOT:$<PLATFORM_ID:Darwin>>:Foundation>")
      linkedLibraries.append("XCTest")
    }
    linkedLibraries.sort()

    var result = "add_library(\(target.name)"
    for sourceFile in target.sourceFiles.map(\.path.lastComponent).sorted() {
      result += "\n  \(target.name)/\(sourceFile)"
    }
    result += ")\n"
    if target.kind == .generic || target.name == "ComplexTests" { // FIXME: Generic targets only?
      result += "set_target_properties(\(target.name) PROPERTIES"
      result += "\n  INTERFACE_INCLUDE_DIRECTORIES "
      result += "${CMAKE_Swift_MODULE_DIRECTORY})\n"
    }
    if target.name == "Numerics" {
      result +=
"""
# NOTE: generate the force load symbol to ensure that the import library is
# generated on Windows for autolinking.
target_compile_options(Numerics PUBLIC
  $<$<NOT:$<PLATFORM_ID:Darwin>>:-autolink-force-load>
  # SR-12254: workaround for the swift compiler not properly tracking the force
  # load symbol when validating the TBD
  -Xfrontend -validate-tbd-against-ir=none)
"""
      result += "\n"
    }
    if target.kind == .test {
      result += "target_compile_options(\(target.name) PRIVATE\n"
      result += "  -enable-testing)\n"
    }
    if !linkedLibraries.isEmpty {
      result += "target_link_libraries(\(target.name) PUBLIC"
      for linkedLibrary in linkedLibraries {
        result += "\n  \(linkedLibrary)"
      }
      result += ")\n"
    }
    if target.kind == .generic { // FIXME: Library products only?
      result += "_install_target(\(target.name))\n"
      result += "set_property(GLOBAL APPEND PROPERTY "
      result += "SWIFT_NUMERICS_EXPORTS \(target.name))\n"
    }
    return result
  }
}

// MARK: -

extension PackagePlugin.TargetDependency {

  var name: String? {
    switch self {
    case .target(let target):
      return target.name
    case .product(let product):
      return product.name
    @unknown default:
      return nil
    }
  }
}
