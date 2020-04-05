import XCTest
import FirstOrderDeepEmbedding

final class FirstOrderDeepEmbeddingTests: XCTestCase {

    let language = Language.standard

    func eval<T : ASort>(_ t : T, result : T.Native) {
        XCTAssertEqual(language.eval(t) as! T.Native, result)
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
        
        eval((-X).IfNegative(Y), result: y)
        eval(X.IfNegative(Y), result: x)
        
        eval(X == X, result: true)
        eval(X == Y, result: false)
        eval(X == 10, result: false)
        eval(123 == X, result: true)
        
        eval(X == INT(x), result: true)
        eval(X == INT(y), result: false)
        eval(Y == INT(y), result: true)
        
        eval(X < Y, result: x < y)
        eval(X <= Y, result: x <= y)
        eval(X > Y, result: x > y)
        eval(X >= Y, result: x >= y)
        eval(X < INT(x), result: false)
        eval(X <= INT(x), result: true)
    }

    static var allTests = [
        ("testINT", testINT),
    ]
}
