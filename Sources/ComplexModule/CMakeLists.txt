#[[
This source file is part of the Swift Numerics open source project

Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
#]]

add_library(ComplexModule
  Complex.swift
  Complex+AdditiveArithmetic.swift
  Complex+AlgebraicField.swift
  Complex+Codable.swift
  Complex+ElementaryFunctions.swift
  Complex+Hashable.swift
  Complex+IntegerLiteral.swift
  Complex+Numeric.swift
  Complex+StringConvertible.swift
  Polar.swift
  Scale.swift)
set_target_properties(ComplexModule PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})
target_link_libraries(ComplexModule PUBLIC
  RealModule)


_install_target(ComplexModule)
set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS ComplexModule)
