import Foundation

public indirect enum StoredTerm : Hashable {
    
    public typealias Id = TermStore.Id
    
    case Var(name : AnyHashable)
    
    case Native(value : AnyHashable, sort : SortName)
    
    case App(const : ConstName, args : [Id])

}

public class TermStore {
    
    public typealias Id = Int
    
    public class MutableId : Hashable {
        
        private var _id : Id?
        
        public init() {
            self._id = nil
        }
        
        public static func == (left : MutableId, right : MutableId) -> Bool {
            return left._id == right._id
        }
        
        public var id : Id {
            return _id!
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(_id)
        }
        
        public var isDefined : Bool {
            return _id != nil
        }
                
        func set(_ compute : @autoclosure () throws -> Id) rethrows -> Id {
            if _id != nil { return _id! }
            _id = try compute()
            return _id!
        }
        
    }
    
    private var idOfStoredTerms : [StoredTerm : Id] = [:]
    
    private var storedTerms : [StoredTerm] = []
    
    public subscript(id : Id) -> StoredTerm {
        return storedTerms[id]
    }
    
    public subscript(stored : StoredTerm) -> Id {
        return idOfStoredTerms[stored]!
    }
    
    public var count : Int {
        return storedTerms.count
    }
    
    private func store(stored : StoredTerm) -> Id {
        if let id = idOfStoredTerms[stored] {
            return id
        } else {
            let id = storedTerms.count
            storedTerms.append(stored)
            idOfStoredTerms[stored] = id
            return id
        }
    }
    
    public func size(_ id : Id) -> Int {
        var computed : Set<Id> = []
        func compute(_ id : Id) -> Int {
            if !computed.insert(id).inserted { return 0 }
            switch self[id] {
            case .Var: return 1
            case .Native: return 1
            case let .App(const: _, args: args):
                var sum = 1
                for arg in args {
                    sum += size(arg)
                }
                return sum
            }
        }
        return compute(id)
    }
    
    public func store(_ term : Term) -> Id {
        switch term {
        case let .App(id: id, const: constname, args: args):
            return id.set(store(stored: .App(const: constname, args: args.map(store))))
        case let .Native(id: id, value: value, sort: sortname):
            return id.set(store(stored: .Native(value: value, sort: sortname)))
        case let .Var(id: id, name: name):
            return id.set(store(stored: .Var(name: name)))
        }
    }
    
}
