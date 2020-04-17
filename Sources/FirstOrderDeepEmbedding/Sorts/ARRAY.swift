public final class ARRAY<Elem : ASort> : ASort, ExpressibleByArrayLiteral {

    public typealias Native = Array<Elem.Native>
    
    public typealias ArrayLiteralElement = Elem

    private class H : SortMakingHelper {
                        
        var C_append : ConstName!
        var C_plus : ConstName!
        var C_contains : ConstName!
        var C_length : ConstName!
        var C_at : ConstName!
        
        init() {
            let elem = Elem().sortname
            super.init("ARRAY<\(elem)>")
            let bool = BOOL().sortname
            let int = INT().sortname
            C_append = add(op: "append", args: [sortname, elem], result: sortname)
            C_plus = add(op: "plus", args: [sortname, sortname], result: sortname)
            C_contains = add(op: "contains", args: [sortname, elem], result: bool)
            C_length = add(op: "length", args: [sortname], result: int)
            C_at = add(op: "at", args: [sortname, int], result: elem)
        }
        
    }
    
    private let h = H()
                    
    public required init() {
        super.init()
    }
    
    public init(arrayLiteral elements: Elem...) {
        super.init()
        var tm : Term = .Native(value: Native(), sort: sortname)
        for elem in elements {
            tm = .App(const: h.C_append, args: [tm, elem.inhabitant])
        }
        set(inhabitant: tm)
    }
    
    public override func setDefaultInhabitant() {
        set(inhabitant: .Native(value: Native(), sort: sortname))
    }
        
    public override func isValid(nativeValue : Any) -> Bool {
        return nativeValue is Native
    }

    override public var sortname : SortName {
        return h.sortname
    }
        
    override public var constants : [ConstName : Signature] {
        return h.constants
    }
        
    override public func eval(name : ConstName, count : Int, nativeArgs : (Int) -> AnyHashable) -> AnyHashable {
        switch name.code {
        case h.C_append.code:
            var array = (nativeArgs(0) as! Native)
            array.append(nativeArgs(1) as! Elem.Native)
            return array
        case h.C_plus.code: return (nativeArgs(0) as! Native) + (nativeArgs(1) as! Native)
        case h.C_contains.code: return (nativeArgs(0) as! Native).contains(nativeArgs(1) as! Elem.Native)
        case h.C_length.code: return (nativeArgs(0) as! Native).count
        case h.C_at.code: return (nativeArgs(0) as! Native)[nativeArgs(1) as! Int]
        default: fatalEval(name, count, nativeArgs)
        }
    }
        
    public static func == (left : ARRAY<Elem>, right : ARRAY<Elem>) -> BOOL {
        return BOOL.equals(left, right)
    }
    
    public static func != (left : ARRAY<Elem>, right : ARRAY<Elem>) -> BOOL {
        return !BOOL.equals(left, right)
    }
        
    public static func +(left : ARRAY<Elem>, right : ARRAY<Elem>) -> ARRAY<Elem> {
        return ARRAY<Elem>(inhabitant: .App(const: H().C_plus, args: [left.inhabitant, right.inhabitant]))
    }

    public static func +(left : ARRAY<Elem>, right : Elem) -> ARRAY<Elem> {
        return ARRAY<Elem>(inhabitant: .App(const: H().C_append, args: [left.inhabitant, right.inhabitant]))
    }
    
    public func contains(_ elem : Elem) -> BOOL {
        return BOOL(inhabitant: .App(const: h.C_contains, args: [self.inhabitant, elem.inhabitant]))
    }
    
    public var length : INT {
        return INT(inhabitant: .App(const: h.C_length, args: [self.inhabitant]))
    }
    
    public subscript(at : INT) -> Elem {
        let elem = Elem()
        elem.set(inhabitant: .App(const: h.C_at, args: [self.inhabitant, at.inhabitant]))
        return elem
    }
    
}

