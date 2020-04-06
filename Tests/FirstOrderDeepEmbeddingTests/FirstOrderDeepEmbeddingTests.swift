import XCTest
import FirstOrderDeepEmbedding

final class FirstOrderDeepEmbeddingTests: XCTestCase {

    let language = Language.standard

    func eval<T : ASort>(_ t : T, result : T.Native) {
        XCTAssert(language.check(t))
        XCTAssertEqual(language.eval(t) as! T.Native, result, "inhabitant = \(t.inhabitant)")
    }
    
    func testINT() {
        let x = 123
        let y = 27
        let X : INT = 123
        let Y : INT = 27

        eval(X + Y, result: x + y)
        eval(X + 1, result: x + 1)
        eval(X - Y, result: x - y)
        eval(-X, result: -x)
        eval(X * Y, result: x * y)
        eval(X / Y, result: x / y)
        eval(X % Y, result: x % y)
        eval(INT.max(X, Y), result: max(x, y))
        eval(INT.min(X, Y), result: min(x, y))

        func match(_ t : INT) -> INT {
            t.match(123 => 1, 27 => 2)
        }
        
        eval(match(X), result: 1)
        eval(match(Y), result: 2)
        eval(match(X + Y + 1), result: 0)
        eval((X + Y + 1).match(123 => 1, 27 => 2, default: INT(3)), result: 3)
        
        eval((-X).IfNegative(Y), result: y)
        eval(X.IfNegative(Y), result: x)
        
        eval(X == X, result: true)
        eval(X == Y, result: false)
        eval(X == 10, result: false)
        eval(123 == X, result: true)
        
        eval(X == INT(x), result: true)
        eval(X == INT(y), result: false)
        eval(Y == INT(y), result: true)

        eval(X != INT(x), result: false)
        eval(X != INT(y), result: true)
        eval(Y != INT(y), result: false)

        
        eval(X < Y, result: x < y)
        eval(X <= Y, result: x <= y)
        eval(X > Y, result: x > y)
        eval(X >= Y, result: x >= y)
        eval(X < INT(x), result: false)
        eval(X <= INT(x), result: true)
        
        eval(X.in([123, 27]), result: true)
        eval(Y.in([123, 27]), result: true)
        eval((X + Y).in([123, 27]), result: false)
        
        eval(X.inRange(0, 100), result: false)
        eval(Y.inRange(0, 100), result: true)
                
        let defaultUNIT : UNIT = X.match()
        eval(defaultUNIT, result: UNIT.singleton)
        
        let defaultBOOL : BOOL = X.match()
        eval(defaultBOOL, result: false)
        
        let defaultINT : INT = X.match()
        eval(defaultINT, result: 0)
    }
    
    func testUNIT() {
        eval(UNIT.unit, result: UNIT.singleton)
        eval(UNIT.from(UNIT.singleton), result: UNIT.singleton)
    }
    
    func testBOOL() {
        eval(BOOL.from(false), result: false)
        eval(BOOL.from(true), result: true)
        eval(BOOL(false), result: false)
        eval(BOOL(true), result: true)
        let t : BOOL = true
        let f : BOOL = false
        eval(t, result: true)
        eval(f, result: false)
        eval(t && t, result: true)
        eval(t && f, result: false)
        eval(f && t, result: false)
        eval(f && f, result: false)
        eval(t || t, result: true)
        eval(t || f, result: true)
        eval(f || t, result: true)
        eval(f || f, result: false)
        eval(!t, result: false)
        eval(!f, result: true)
        eval(t == t, result: true)
        eval(t == f, result: false)
        eval(f == t, result: false)
        eval(f == f, result: true)
        eval(t != t, result: false)
        eval(t != f, result: true)
        eval(f != t, result: true)
        eval(f != f, result: false)
    }
    
    func testRecord() {
        
    }
    
    func testEnumeration() {
        
    }
    
    func testLanguage() {
    }

    static var allTests = [
        ("testINT", testINT),
        ("testUNIT", testUNIT),
        ("testBOOL", testBOOL),
        ("testRecord", testRecord),
        ("testEnumeration", testEnumeration),
        ("testLanguage", testLanguage)
    ]
}
