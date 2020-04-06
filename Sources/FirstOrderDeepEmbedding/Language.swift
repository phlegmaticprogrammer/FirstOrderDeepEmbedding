import Foundation

public typealias SortName = String

public struct ConstName : Hashable, CustomStringConvertible {
    let sort : SortName
    let name : String?
    let code : Int

    public func hash(into hasher: inout Hasher) {
        hasher.combine(sort)
        hasher.combine(code)
    }
        
    public static func == (left : ConstName, right : ConstName) -> Bool {
        return left.code == right.code && left.sort == right.sort
    }
    
    public var description : String {
        if let n = name {
            return "\(sort).\(n)"
        } else {
            return "\(sort).(code=\(code))"
        }
    }
}

public struct Signature : Hashable {
    let args : [SortName?]
    let result : SortName?
}

public indirect enum Term : Hashable, CustomStringConvertible {
    case Custom(name : AnyHashable)
    case Var(index : Int)
    case Native(value : AnyHashable, sort : SortName)
    case App(const : ConstName, args : [Term])
    case Let(name : String?, rhs : Term, body : Term)
    
    public var description : String {
        switch self {
        case let .Custom(name: name): return "\(name)"
        case let .Var(index : index): return "Var \(index)"
        case let .Native(value : value, sort : _): return "{\(value)}"
        case let .App(const, args):
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
        default: fatalError()
        }
    }
}

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
    
    public func isValid(signature : Signature) -> Bool {
        guard signature.result == nil || isValid(sort: signature.result!) else { return false }
        var polymorphicArgs = false
        for sort in signature.args {
            if sort == nil { polymorphicArgs = true }
            guard sort == nil || isValid(sort: sort!) else { return false }
        }
        return polymorphicArgs || signature.result != nil
    }
        
    public func check(customEnv : (AnyHashable) -> SortName?, env : [SortName], term : Term) -> SortName? {
        switch term {
        case let .Custom(name: name):
            return customEnv(name)
        case let .Var(index: index):
            guard index >= 0 && index < env.count else { return nil }
            return env[env.count - 1 - index]
        case let .Native(value: value, sort: sortname):
            guard let sort = _sorts[sortname] else { return nil }
            guard sort.isValid(nativeValue: value) else { return nil }
            return sortname
        case let .App(const: const, args: args):
            guard let signature = _constants[const] else { return nil }
            guard args.count == signature.args.count else { return nil }
            var polymorphic : SortName? = nil
            for (i, arg) in args.enumerated() {
                guard let ty = check(customEnv: customEnv, env: env, term: arg) else { return nil }
                if let sigTy = signature.args[i] {
                    if ty != sigTy { return nil }
                } else if polymorphic == nil {
                    polymorphic = ty
                } else if polymorphic! != ty {
                    return nil
                }
            }
            if let sigTy = signature.result {
                return sigTy
            } else {
                return polymorphic
            }
        case let .Let(name: _, rhs: rhs, body : body):
            guard let ty = check(customEnv: customEnv, env: env, term: rhs) else { return nil }
            var newEnv = env
            newEnv.append(ty)
            return check(customEnv: customEnv, env: newEnv, term: body)
        }
    }
    
    public func check<T : Sort>(_ t : T) -> Bool {
        guard t.isInhabited else { return false }
        return check(customEnv: {_ in nil}, env: [], term: t.inhabitant) == t.sortname
    }
    
    public func eval(customEnv : (AnyHashable) -> Any?, env : [Any], term : Term) -> Any {
        switch term {
        case let .Custom(name: name):
            return customEnv(name)!
        case let .Var(index: index):
            precondition(index >= 0 && index < env.count)
            return env[env.count - 1 - index]
        case let .Native(value: value, sort: _):
            return value
        case let .App(const: const, args: args):
            let sort = _sorts[const.sort]!
            return sort.eval(name: const, count: args.count) { index in
                eval(customEnv: customEnv, env: env, term: args[index])
            }
        case let .Let(name: _, rhs: rhs, body : body):
            let x = eval(customEnv: customEnv, env: env, term: rhs)
            var newEnv = env
            newEnv.append(x)
            return eval(customEnv: customEnv, env: newEnv, term: body)
        }
    }
    
    public func eval<T : Sort>(_ t : T) -> Any {
        return eval(customEnv: {_ in nil }, env: [], term: t.inhabitant)
    }
    
    public func customNamesOf(term : Term) -> Set<AnyHashable> {
        var names : Set<AnyHashable> = []
        func collect(_ term : Term) {
            switch term {
            case let .Custom(name: name): names.insert(name)
            case .Var: break
            case .Native: break
            case let .App(const: _, args: args):
                for arg in args {
                    collect(arg)
                }
            case let .Let(name: _, rhs: rhs, body: body):
                collect(rhs)
                collect(body)
            }
        }
        collect(term)
        return names
    }
        
    public static var standard : Language {
        let language = Language()
        language.add(sort: UNIT())
        language.add(sort: BOOL())
        language.add(sort: INT())
        return language
    }
        
}
