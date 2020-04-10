fileprivate protocol FIELD {
        
    var sort : Sort { get }
    
}

@propertyWrapper
public final class Field<Value : Sort> : FIELD {

    private let field : Value = Value()
    
    fileprivate var sort : Sort {
        return field
    }
    
    public init() {}
    
    public var wrappedValue : Value {
        get {
            return field
        }
        set {
            field.set(inhabitant: newValue.inhabitant)
        }
    }
    
}

open class Record : ASort {
    
    private static let INIT : String = "init"
    private static let INIT_code : Int = -1
        
    private var fields : [(name: String, field: FIELD)] = []
            
    public required init() {
        super.init()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let fieldname = child.label else { continue }
            guard fieldname.starts(with: "_") else { continue }
            let name = String(fieldname.dropFirst())
            guard let field = child.value as? FIELD else { continue }
            precondition(name != Record.INIT)
            fields.append((name: name, field: field))
        }
    }
        
    open override var sortname : String {
        return String(describing: Self.self)
    }
        
    public override func set(inhabitant : Term) {
        var inhabitants : [String] = []
        for f in fields {
            if f.field.sort.isInhabited { inhabitants.append(f.name) }
        }
        if !inhabitants.isEmpty {
            fatalError("cannot inhabit, some record fields are already inhabited: \(inhabitants)")
        }
        super.set(inhabitant: inhabitant)
        populateFields()
    }
    
    public override func setDefaultInhabitant() {
        if isInhabited {
            fatalError("cannot populate record, it is already inhabited")
        }
        var inhabitants : [Term] = []
        for f in fields {
            if f.field.sort.isInhabited {
                inhabitants.append(f.field.sort.inhabitant)
            } else {
                f.field.sort.setDefaultInhabitant()
                inhabitants.append(f.field.sort.inhabitant)
            }
        }
        let c_init = ConstName(sort: sortname, name: Record.INIT, code: Record.INIT_code)
        super.set(inhabitant: .App(const: c_init, args: inhabitants))
    }
                
    private func populateFields() {
        for (code, f) in fields.enumerated() {
            if f.field.sort.isInhabited {
                fatalError("cannot populate fields as field '\(f.name)' is already populated")
            }
            f.field.sort.set(inhabitant: Term.App(const: ConstName(sort: sortname, name: f.name, code: code), args: [inhabitant]))
        }
    }
    
    private lazy var _constants : [ConstName : Signature] = computeConstants()
    
    public override var constants : [ConstName : Signature] {
        return _constants
    }
    
    private func computeConstants() -> [ConstName : Signature] {
        var consts : [ConstName : Signature] = [:]
        let sortnames = fields.map { f in f.field.sort.sortname }
        let sortname = self.sortname
        consts[ConstName(sort: sortname, name: Record.INIT, code: Record.INIT_code)] = Signature(args: sortnames, result: sortname)
        for (code, f) in fields.enumerated() {
            consts[ConstName(sort: sortname, name: f.name, code: code)] = Signature(args: [sortname], result: f.field.sort.sortname)
        }
        return consts
    }
    
    public typealias Native = [AnyHashable]
    
    public override func isValid(nativeValue : Any) -> Bool {
        guard let native = nativeValue as? Native else { return false }
        guard native.count == fields.count else { return false }
        for (i, value) in native.enumerated() {
            let f = fields[i]
            guard f.field.sort.isValid(nativeValue: value) else { return false }
        }
        return true
    }
    
    public static func == (left : Record, right : Record) -> BOOL {
        return BOOL.equals(left, right)
    }
        
    public static func != (left : Record, right : Record) -> BOOL {
        return !BOOL.equals(left, right)
    }

    public override func eval(name : ConstName, count : Int, nativeArgs : (Int) -> AnyHashable) -> AnyHashable {
        if name.code == Record.INIT_code {
            return unpack(count: count, args: nativeArgs)
        } else {
            return (nativeArgs(0) as! Native)[name.code]
        }
    }
    
}
