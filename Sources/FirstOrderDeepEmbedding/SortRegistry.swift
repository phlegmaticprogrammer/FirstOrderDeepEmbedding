import Foundation

internal class SortRegistry {
    
    class Id : Hashable {
        
        public static func == (left : Id, right : Id) -> Bool {
            return left === right
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self))
        }
        
    }
    
    private static var registeredSorts : [SortName : (Id, Sort)] = [:]
    
    private static let lock = NSLock()
    
    static func register(sort : Sort) -> (Id, Sort) {
        lock.lock()
        defer {
            lock.unlock()
        }
        let name = sort.sortname
        if let result = registeredSorts[name] {
            return result
        } else {
            let id = Id()
            let result = (id, sort)
            registeredSorts[name] = result
            return result
        }
    }
    
}
