import XCTest
import BigInt

func fac(_ n: BigInt) -> BigInt {
    var result: BigInt = 1
    var count = n
    while count >= 1 {
        result *= count
        count -= 1
    }
    
    return result
}

final class BigIntTests: XCTestCase {
    func testExample() throws {
        let bar = BigInt(exactly: -100)
        XCTAssertNotNil(bar)
        XCTAssert(bar! < 0)
        
        XCTAssert(-(bar!) > 0)
        XCTAssertEqual(-(bar!), BigInt(100))
        
        XCTAssertEqual(-BigInt("-1234567890123456789012345678901234567890")!, BigInt("1234567890123456789012345678901234567890")!)
    }
    
    func testFloatingConversion() {
        let bar = BigInt(3.14159)
        XCTAssertEqual(bar, BigInt(3))
        let foo = BigInt(exactly: 3.14159)
        XCTAssertNil(foo)
        
        let baz = BigInt(exactly: 2.4e39)
        XCTAssertNotNil(baz)
        let equal = (baz ?? 0) / BigInt(1e38) == BigInt(24)
        XCTAssertEqual(equal, true)
    }
    
    func testUIntConversion() {
        let foo = BigInt(UInt.max)
        XCTAssertNotEqual(foo, BigInt(-1))
        
        let bar = BigInt(bitPattern: UInt.max)
        XCTAssertEqual(bar, BigInt(-1))
    }
    
    func testComparison() {
        let foo = BigInt(-10)
        let bar = BigInt(-20)
        
        XCTAssert(foo > bar)
        XCTAssert(bar < foo)
        XCTAssert(foo == BigInt(-10))
        
        let baz = pow(foo, -bar)
        XCTAssertEqual(baz, BigInt("100000000000000000000")!)
    }
    
    func testMath() {
        let foo = pow(BigInt(10), 20)
        let bar = BigInt("1234567890123456789012345678901234567890")!
        
        let baz = foo + bar
        
        XCTAssertEqual(baz, BigInt("1234567890123456789112345678901234567890")!)
        
        let fooz = foo >> BigInt(10)
        XCTAssertEqual(fooz, foo / 1024)
        
        let barz = BigInt(1) << 64
        XCTAssertEqual(barz, BigInt(UInt.max) + 1)
    }
}
