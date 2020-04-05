import Foundation

open class Enumeration<EnumBase : CaseIterable & Hashable> : ASort {
        
    public typealias Native = EnumBase
    
    public static func Case(_ base : EnumBase) -> Self {
        let e : Enumeration<EnumBase> = Self.init()
        e.set(inhabitant: .Native(value: base, sort: e.sortname))
        return e as! Self
    }
    
    public required init() {
        super.init()
    }
    
    public override var constants : [ConstName : Signature] { return [:] }
    
    public override func isValid(nativeValue: Any) -> Bool {
        return nativeValue is Native
    }
    
    public override var sortname : String {
        return String(describing: Self.self)
    }
    
    public override func setDefaultInhabitant() {
        guard let base = EnumBase.allCases.first else { fatalError("There is no default inhabitant as enumeration \(sortname) has no cases.") }
        set(inhabitant: .Native(value: base, sort: sortname))
    }
    
    public static func ==(left : Enumeration, right : Enumeration) -> BOOL {
        return BOOL.equals(left, right)
    }
    
    public static func ==(left : Enumeration, right : EnumBase) -> BOOL {
        return BOOL.equals(left, Case(right))
    }
        
    public static func ==(left : EnumBase, right : Enumeration) -> BOOL {
        return BOOL.equals(Case(left), right)
    }
    
    public override func eval(name: ConstName, count: Int, nativeArgs: (Int) -> Any) -> Any {
        fatalEval(name, count, nativeArgs)
    }

    public func In <S : Sequence>(_ xs : S) -> BOOL where S.Element == Self {
        var result : BOOL = false
        for x in xs {
            result = (result && self == x)
        }
        return result
    }

    public func `in` <S : Sequence>(_ xs : S) -> BOOL where S.Element == EnumBase {
        var result : BOOL = false
        for x in xs {
            result = (result && self == Self.Case(x))
        }
        return result
    }
    
    public func Match<T : Sort>(_ cases : Case<Enumeration, T>..., default : T? = nil) -> T {
        var t = `default` ?? T.default()
        for c in cases.reversed() {
            t = (self == c.pattern).If(c.result, t)
        }
        return t
    }

    public func match<T : Sort>(_ cases : Case<EnumBase, T>..., default : T? = nil) -> T {
        var t = `default` ?? T.default()
        for c in cases.reversed() {
            t = (self == Self.Case(c.pattern)).If(c.result, t)
        }
        return t
    }

    
}
