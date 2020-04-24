public final class OPTIONAL<Elem : ASort> : ASort, ExpressibleByNilLiteral {
    
    public enum Optional<E : Hashable> : Hashable {
        case None
        case Some(elem : E)
        
        var get : E? {
            switch self {
            case .None: return nil
            case let .Some(elem: e): return e
            }
        }
        
        static func from(_ elem : E?) -> Optional<E> {
            if let e = elem {
                return .Some(elem: e)
            } else {
                return .None
            }
        }
    }
    
    public typealias Native = Optional<Elem.Native>

    private class H : SortMakingHelper {
                        
        var C_otherwise : ConstName!
        var C_project : ConstName!
        var C_inject : ConstName!
        
        init() {
            let elem = Elem().sortname
            super.init("OPTIONAL<\(elem)>")
            C_otherwise = add(op: "otherwise", args: [sortname, elem], result: elem)
            C_project = add(op: "project", args: [sortname], result: elem)
            C_inject = add(op: "inject", args: [elem], result: sortname)
        }
        
    }
    
    private let h = H()
                    
    public required init() {
        super.init()
    }
    
    public init(_ optional : Elem.Native?) {
        super.init()
        set(inhabitant: .Native(value: Optional.from(optional), sort: sortname))
    }
    
    public init(_ elem : Elem) {
        super.init()
        set(inhabitant: .App(const: h.C_inject, args: [elem.inhabitant]))
    }
    
    public init(nilLiteral: ()) {
        super.init()
        set(inhabitant: .Native(value: Optional<Elem.Native>.None, sort: sortname))
    }

    public override func setDefaultInhabitant() {
        set(inhabitant: .Native(value: Optional<Elem.Native>.None, sort: sortname))
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
        case h.C_inject.code:
            let elem = nativeArgs(0) as! Elem.Native
            return Optional.from(elem)
        case h.C_project.code:
            let optElem = nativeArgs(0) as! Native
            return optElem.get!
        case h.C_otherwise.code:
            let elem = nativeArgs(0) as! Native
            switch elem {
            case .None: return nativeArgs(1) as! Elem.Native
            case let .Some(elem: elem): return elem
            }
        default: fatalEval(name, count, nativeArgs)
        }
    }
        
    public static func == (left : OPTIONAL<Elem>, right : OPTIONAL<Elem>) -> BOOL {
        return BOOL.equals(left, right)
    }
    
    public static func != (left : OPTIONAL<Elem>, right : OPTIONAL<Elem>) -> BOOL {
        return !BOOL.equals(left, right)
    }

    public static func == (left : OPTIONAL<Elem>, right : Elem.Native?) -> BOOL {
        return BOOL.equals(left, OPTIONAL(right))
    }

    public static func == (left : Elem.Native?, right : OPTIONAL<Elem>) -> BOOL {
        return BOOL.equals(OPTIONAL(left), right)
    }

    public static func != (left : OPTIONAL<Elem>, right : Elem.Native?) -> BOOL {
        return !BOOL.equals(left, OPTIONAL(right))
    }

    public static func != (left : Elem.Native?, right : OPTIONAL<Elem>) -> BOOL {
        return !BOOL.equals(OPTIONAL(left), right)
    }
    
    public static func ??(left : OPTIONAL<Elem>, right : Elem) -> Elem {
        let elem = Elem()
        elem.set(inhabitant: .App(const: H().C_otherwise, args: [left.inhabitant, right.inhabitant]))
        return elem
    }

    public var get : Elem {
        let elem = Elem()
        elem.set(inhabitant: .App(const: h.C_project, args: [inhabitant]))
        return elem
    }
}

