import XCTest
import ComplexTests
import ElementaryFunctionTests

var tests = [XCTestCaseEntry]()
tests += ComplexTests.allTests()
tests += ElementaryFunctionTests.allTests()
XCTMain(tests)
