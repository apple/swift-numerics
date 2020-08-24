#[[
This source file is part of the Swift Numerics open source project

Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
#]]

add_library(ComplexModule
  Arithmetic.swift
  Complex.swift
  Differentiable.swift
  ElementaryFunctions.swift)
set_target_properties(ComplexModule PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})
target_link_libraries(ComplexModule PUBLIC
  RealModule)


_install_target(ComplexModule)
set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS ComplexModule)
