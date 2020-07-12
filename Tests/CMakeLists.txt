#[[
This source file is part of the Swift Numerics open source project

Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
#]]

find_package(dispatch CONFIG QUIET)
find_package(Foundation CONFIG QUIET)
find_package(XCTest CONFIG QUIET)

add_subdirectory(ComplexTests)
add_subdirectory(RealTests)

add_executable(SwiftNumericsTestRunner
  WindowsMain.swift)
target_link_libraries(SwiftNumericsTestRunner PRIVATE
  ComplexTests
  RealTests)

add_test(NAME SwiftNumericsTestRunner
  COMMAND SwiftNumericsTestRunner)
