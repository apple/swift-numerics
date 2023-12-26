#[[
This source file is part of the Swift Numerics open source project

Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
#]]

add_library(BigIntModule
  BigInt.swift)
set_target_properties(BigIntModule PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})

_install_target(BigIntModule)
set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS BigIntModule)
