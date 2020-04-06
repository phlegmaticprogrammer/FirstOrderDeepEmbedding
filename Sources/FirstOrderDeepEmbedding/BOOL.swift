import Foundation

public final class BOOL : ASort, ExpressibleByBooleanLiteral {
    
    public typealias BooleanLiteralType = Bool

    public typealias Native = Bool

    private class H : SortMakingHelper {
        
        var C_false : ConstName!
        var T_false : Term!

        var C_true : ConstName!
        var T_true : Term!
        
        var C_equals : ConstName!
        
        var C_not : ConstName!

        var C_and : ConstName!
        
        var C_or : ConstName!
        
        var C_if : ConstName!
        
        init() {
            super.init("BOOL")
            (C_false, T_false) = add(name: "false", result: sortname)
            (C_true, T_true) = add(name: "true", result: sortname)
            C_equals = add(op: "equals", args: [nil, nil], result: sortname)
            C_not = add(op: "not", args: [sortname], result: sortname)
            C_and = add(op: "and", args: [sortname, sortname], result: sortname)
            C_or = add(op: "or", args: [sortname, sortname], result: sortname)
            C_if = add(op: "if", args: [sortname, nil, nil], result: nil)
        }
        
    }
    
    private static let h = H()
                    
    public required init() {
        super.init()
    }
    
    public init(booleanLiteral: BooleanLiteralType) {
        super.init()
        set(inhabitant: booleanLiteral ? BOOL.h.T_true : BOOL.h.T_false)
    }

    public init(_ boolean: Native) {
        super.init()
        set(inhabitant: boolean ? BOOL.h.T_true : BOOL.h.T_false)
    }
    
    public override func setDefaultInhabitant() {
        set(inhabitant: BOOL.h.T_false)
    }
        
    public override func isValid(nativeValue : Any) -> Bool {
        return nativeValue is Native
    }

    override public var sortname : SortName {
        return BOOL.h.sortname
    }
        
    override public var constants : [ConstName : Signature] {
        return BOOL.h.constants
    }
    
    override public func eval(name : ConstName, count : Int, nativeArgs : (Int) -> Any) -> Any {
        switch name.code {
        case BOOL.h.C_false.code: return false
        case BOOL.h.C_true.code: return true
        case BOOL.h.C_equals.code: return (nativeArgs(0) as! AnyHashable) == (nativeArgs(1) as! AnyHashable)
        case BOOL.h.C_not.code: return !(nativeArgs(0) as! Native)
        case BOOL.h.C_and.code: return (nativeArgs(0) as! Native) && (nativeArgs(1) as! Native)
        case BOOL.h.C_or.code: return (nativeArgs(0) as! Native) || (nativeArgs(1) as! Native)
        case BOOL.h.C_if.code: return nativeArgs(nativeArgs(0) as! Native ? 1 : 2)
        default: fatalEval(name, count, nativeArgs)
        }
    }
    
    public static func equals<T : Sort>(_ left : T, _ right : T) -> BOOL {
        return BOOL(inhabitant: .App(const: h.C_equals, args: [left.inhabitant, right.inhabitant]))
    }
        
    public static func ==(left : BOOL, right : BOOL) -> BOOL {
        return equals(left, right)
    }

    public static func !=(left : BOOL, right : BOOL) -> BOOL {
        return !equals(left, right)
    }
    
    public prefix static func !(operand : BOOL) -> BOOL {
        return BOOL(inhabitant: .App(const: h.C_not, args: [operand.inhabitant]))
    }
    
    public static func &&(left : BOOL, right : BOOL) -> BOOL {
        return BOOL(inhabitant: .App(const: h.C_and, args: [left.inhabitant, right.inhabitant]))
    }
    
    public static func ||(left : BOOL, right : BOOL) -> BOOL {
        return BOOL(inhabitant: .App(const: h.C_or, args: [left.inhabitant, right.inhabitant]))
    }
    
    public func If<T : Sort>(_ caseTrue : T, _ caseFalse : T) -> T {
        let t = T()
        t.set(inhabitant: .App(const: BOOL.h.C_if, args: [inhabitant, caseTrue.inhabitant, caseFalse.inhabitant]))
        return t
    }
    
    public static let True : BOOL = true
    
    public static let False : BOOL = false

}
