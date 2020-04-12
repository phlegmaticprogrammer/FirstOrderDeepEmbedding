public typealias SortName = String

public struct ConstName : Hashable, CustomStringConvertible {
    public let sort : SortName
    public let name : String?
    public let code : Int
    
    public init(sort : SortName, name : String?, code : Int) {
        self.sort = sort
        self.name = name
        self.code = code
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(sort)
        hasher.combine(code)
    }
        
    public static func == (left : ConstName, right : ConstName) -> Bool {
        return left.code == right.code && left.sort == right.sort
    }
    
    public var description : String {
        return "\(sort).\(name ?? "(code=\(code)")"
    }
}

public typealias VarName = AnyHashable

public struct Signature : Hashable {
    
    public enum T : Hashable {
        case monomorph(name : SortName)
        case polymorph
    }
    
    public let args : [T]
    public let result : T
    
    public init(args : [T], result : T) {
        self.args = args
        self.result = result
    }
    
    public init(args : [SortName], result : SortName) {
        self.args = args.map { arg in T.monomorph(name: arg) }
        self.result = .monomorph(name: result)
    }
}

public indirect enum Term : Hashable, CustomStringConvertible {
    
    public typealias Id = TermStore.MutableId
    
    case Var(id : Id = Id(), name : VarName)
    case Native(id : Id = Id(), value : AnyHashable, sort : SortName)
    case App(id : Id = Id(), const : ConstName, args : [Term])
    
    public var description : String {
        switch self {
        case let .Var(id: _, name: name): return "\(name)"
        case let .Native(id: _, value : value, sort : sort): return "\(value) : \(sort)"
        case let .App(id: _, const, args):
            guard !args.isEmpty else { return const.description }
            var descr = const.description
            descr.append("(")
            var first = true
            for a in args {
                if first {
                    first = false
                } else {
                    descr.append(",")
                }
                descr.append("\(a)")
            }
            descr.append(")")
            return descr
        }
    }

}

public typealias Environment<R> = (VarName) -> R?

public class Language {
        
    private var _sorts : [SortName : Sort]
    private var _constants : [ConstName : Signature]
            
    public init() {
        self._sorts = [:]
        self._constants = [:]
    }
    
    private func add(name : ConstName, signature : Signature) {
        precondition(_constants[name] == nil)
        guard(isValid(signature: signature)) else {
            fatalError("invalid signature for \(name): \(signature)")
        }
        _constants[name] = signature
    }

    public func add(sort : Sort) {
        let name = sort.sortname
        precondition(_sorts[name] == nil)
        _sorts[name] = sort
        for (constname, signature) in sort.constants {
            precondition(constname.sort == name)
            add(name: constname, signature: signature)
        }
    }
        
    public func isValid(sort : SortName) -> Bool {
        return _sorts[sort] != nil
    }
    
    public func sortOf(_ sort : SortName) -> Sort? {
        return _sorts[sort]
    }
    
    public func signatureOf(_ constant : ConstName) -> Signature? {
        return _constants[constant]
    }
    
    private func isValid(_ t : Signature.T) -> Bool {
        switch t {
        case .polymorph: return true
        case let .monomorph(name: name): return isValid(sort: name)
        }
    }
    
    public func isValid(signature : Signature) -> Bool {
        guard isValid(signature.result) else { return false }
        var polymorphicArgs = false
        for arg in signature.args {
            if arg == .polymorph { polymorphicArgs = true }
            guard isValid(arg) else { return false }
        }
        return polymorphicArgs || signature.result != .polymorph
    }
        
    public func check(env : @escaping Environment<SortName>, term : Term) -> SortName? {
        let sortOf = SortOf(language: self, environment: env)
        return term.compute(sortOf)
    }
        
    public func check<T : Sort>(_ t : T) -> Bool {
        guard t.isInhabited else { return false }
        let sortname = check(env: {_ in nil}, term: t.inhabitant)
        return sortname == t.sortname
    }
    
    public func eval(env : @escaping Environment<AnyHashable>, term : Term) -> AnyHashable {
        return term.compute(Eval(language: self, environment: env))
    }
    
    public func eval<T : Sort>(_ t : T) -> AnyHashable {
        return eval(env: {_ in nil }, term: t.inhabitant)
    }
    
    public func varNamesOf(term : Term) -> Set<VarName> {
        return term.compute(VarNamesOf())
    }
        
    public static var standard : Language {
        let language = Language()
        language.add(sort: UNIT())
        language.add(sort: BOOL())
        language.add(sort: INT())
        return language
    }
        
}
