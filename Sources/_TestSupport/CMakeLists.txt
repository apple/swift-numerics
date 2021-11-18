#[[
This source file is part of the Swift Numerics open source project

Copyright (c) 2019-2021 Apple Inc. and the Swift Numerics project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
#]]

add_library(_TestSupport
  BlackHole.swift
  DoubleWidth.swift
  Error.swift
  Interval.swift
  RealTestSupport.swift)
set_target_properties(_TestSupport PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})
target_link_libraries(_TestSupport PUBLIC
  Numerics)


_install_target(_TestSupport)
set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS _TestSupport)
