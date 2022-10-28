#[[
This source file is part of the Swift Numerics open source project

Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
#]]

add_library(_NumericsShims INTERFACE)
target_include_directories(_NumericsShims INTERFACE
  include)
target_link_libraries(_NumericsShims INTERFACE
  $<$<PLATFORM_ID:Linux>:m>)

set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS _NumericsShims)
