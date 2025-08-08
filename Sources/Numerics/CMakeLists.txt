#[[
This source file is part of the Swift Numerics open source project

Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
#]]

add_library(Numerics
  Numerics.swift)
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
  RealModule)


_install_target(Numerics)
set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS Numerics)
