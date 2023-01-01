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

add_library(ComplexTests
  ApproximateEqualityTests.swift
  ArithmeticTests.swift
  ElementaryFunctionTests.swift
  PropertyTests.swift)
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
