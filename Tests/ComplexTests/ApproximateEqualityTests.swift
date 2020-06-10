import Numerics
import XCTest

final class ElementaryFunctionTests: XCTestCase {
  
  func testSpecials<T: Real>(tolerance tol: Tolerance<T>) {
    XCTAssertTrue(Complex<T>.zero.approximatelyEquals(.zero, tolerance: tol))
    XCTAssertTrue(Complex<T>.zero.approximatelyEquals(-.zero, tolerance: tol))
    XCTAssertTrue((-Complex<T>.zero).approximatelyEquals(.zero, tolerance: tol))
    XCTAssertTrue((-Complex<T>.zero).approximatelyEquals(-.zero, tolerance: tol))
    XCTAssertTrue(Complex<T>.infinity.approximatelyEquals(.infinity, tolerance: tol))
    XCTAssertTrue((-Complex<T>.infinity).approximatelyEquals(-.infinity, tolerance: tol))
    // Complex has a single point at infinity.
    XCTAssertTrue(Complex<T>.infinity.approximatelyEquals(-.infinity, tolerance: tol))
    XCTAssertTrue((-Complex<T>.infinity).approximatelyEquals(.infinity, tolerance: tol))
  }
  
  func testSpecials<T: Real>(_ type: T.Type) {
    XCTAssertTrue(Complex<T>.zero.approximatelyEquals(.zero))
    XCTAssertTrue(Complex<T>.zero.approximatelyEquals(-.zero))
    testSpecials(tolerance: .absolute(T.zero))
    testSpecials(tolerance: .absolute(T.greatestFiniteMagnitude))
    testSpecials(tolerance: .relative(T.ulpOfOne))
    testSpecials(tolerance: .relative(T(1).nextDown))
  }
  
  func testFloat() {
    testSpecials(Float.self)
  }
  
  func testDouble() {
    testSpecials(Double.self)
  }
  
  func testFloat80() {
    testSpecials(Float80.self)
  }
}
