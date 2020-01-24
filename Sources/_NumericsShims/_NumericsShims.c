//===--- NumericsShims.c --------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// This file exists only to trigger the NumericShims module to build; without
// it swiftpm won't build anything, and then the shims are not available for
// the modules that need them.

// If any shims are added that are not pure header inlines, whatever runtime
// support they require can be added to this file.

#include "_NumericsShims.h"
