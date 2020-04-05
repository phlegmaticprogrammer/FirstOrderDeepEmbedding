import Foundation

func abstractMethod(_ name : String) -> Never {
    fatalError("cannot call abstract method '\(name)'")
}

func unpack<T>(count : Int, args : (Int) -> T) -> [T] {
    return (0 ..< count).map { index in args(index) }
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

    convenience init?<Native : Hashable>(nativeValue : Native) {
        self.init()
        guard isValid(nativeValue: nativeValue) else { return nil }
        set(inhabitant: .Native(value: nativeValue, sort: sortname))
    }
        
    public func set(inhabitant : Term) {
        guard _inhabitant == nil else {
            fatalError("cannot inhabit \(sortname), it is already inhabited")
        }
        _inhabitant = inhabitant
    }
    
    public func setDefaultInhabitant() {
        fatalError("there is no default inhabitant for \(sortname)")
    }
            
    public var sortname : SortName {
        abstractMethod("Sort.sortname")
    }

    public final var isInhabited : Bool {
        return _inhabitant != nil
    }

    public final var inhabitant : Term {
        return _inhabitant!
    }
        
    public var constants : [ConstName : Signature] {
        abstractMethod("Sort.constants")
    }
    
    public func isValid(nativeValue: Any) -> Bool {
        abstractMethod("Sort.isValid")
    }
        
    public func eval(name : ConstName, count : Int, nativeArgs : (Int) -> Any) -> Any {
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

}

open class SortMakingHelper {
    
    public let sortname : SortName
    
    public var constants : [ConstName : Signature]
    
    public init(_ sortname : SortName) {
        self.sortname = sortname
        self.constants = [:]
        let m = Mirror(reflecting: self)
        print("description of helper = '\(m.description)'")
        print("Self.type = '\(Self.self)'")
    }
    
    public func add(op : String, args : [SortName?] = [], result : SortName?) -> ConstName {
        let constname = ConstName(sort: sortname, name: op, code: constants.count)
        precondition(constants[constname] == nil)
        let signature = Signature(args: args, result: result)
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
    
}

public typealias ASort = Sort & HasAssociatedNativeType
