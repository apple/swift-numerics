#[[
This source file is part of the Swift Numerics open source project

Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
#]]

add_library(RealModule
  AlgebraicField.swift
  ApproximateEquality.swift
  AugmentedArithmetic.swift
  Double+Real.swift
  ElementaryFunctions.swift
  Float+Real.swift
  Float16+Real.swift
  Float80+Real.swift
  Real.swift
  RealFunctions.swift)
set_target_properties(RealModule PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})
target_link_libraries(RealModule PUBLIC
  _NumericsShims)


_install_target(RealModule)
set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS RealModule)
