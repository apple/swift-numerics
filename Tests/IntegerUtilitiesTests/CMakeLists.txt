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

add_library(IntegerUtilitiesTests
  DivideTests.swift
  DoubleWidthTests.swift
  GCDTests.swift
  RotateTests.swift
  ShiftTests.swift)
target_compile_options(IntegerUtilitiesTests PRIVATE
  -enable-testing)
target_link_libraries(IntegerUtilitiesTests PUBLIC
  $<$<NOT:$<PLATFORM_ID:Darwin>>:Foundation>
  IntegerUtilities
  XCTest
  _TestSupport)
