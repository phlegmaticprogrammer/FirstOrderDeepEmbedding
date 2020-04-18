public final class CHAR : ASort, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral {

    public typealias IntegerLiteralType = Int
        
    public typealias StringLiteralType = String

    public typealias Native = Character

    private class H : SortMakingHelper {
                            
        var C_less : ConstName!
        
        var C_leq : ConstName!
            
        var C_min : ConstName!
        
        var C_max : ConstName!
        
        init() {
            super.init("CHAR")
            let bool = BOOL().sortname
            C_less = add(op: "less", args: [sortname, sortname], result: bool)
            C_leq = add(op: "leq", args: [sortname, sortname], result: bool)
            C_min = add(op: "min", args: [sortname, sortname], result: sortname)
            C_max = add(op: "max", args: [sortname, sortname], result: sortname)
        }
        
    }

    private static let h = H()
                    
    public required init() {
        super.init()
    }

    public init(integerLiteral: IntegerLiteralType) {
        super.init()
        let character = Native(Unicode.Scalar(integerLiteral)!)
        set(inhabitant: .Native(value: character, sort: sortname))
    }
        
    public init(stringLiteral: StringLiteralType) {
        super.init()
        let character = Native(stringLiteral)
        set(inhabitant: .Native(value: character, sort: sortname))
    }

    public override func setDefaultInhabitant() {
        set(inhabitant: .Native(value: Native(" "), sort: sortname))
    }
        
    public override func isValid(nativeValue : Any) -> Bool {
        return nativeValue is Native
    }

    override public var sortname : SortName {
        return CHAR.h.sortname
    }
        
    override public var constants : [ConstName : Signature] {
        return CHAR.h.constants
    }
        
    override public func eval(name : ConstName, count : Int, nativeArgs : (Int) -> AnyHashable) -> AnyHashable {
        switch name.code {
        case CHAR.h.C_leq.code: return (nativeArgs(0) as! Native) <= (nativeArgs(1) as! Native)
        case CHAR.h.C_less.code: return (nativeArgs(0) as! Native) < (nativeArgs(1) as! Native)
        case CHAR.h.C_min.code: return Swift.min(nativeArgs(0) as! Native, nativeArgs(1) as! Native)
        case CHAR.h.C_max.code: return Swift.max(nativeArgs(0) as! Native, nativeArgs(1) as! Native)
        default: fatalEval(name, count, nativeArgs)
        }
    }
        
    public static func == (left : CHAR, right : CHAR) -> BOOL {
        return BOOL.equals(left, right)
    }

    public static func != (left : CHAR, right : CHAR) -> BOOL {
        return !BOOL.equals(left, right)
    }

    public static func <=(left : CHAR, right : CHAR) -> BOOL {
        return BOOL(inhabitant: .App(const: h.C_leq, args: [left.inhabitant, right.inhabitant]))
    }

    public static func <(left : CHAR, right : CHAR) -> BOOL {
        return BOOL(inhabitant: .App(const: h.C_less, args: [left.inhabitant, right.inhabitant]))
    }

    public static func >=(left : CHAR, right : CHAR) -> BOOL {
        return BOOL(inhabitant: .App(const: h.C_leq, args: [right.inhabitant, left.inhabitant]))
    }

    public static func >(left : CHAR, right : CHAR) -> BOOL {
        return BOOL(inhabitant: .App(const: h.C_less, args: [right.inhabitant, left.inhabitant]))
    }
        
    public static func min(_ left : CHAR, _ right : CHAR) -> CHAR {
        return CHAR(inhabitant: .App(const: h.C_min, args: [left.inhabitant, right.inhabitant]))
    }

    public static func max(_ left : CHAR, _ right : CHAR) -> CHAR {
        return CHAR(inhabitant: .App(const: h.C_max, args: [left.inhabitant, right.inhabitant]))
    }

    public func `in` <S : Sequence>(_ xs : S) -> BOOL where S.Element == CHAR {
        var result : BOOL = false
        for x in xs {
            result = result || self == x
        }
        return result
    }

    public func `in`(_ xs : CHAR...) -> BOOL {
        return `in`(xs)
    }
    
    public func inRange(_ lower : CHAR, _ upper : CHAR) -> BOOL {
        return lower <= self && self <= upper
    }
    
    public func match<T : Sort>(_ cases : Case<CHAR, T>..., `default` : T? = nil) -> T {
        var t = `default` ?? T.default()
        for c in cases.reversed() {
            t = (self == c.pattern).If(c.result, t)
        }
        return t
    }

}
