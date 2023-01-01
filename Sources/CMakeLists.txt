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

add_subdirectory(_NumericsShims)
add_subdirectory(ComplexModule)
add_subdirectory(IntegerUtilities)
add_subdirectory(Numerics)
add_subdirectory(RealModule)
if(BUILD_TESTING)
  add_subdirectory(_TestSupport)
endif()
