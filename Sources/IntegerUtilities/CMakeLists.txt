#[[
This source file is part of the Swift Numerics open source project

Copyright (c) 2019-2021 Apple Inc. and the Swift Numerics project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
#]]

add_library(IntegerUtilities
  DivideWithRounding.swift
  GCD.swift
  Rotate.swift
  RoundingRule.swift
  SaturatingArithmetic.swift
  ShiftWithRounding.swift)
set_target_properties(IntegerUtilities PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})

_install_target(IntegerUtilities)
set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS IntegerUtilities)
