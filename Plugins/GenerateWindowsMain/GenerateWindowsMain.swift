//===--- GenerateWindowsMain.swift ----------------------------*- swift -*-===//
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
//===--- WindowsMain.swift ------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) \(year) Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//
// This file can be automatically generated with the command:
// swift package --allow-writing-to-package-directory generate-windows-main
//===----------------------------------------------------------------------===//
"""

@main
struct GenerateWindowsMain: CommandPlugin {

  func performCommand(
    context: PluginContext,
    arguments: [String]
  ) async throws {
    let moduleNames: [String] = context.package.targets(
      ofType: SwiftSourceModuleTarget.self
    ).filter({ $0.kind == .test }).map(\.moduleName).sorted()

    var testCases: [String: [String]] = [:]
    let specifiers = try packageManager.discoverTests(context: context)
    for specifier in specifiers {
      let components = specifier.split(separator: "/").map { String($0) }
      guard components.count == 2 else { continue }
      let (key, value) = (components[0], components[1])
      testCases[key, default: []].append(value)
    }

    var result = prefix
    result += "\n\n"
    result += "#if os(Windows)\n\n"
    result += "import XCTest\n\n"
    for moduleName in moduleNames {
      result += "@testable import \(moduleName)\n"
    }
    result += "\n"
    for testCase in testCases.keys.sorted() {
      result += "extension \(testCase) {\n"
      result += "  static var all = testCase([\n"
      for test in testCases[testCase]! {
        result += "    (\"\(test)\", \(testCase).\(test)),\n"
      }
      result += "  ])\n"
      result += "}\n\n"
    }
    result += "var testCases = [\n"
    for testCase in testCases.keys.sorted() {
      result += "  \(testCase).all,\n"
    }
    result += "]\n\n"
    result += "XCTMain(testCases)\n\n"
    result += "#endif\n"

    let path = context.package.directory.appending("Tests", "WindowsMain.swift")
    try result.write(toFile: path.string, atomically: true, encoding: .utf8)
  }
}

// MARK: -

extension PackagePlugin.PackageManager {

  /// Returns all test methods, in the specifier format.
  func discoverTests(
    context: PluginContext
  ) throws -> [String] {
#if canImport(XcodeProjectPlugin)
    // FIXME: Xcode 14.2 doesn't implement the `test(_:parameters:)` method.
    let pipe = Pipe()
    let process = Process()
    process.executableURL = URL(
      fileURLWithPath: try context.tool(named: "swift").path.string
    )
    process.arguments = [
      "test",
      "--disable-sandbox", // Workaround for an 'invalid manifest' error.
      "--list-tests",
      "--package-path",
      context.package.directory.string,
    ]
    process.standardOutput = pipe
    try process.run()
    guard
      let data = try pipe.fileHandleForReading.readToEnd(),
      let text = String(data: data, encoding: .utf8)
    else {
      throw PackageManagerProxyError.unspecified("--list-tests: invalid output")
    }
    process.waitUntilExit()
    guard
      process.terminationReason == .exit,
      process.terminationStatus == 0
    else {
      throw PackageManagerProxyError.unspecified("--list-tests: exit failure")
    }
    return text.split(whereSeparator: \.isNewline).map { String($0) }.sorted()
#else
    var specifiers: [String] = []
    let testResult = try test(.all, parameters: TestParameters())
    for testTarget in testResult.testTargets {
      for testCase in testTarget.testCases {
        for test in testCase.tests {
          specifiers.append("\(testCase.name)/\(test.name)")
        }
      }
    }
    specifiers.sort()
    return specifiers
#endif
  }
}
