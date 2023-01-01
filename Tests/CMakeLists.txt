#[[
This source file is part of the Swift Numerics open source project

Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
#]]

#[=============================================================================[
# This file can be automatically generated with the command:
# swift package --allow-writing-to-package-directory generate-cmake-lists
#]=============================================================================]

find_package(dispatch CONFIG QUIET)
find_package(Foundation CONFIG QUIET)
find_package(XCTest CONFIG QUIET)

add_library(ComplexTests
  ComplexTests/ApproximateEqualityTests.swift
  ComplexTests/ArithmeticTests.swift
  ComplexTests/ElementaryFunctionTests.swift
  ComplexTests/PropertyTests.swift)
set_target_properties(ComplexTests PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})
target_compile_options(ComplexTests PRIVATE
  -enable-testing)
target_link_libraries(ComplexTests PUBLIC
  $<$<NOT:$<PLATFORM_ID:Darwin>>:Foundation>
  ComplexModule
  RealModule
  XCTest
  _TestSupport)

add_library(IntegerUtilitiesTests
  IntegerUtilitiesTests/DivideTests.swift
  IntegerUtilitiesTests/DoubleWidthTests.swift
  IntegerUtilitiesTests/GCDTests.swift
  IntegerUtilitiesTests/RotateTests.swift
  IntegerUtilitiesTests/ShiftTests.swift)
target_compile_options(IntegerUtilitiesTests PRIVATE
  -enable-testing)
target_link_libraries(IntegerUtilitiesTests PUBLIC
  $<$<NOT:$<PLATFORM_ID:Darwin>>:Foundation>
  IntegerUtilities
  XCTest
  _TestSupport)

add_library(RealTests
  RealTests/ApproximateEqualityTests.swift
  RealTests/AugmentedArithmeticTests.swift
  RealTests/ElementaryFunctionChecks.swift
  RealTests/IntegerExponentTests.swift)
target_compile_options(RealTests PRIVATE
  -enable-testing)
target_link_libraries(RealTests PUBLIC
  $<$<NOT:$<PLATFORM_ID:Darwin>>:Foundation>
  RealModule
  XCTest
  _TestSupport)

add_executable(SwiftNumericsTestRunner
  WindowsMain.swift)
target_link_libraries(SwiftNumericsTestRunner PRIVATE
  ComplexTests
  IntegerUtilitiesTests
  RealTests)
add_test(NAME SwiftNumericsTestRunner
  COMMAND SwiftNumericsTestRunner)
