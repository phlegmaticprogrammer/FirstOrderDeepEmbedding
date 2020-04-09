import Foundation

public indirect enum PackedTerm : Hashable {
    
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
    
    private var idOfPackedTerms : [PackedTerm : Id] = [:]
    
    private var packedTerms : [PackedTerm] = []
    
    public subscript(id : Id) -> PackedTerm {
        return packedTerms[id]
    }
    
    public subscript(packed : PackedTerm) -> Id {
        return idOfPackedTerms[packed]!
    }
    
    public var count : Int {
        return packedTerms.count
    }
    
    private func store(_ packed : PackedTerm) -> Id {
        if let id = idOfPackedTerms[packed] {
            return id
        } else {
            let id = packedTerms.count
            packedTerms.append(packed)
            idOfPackedTerms[packed] = id
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
    
}
