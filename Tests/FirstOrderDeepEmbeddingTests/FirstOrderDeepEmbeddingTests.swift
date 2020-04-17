import XCTest
import FirstOrderDeepEmbedding

final class FirstOrderDeepEmbeddingTests: XCTestCase {
    
    class Suit : Enumeration<Suit.Base> {
        
        enum Base : CaseIterable {
            case diamonds, hearts, spades, clubs
        }
                
        static let diamonds = Case(.diamonds)
        static let hearts = Case(.hearts)
        static let spades = Case(.spades)
        static let clubs = Case(.clubs)
        
        required init() {}
                    
    }

    class Rank : Enumeration<Rank.Base> {
        
        enum Base : CaseIterable {
            case two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace
        }
        
        required init() {}
        
        override var sortname : SortName {
            return "TheRank"
        }
        
    }
    
    class Card : Record {
        @Field var rank : Rank
        @Field var suit : Suit
        
        required init() {}

        init(rank : Rank, suit : Suit) {
            super.init()
            self.rank = rank
            self.suit = suit
            setDefaultInhabitant()
        }
    }
    
    class Player : Record {
        @Field var card1 : Card
        @Field var card2 : Card
        @Field var stack : INT
        
        required init() {}
        
        init(card1 : Card, card2 : Card, stack : INT = 10000) {
            super.init()
            self.card1 = card1
            self.card2 = card2
            self.stack = stack
            setDefaultInhabitant()
        }

        init(card : Card) {
            super.init()
            self.card1 = card
            setDefaultInhabitant()
        }


    }

    lazy var language : Language = languageForTesting()
    
    private func languageForTesting() -> Language {
        var language = Language.standard
        language.add(sort: Rank())
        language.add(sort: Suit())
        language.add(sort: Card())
        language.add(sort: Player())
        return language
    }
    

    func eval<T : ASort>(_ t : T, result : T.Native) {
        XCTAssert(language.check(t), "inhabitant = \(t.inhabitant)")
        XCTAssertEqual(language.eval(t) as! T.Native, result, "inhabitant = \(t.inhabitant)")
    }

