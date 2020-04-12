public final class INT : ASort, ExpressibleByIntegerLiteral {
    
    public typealias IntegerLiteralType = Int

    public typealias Native = Int

    private class H : SortMakingHelper {
                        
        var C_uminus : ConstName!

        var C_plus : ConstName!
        
        var C_minus : ConstName!
        
        var C_mul : ConstName!
        
        var C_div : ConstName!
        
        var C_mod : ConstName!
        
        var C_less : ConstName!
        
        var C_leq : ConstName!
        
        var C_ifNegative : ConstName!
        
        var C_min : ConstName!
        
        var C_max : ConstName!
        
        init() {
            super.init("INT")
            let bool = BOOL().sortname
            C_uminus = add(op: "uminus", args: [sortname], result: sortname)
            C_plus = add(op: "plus", args: [sortname, sortname], result: sortname)
            C_minus = add(op: "minus", args: [sortname, sortname], result: sortname)
            C_mul = add(op: "mul", args: [sortname, sortname], result: sortname)
            C_div = add(op: "div", args: [sortname, sortname], result: sortname)
            C_mod = add(op: "mod", args: [sortname, sortname], result: sortname)
            C_less = add(op: "less", args: [sortname, sortname], result: bool)
            C_leq = add(op: "leq", args: [sortname, sortname], result: bool)
            C_ifNegative = add(op: "ifNegative", args: [sortname, sortname], result: sortname)
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
        set(inhabitant: .Native(value: integerLiteral, sort: sortname))
    }
    
    public init(_ integer : Native) {
        super.init()
        set(inhabitant: .Native(value: integer, sort: sortname))
    }

    public override func setDefaultInhabitant() {
        set(inhabitant: .Native(value: 0, sort: sortname))
    }
        
    public override func isValid(nativeValue : Any) -> Bool {
        return nativeValue is Native
    }

    override public var sortname : SortName {
        return INT.h.sortname
    }
        
    override public var constants : [ConstName : Signature] {
        return INT.h.constants
    }
        
    override public func eval(name : ConstName, count : Int, nativeArgs : (Int) -> AnyHashable) -> AnyHashable {
        switch name.code {
        case INT.h.C_uminus.code: return -(nativeArgs(0) as! Native)
        case INT.h.C_plus.code: return (nativeArgs(0) as! Native) + (nativeArgs(1) as! Native)
        case INT.h.C_minus.code: return (nativeArgs(0) as! Native) - (nativeArgs(1) as! Native)
        case INT.h.C_mul.code: return (nativeArgs(0) as! Native) * (nativeArgs(1) as! Native)
        case INT.h.C_div.code: return (nativeArgs(0) as! Native) / (nativeArgs(1) as! Native)
        case INT.h.C_mod.code: return (nativeArgs(0) as! Native) % (nativeArgs(1) as! Native)
        case INT.h.C_leq.code: return (nativeArgs(0) as! Native) <= (nativeArgs(1) as! Native)
        case INT.h.C_less.code: return (nativeArgs(0) as! Native) < (nativeArgs(1) as! Native)
        case INT.h.C_ifNegative.code:
            let x = nativeArgs(0) as! Native
            if x >= 0 { return x } else { return nativeArgs(1) as! Native }
        case INT.h.C_min.code: return Swift.min(nativeArgs(0) as! Native, nativeArgs(1) as! Native)
        case INT.h.C_max.code: return Swift.max(nativeArgs(0) as! Native, nativeArgs(1) as! Native)
        default: fatalEval(name, count, nativeArgs)
        }
    }
        
    public static func == (left : INT, right : INT) -> BOOL {
        return BOOL.equals(left, right)
    }
    
    public static func != (left : INT, right : INT) -> BOOL {
        return !BOOL.equals(left, right)
    }
    
    public prefix static func -(operand : INT) -> INT {
        return INT(inhabitant: .App(const: h.C_uminus, args: [operand.inhabitant]))
    }
    
    public static func +(left : INT, right : INT) -> INT {
        return INT(inhabitant: .App(const: h.C_plus, args: [left.inhabitant, right.inhabitant]))
    }

    public static func -(left : INT, right : INT) -> INT {
        return INT(inhabitant: .App(const: h.C_minus, args: [left.inhabitant, right.inhabitant]))
    }

    public static func *(left : INT, right : INT) -> INT {
        return INT(inhabitant: .App(const: h.C_mul, args: [left.inhabitant, right.inhabitant]))
    }
    
    public static func /(left : INT, right : INT) -> INT {
        return INT(inhabitant: .App(const: h.C_div, args: [left.inhabitant, right.inhabitant]))
    }
    
    public static func %(left : INT, right : INT) -> INT {
        return INT(inhabitant: .App(const: h.C_mod, args: [left.inhabitant, right.inhabitant]))
    }

    public static func <=(left : INT, right : INT) -> BOOL {
        return BOOL(inhabitant: .App(const: h.C_leq, args: [left.inhabitant, right.inhabitant]))
    }

    public static func <(left : INT, right : INT) -> BOOL {
        return BOOL(inhabitant: .App(const: h.C_less, args: [left.inhabitant, right.inhabitant]))
    }

    public static func >=(left : INT, right : INT) -> BOOL {
        return BOOL(inhabitant: .App(const: h.C_leq, args: [right.inhabitant, left.inhabitant]))
    }

    public static func >(left : INT, right : INT) -> BOOL {
        return BOOL(inhabitant: .App(const: h.C_less, args: [right.inhabitant, left.inhabitant]))
    }
    
    public func IfNegative(_ x : INT) -> INT {
        return INT(inhabitant: .App(const: INT.h.C_ifNegative, args: [inhabitant, x.inhabitant]))
    }
    
    public static func min(_ left : INT, _ right : INT) -> INT {
        return INT(inhabitant: .App(const: h.C_min, args: [left.inhabitant, right.inhabitant]))
    }

    public static func max(_ left : INT, _ right : INT) -> INT {
        return INT(inhabitant: .App(const: h.C_max, args: [left.inhabitant, right.inhabitant]))
    }

    public func `in` <S : Sequence>(_ xs : S) -> BOOL where S.Element == INT {
        var result : BOOL = false
        for x in xs {
            result = result || self == x
        }
        return result
    }

    public func `in`(_ xs : INT...) -> BOOL {
        return `in`(xs)
    }
    
    public func inRange(_ lower : INT, _ upper : INT) -> BOOL {
        return lower <= self && self <= upper
    }
    
    public func match<T : Sort>(_ cases : Case<INT, T>..., `default` : T? = nil) -> T {
        var t = `default` ?? T.default()
        for c in cases.reversed() {
            t = (self == c.pattern).If(c.result, t)
        }
        return t
    }

}
