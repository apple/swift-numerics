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

add_library(_NumericsShims INTERFACE)
target_include_directories(_NumericsShims INTERFACE
  _NumericsShims/include)
target_link_libraries(_NumericsShims INTERFACE
  $<$<PLATFORM_ID:Linux>:m>)
set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS _NumericsShims)

add_library(ComplexModule
  ComplexModule/Complex+AdditiveArithmetic.swift
  ComplexModule/Complex+AlgebraicField.swift
  ComplexModule/Complex+Codable.swift
  ComplexModule/Complex+ElementaryFunctions.swift
  ComplexModule/Complex+Hashable.swift
  ComplexModule/Complex+IntegerLiteral.swift
  ComplexModule/Complex+Numeric.swift
  ComplexModule/Complex+StringConvertible.swift
  ComplexModule/Complex.swift
  ComplexModule/Polar.swift
  ComplexModule/Scale.swift)
set_target_properties(ComplexModule PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})
target_link_libraries(ComplexModule PUBLIC
  RealModule)
_install_target(ComplexModule)
set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS ComplexModule)

add_library(IntegerUtilities
  IntegerUtilities/DivideWithRounding.swift
  IntegerUtilities/GCD.swift
  IntegerUtilities/Rotate.swift
  IntegerUtilities/RoundingRule.swift
  IntegerUtilities/ShiftWithRounding.swift)
set_target_properties(IntegerUtilities PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})
_install_target(IntegerUtilities)
set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS IntegerUtilities)

add_library(Numerics
  Numerics/Numerics.swift)
set_target_properties(Numerics PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})
# NOTE: generate the force load symbol to ensure that the import library is
# generated on Windows for autolinking.
target_compile_options(Numerics PUBLIC
  $<$<NOT:$<PLATFORM_ID:Darwin>>:-autolink-force-load>
  # SR-12254: workaround for the swift compiler not properly tracking the force
  # load symbol when validating the TBD
  -Xfrontend -validate-tbd-against-ir=none)
target_link_libraries(Numerics PUBLIC
  ComplexModule
  IntegerUtilities
  RealModule)
_install_target(Numerics)
set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS Numerics)

add_library(RealModule
  RealModule/AlgebraicField.swift
  RealModule/ApproximateEquality.swift
  RealModule/AugmentedArithmetic.swift
  RealModule/Double+Real.swift
  RealModule/ElementaryFunctions.swift
  RealModule/Float+Real.swift
  RealModule/Float16+Real.swift
  RealModule/Float80+Real.swift
  RealModule/Real.swift
  RealModule/RealFunctions.swift)
set_target_properties(RealModule PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})
target_link_libraries(RealModule PUBLIC
  _NumericsShims)
_install_target(RealModule)
set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS RealModule)

add_library(_TestSupport
  _TestSupport/DoubleWidth.swift
  _TestSupport/Error.swift
  _TestSupport/Interval.swift
  _TestSupport/RealTestSupport.swift)
set_target_properties(_TestSupport PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})
target_link_libraries(_TestSupport PUBLIC
  Numerics)
_install_target(_TestSupport)
set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS _TestSupport)
