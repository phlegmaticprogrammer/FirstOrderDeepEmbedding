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
        
        public var isEmpty : Bool {
            return _id == nil
        }
        
        func set(_ compute : @autoclosure () throws -> Id) rethrows -> Id {
            if _id != nil { return _id! }
            _id = try compute()
            return _id!
        }
    }
    
    private var idOfPackedTerms : [PackedTerm : Id] = [:]
    
    private var packedTerms : [PackedTerm] = []
    
}
