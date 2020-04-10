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
    
    public typealias Environment<R> = (AnyHashable) -> R?
    
    public class SortOf : ComputationOnTerms {
        
        public typealias Result = SortName?
        
        private let language : Language
        private let environment : Environment<SortName>
        
        public init(language : Language, environment : @escaping Environment<SortName>) {
            self.language = language
            self.environment = environment
        }
        
        public func computeVar(name: AnyHashable) -> SortName? {
            return environment(name)
        }
        
        public func computeNative(value: AnyHashable, sort sortname: SortName) -> SortName? {
            guard let sort = language._sorts[sortname] else { return nil }
            guard sort.isValid(nativeValue: value) else { return nil }
            return sortname
        }
        
        public func computeApp(const: ConstName, count: Int, args: (Int) -> SortName?) -> SortName? {
            guard let signature = language._constants[const] else { return nil }
            guard count == signature.args.count else { return nil }
            var polymorphic : SortName? = nil
            for i in 0 ..< count {
                guard let ty = args(i) else { return nil }
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
    
    public class Eval : ComputationOnTerms {
        
        public typealias Result = AnyHashable
        
        private let language : Language
        private let environment : Environment<AnyHashable>
        
        public init(language : Language, environment : @escaping Environment<AnyHashable>) {
            self.language = language
            self.environment = environment
        }
        
        public func computeVar(name: AnyHashable) -> AnyHashable {
            return environment(name)!
        }
        
        public func computeNative(value: AnyHashable, sort: SortName) -> AnyHashable {
            return value
        }
        
        public func computeApp(const: ConstName, count: Int, args: (Int) -> AnyHashable) -> AnyHashable {
            let sort = language._sorts[const.sort]!
            return sort.eval(name: const, count: count, nativeArgs: args)
        }

    }
        
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