    func eval<T : ASort>(typeEnv : @escaping (AnyHashable) -> SortName?, env : @escaping (AnyHashable) -> AnyHashable?, _ t : T, result : T.Native) {
        XCTAssertEqual(language.check(env: typeEnv, term: t.inhabitant), T().sortname, "inhabitant = \(t.inhabitant)")
        XCTAssertEqual(language.eval(env: env, term: t.inhabitant) as! T.Native, result, "inhabitant = \(t.inhabitant)")
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
        
        eval(X.in(123, 27), result: true)
        eval(Y.in(123, 27), result: true)
        eval((X + Y).in(123, 27), result: false)
        
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
        let t : BOOL = true
        let f : BOOL = false
        eval(BOOL.from(false), result: false)
        eval(BOOL.from(true), result: true)
        eval(BOOL(false), result: false)
        eval(BOOL(true), result: true)
        let F = false
        let T = true
        eval(BOOL(F), result: false)
        eval(BOOL(T), result: true)
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
    
    func testEnumeration() {
        XCTAssertFalse(Language.standard.check(Suit.Case(.diamonds)))
        XCTAssertTrue(language.check(Suit.Case(.diamonds)))
        eval(Suit.Case(.diamonds), result: .diamonds)
        eval(Suit.Case(.hearts), result: .hearts)
        eval(Suit.Case(.spades), result: .spades)
        eval(Suit.Case(.clubs), result: .clubs)
        eval(Suit.diamonds, result: .diamonds)
        eval(Suit.hearts, result: .hearts)
        eval(Suit.spades, result: .spades)
        eval(Suit.clubs, result: .clubs)
        eval(Suit.diamonds == Suit.Case(.diamonds), result: true)
        eval(Suit.diamonds == Suit.diamonds, result: true)
        eval(Suit.hearts == Suit.hearts, result: true)
        eval(Suit.hearts == Suit.diamonds, result: false)
        eval(Suit.diamonds != Suit.Case(.diamonds), result: false)
        eval(Suit.diamonds != Suit.diamonds, result: false)
        eval(Suit.hearts != Suit.hearts, result: false)
        eval(Suit.hearts != Suit.diamonds, result: true)
        let suit = Suit.default()
        eval(suit, result: .diamonds)
        eval(suit == suit, result: true)
        eval(suit != suit, result: false)
        eval(suit == .diamonds, result: true)
        eval(.diamonds == suit, result: true)
        eval(suit == .hearts, result: false)
        eval(suit != .diamonds, result: false)
        eval(.diamonds != suit, result: false)
        eval(suit != .hearts, result: true)
        func points(_ suit : Suit) -> INT {
            return suit.match(.diamonds => 9, .hearts => 10, .spades => 11, .clubs => 12)
        }
        eval(points(.diamonds), result: 9)
        eval(points(.hearts), result: 10)
        eval(points(.spades), result: 11)
        eval(points(.clubs), result: 12)
        let suit2 : Suit = Suit.clubs.match()
        XCTAssertEqual(suit2.sortname, "Suit")
        eval(suit2, result: .diamonds)
        eval(Suit.clubs.match(default: Suit.hearts), result: .hearts)
        XCTAssertEqual(Rank.default().sortname, "TheRank")
        eval(Rank.default(), result: .two)
        eval(suit.in(.clubs, .spades), result: false)
        eval(suit.in(.clubs, .diamonds), result: true)
        eval(suit.in(.diamonds, .clubs), result: true)
    }

    func testRecord() {
        let card1 = Card(rank: .Case(.ace), suit: .spades)
        let card2 = Card(rank: .Case(.king), suit: .spades)
        let player1 = Player(card1: card1, card2: card2)
        let player2 = Player(card1: card1, card2: card2)
        let player3 = Player(card1: card1, card2: card2, stack: 8)
        let player4 = Player(card1: card2, card2: card1)
        
        eval(player1.card1.rank, result: .ace)
        eval(player1.card2.rank, result: .king)
        eval(player1.card1 == player2.card1, result: true)
        eval(player1.card1 != player2.card2, result: true)
        eval(player1 == player2, result: true)
        eval(player1 != player3, result: true)
        eval(player1 != player4, result: true)
        eval(player1.stack, result: 10000)
        eval(player3.stack, result: 8)
        
        var native = language.eval(player1) as! Record.Native
        XCTAssert(player4.isValid(nativeValue: native))
        native.append(5)
        XCTAssertFalse(player4.isValid(nativeValue: native))
        
        let player5 = Player(card: card2)
        eval(player5.card1 == card2, result: true)
        eval(player5.card2 == Card.default(), result: true)
        eval(player5.stack == 0, result: true)
    }
    
    func testArray() {
        let array : ARRAY<INT> = [0, 2, 4]
        eval(array.length, result: 3)
        eval(array, result: [0, 2, 4])
        eval(array.contains(2), result: true)
        eval(array.contains(3), result: false)
        eval(array + array, result: [0, 2, 4, 0, 2, 4])
        eval(array == array, result: true)
        eval(array != [], result: true)
        eval(array + 7, result: [0, 2, 4, 7])
        eval(array + [7], result: [0, 2, 4, 7])
        eval(ARRAY<INT>.default(), result: [])
        eval(array[0], result: 0)
        eval(array[1], result: 2)
        eval(array[2], result: 4)
    }
        
    func testLanguage() {
        let X : INT = 10
        XCTAssertEqual(language.varNamesOf(term: (X + 1).inhabitant), [])
    
        let intsortname = INT().sortname
        func typeEnv(name : AnyHashable) -> SortName? {
            if name is Int { return intsortname } else { return nil }
        }
        func env(name : AnyHashable) -> AnyHashable? {
            return name as? Int
        }
        
        eval(typeEnv: typeEnv, env: env, INT.Var(5) + INT.Var(7), result: 12)
        
        let lang1 = Language()
        var lang2 = Language()
        XCTAssertEqual(lang1, lang1)
        XCTAssertEqual(lang1, lang2)

        lang2.add(sort: BOOL())

        XCTAssertNotEqual(lang1, lang2)

        var lang3 = lang1
        lang3.add(sort: BOOL())

        XCTAssertEqual(lang2, lang3)

        lang3.add(sort: INT())

        XCTAssertNotEqual(lang2, lang3)
        XCTAssertEqual(Language.join(lang2, lang3), lang3)
        XCTAssertTrue(lang1 < lang2)
        XCTAssertTrue(lang1 < lang3)
        XCTAssertTrue(lang2 < lang3)
        XCTAssertFalse(lang3 < lang2)
        
        XCTAssertTrue(lang1 < Language.standard)
        XCTAssertTrue(lang2 < Language.standard)
        XCTAssertTrue(lang3 < Language.standard)
        
        XCTAssertTrue(Language.standard < languageForTesting())
        
        lang2.add(sort: UNIT())
        XCTAssertNotEqual(lang2, lang3)
        
        let lang4 = Language.join(lang2, lang3)
        let lang5 = Language.join(lang3, lang2)
        
        XCTAssertEqual(lang4, lang5)
        XCTAssertTrue(lang2 < lang4)
        XCTAssertTrue(lang3 < lang4)

    }
    
    func testTermStore() {
        
        // computes x*2^power
        func add(_ x : INT, power : Int) -> INT {
            guard power > 0 else { return x }
            let y = add(x, power: power - 1)
            return y + y
        }
        
        let x : INT = 1
        let y = add(x, power: 10)
        eval(y, result: 1024)
        
        let store = TermStore()
        let yId = store.store(y.inhabitant)
        XCTAssertEqual(store.size(yId), 2047)
        XCTAssertEqual(store.storedSize(yId), 11)
        
        let E = Eval(language: language, environment: { _ in nil })
        let values = store.computeAll(E)
        XCTAssertEqual(values.count, 11)
        var v = 1
        for value in values {
            XCTAssertEqual(value, v)
            v = 2 * v
        }
        
        XCTAssertEqual(store.compute(E, id: yId), 1024)
        guard case let .App(const: _, args: args) = store[yId] else { XCTFail(); return }
        XCTAssertEqual(args.count, 2)
        XCTAssertEqual(store.compute(E, id: args[0]), 512)
        XCTAssertEqual(store.compute(E, id: args[1]), 512)
        XCTAssertEqual(store[store[yId]], yId)
        XCTAssertEqual(store[store[args[0]]], args[0])
        XCTAssertEqual(store[store[args[1]]], args[1])
        XCTAssertEqual(args[0], args[1])
    }

}

