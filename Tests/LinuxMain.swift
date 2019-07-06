import XCTest

import ComplexTests
import ElementaryFunctionTests

var tests = [XCTestCaseEntry]()
tests += ComplexTests.__allTests()
tests += ElementaryFunctionTests.__allTests()

XCTMain(tests)
