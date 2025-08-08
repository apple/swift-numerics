#[[
This source file is part of the Swift Numerics open source project

Copyright (c) 2019-2021 Apple Inc. and the Swift Numerics project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
#]]

add_subdirectory(_NumericsShims)
add_subdirectory(ComplexModule)
add_subdirectory(Numerics)
add_subdirectory(RealModule)
if(BUILD_TESTING)
  add_subdirectory(_TestSupport)
endif()
