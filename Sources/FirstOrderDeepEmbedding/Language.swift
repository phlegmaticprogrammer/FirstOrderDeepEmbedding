import Foundation

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

public struct Signature : Hashable {
    public let args : [SortName?]
    public let result : SortName?
    public init(args : [SortName?], result : SortName?) {
        self.args = args
        self.result = result
    }
}

public indirect enum Term : Hashable, CustomStringConvertible {
    
    public typealias Id = TermStore.MutableId
    
    case Var(id : Id = Id(), name : AnyHashable)
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
        
    public func check(env : (AnyHashable) -> SortName?, term : Term) -> SortName? {
        switch term {
        case let .Var(id: _, name: name):
            return env(name)
        case let .Native(id: _, value: value, sort: sortname):
            guard let sort = _sorts[sortname] else { return nil }
            guard sort.isValid(nativeValue: value) else { return nil }
            return sortname
        case let .App(id: _, const: const, args: args):
            guard let signature = _constants[const] else { return nil }
            guard args.count == signature.args.count else { return nil }
            var polymorphic : SortName? = nil
            for (i, arg) in args.enumerated() {
                guard let ty = check(env: env, term: arg) else { return nil }
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
        }
    }
    
    public func check(store : TermStore, computed : TermStore.Computed<SortName?> = TermStore.Computed(), env : (AnyHashable) -> SortName?, id : TermStore.Id) -> SortName? {
        computed.compute(id: id) {
            switch store[id] {
            case let .Var(name: name):
                return env(name)
            case let .Native(value: value, sort: sortname):
                guard let sort = _sorts[sortname] else { return nil }
                guard sort.isValid(nativeValue: value) else { return nil }
                return sortname
            case let .App(const: const, args: args):
                guard let signature = _constants[const] else { return nil }
                guard args.count == signature.args.count else { return nil }
                var polymorphic : SortName? = nil
                for (i, arg) in args.enumerated() {
                    guard let ty = check(store: store, computed: computed, env: env, id: arg) else { return nil }
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

            }
        }
    }
    
    public func check<T : Sort>(_ t : T) -> Bool {
        guard t.isInhabited else { return false }
        let sortname = check(env: {_ in nil}, term: t.inhabitant)
        return sortname == t.sortname
    }
    
    public func eval(env : (AnyHashable) -> AnyHashable?, term : Term) -> AnyHashable {
        switch term {
        case let .Var(id: _, name: name):
            return env(name)!
        case let .Native(id: _, value: value, sort: _):
            return value
        case let .App(id: _, const: const, args: args):
            let sort = _sorts[const.sort]!
            return sort.eval(name: const, count: args.count) { index in
                eval(env: env, term: args[index])
            }
        }
    }
    
    public func eval<T : Sort>(_ t : T) -> AnyHashable {
        return eval(env: {_ in nil }, term: t.inhabitant)
    }
    
    public func customNamesOf(term : Term) -> Set<AnyHashable> {
        var names : Set<AnyHashable> = []
        func collect(_ term : Term) {
            switch term {
            case let .Var(id: _, name: name): names.insert(name)
            case .Native: break
            case let .App(id: _, const: _, args: args):
                for arg in args {
                    collect(arg)
                }
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
