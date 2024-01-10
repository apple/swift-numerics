#[[
This source file is part of the Swift Numerics open source project

Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
#]]

add_library(RealTests
  ApproximateEqualityTests.swift
  AugmentedArithmeticTests.swift
  ElementaryFunctionChecks.swift
  IntegerExponentTests.swift
  RelaxedArithmeticTests.swift)
target_compile_options(RealTests PRIVATE
  -enable-testing)
target_link_libraries(RealTests PUBLIC
  $<$<NOT:$<PLATFORM_ID:Darwin>>:Foundation>
  RealModule
  _TestSupport
  XCTest)
