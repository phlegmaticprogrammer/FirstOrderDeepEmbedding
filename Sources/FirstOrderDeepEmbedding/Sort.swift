func abstractMethod(_ name : String) -> Never {
    fatalError("cannot call abstract method '\(name)'")
}

open class Sort {
    
    private var _inhabitant : Term?
    
    public required init() {
        _inhabitant = nil
    }
    
    convenience init(inhabitant : Term) {
        self.init()
        set(inhabitant: inhabitant)
    }
            
    open func set(inhabitant : Term) {
        guard _inhabitant == nil else {
            fatalError("cannot inhabit \(sortname), it is already inhabited")
        }
        _inhabitant = inhabitant
    }
    
    open func setDefaultInhabitant() {
        fatalError("there is no default inhabitant for \(sortname)")
    }
            
    open var sortname : SortName {
        abstractMethod("Sort.sortname")
    }

    public final var isInhabited : Bool {
        return _inhabitant != nil
    }

    public final var inhabitant : Term {
        return _inhabitant!
    }
        
    open var constants : [ConstName : Signature] {
        abstractMethod("Sort.constants")
    }
    
    open func isValid(nativeValue: Any) -> Bool {
        abstractMethod("Sort.isValid")
    }
        
    open func eval(name : ConstName, count : Int, nativeArgs : (Int) -> AnyHashable) -> AnyHashable {
        fatalEval(name, count, nativeArgs)
    }

    public final func fatalEval(_ constname : ConstName, _ count : Int, _ args : (Int) -> Any) -> Never {
        fatalError("sort \(sortname) cannot evaluate call to \(constname) (\(count) parameters)")
    }
    
    public static func `default`() -> Self {
        let e : Sort = Self()
        e.setDefaultInhabitant()
        return e as! Self
    }
    
    public static func Var(_ name : AnyHashable) -> Self {
        let e : Sort = Self()
        e.set(inhabitant: .Var(name: name))
        return e as! Self
    }
    
    public static func unpack<T>(count : Int, args : (Int) -> T) -> [T] {
        return (0 ..< count).map { index in args(index) }
    }

}

open class SortMakingHelper {
    
    public let sortname : SortName
    
    public var constants : [ConstName : Signature]
    
    public init(_ sortname : SortName) {
        self.sortname = sortname
        self.constants = [:]
    }
    
    private func T(_ sortname : SortName?) -> Signature.T {
        if let name = sortname {
            return .monomorph(name: name)
        } else {
            return .polymorph
        }
    }
    
    public func add(op : String, args : [SortName?] = [], result : SortName?) -> ConstName {
        let constname = ConstName(sort: sortname, name: op, code: constants.count)
        precondition(constants[constname] == nil)
        let signature = Signature(args: args.map(T), result: T(result))
        constants[constname] = signature
        return constname
    }
    
    public func add(name : String, result : SortName?) -> (ConstName, Term) {
        let constname = add(op: name, result: result)
        return (constname, .App(const: constname, args: []))
    }
        
}

public protocol HasAssociatedNativeType {
    
    associatedtype Native : Hashable
    
    init()
    
    func set(inhabitant : Term)
    
    var sortname : SortName { get }

}

public extension HasAssociatedNativeType {
    
    static func from(_ native : Native) -> Self {
        let t = Self()
        t.set(inhabitant: .Native(value: native, sort: t.sortname))
        return t
    }
    
}

public typealias ASort = Sort & HasAssociatedNativeType
