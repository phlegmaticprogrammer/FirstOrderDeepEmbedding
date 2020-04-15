import Foundation

internal class SortRegistry {
        
    private static var registeredSorts : [SortName : Sort] = [:]
    
    private static let lock = NSLock()
    
    static func register(sort : Sort) -> Sort? {
        lock.lock()
        defer { lock.unlock() }
        let name = sort.sortname
        if let registeredSort = registeredSorts[name] {
            guard type(of: sort) == type(of: registeredSort) else { return nil }
            return registeredSort
        } else {
            registeredSorts[name] = sort
            return sort
        }
    }
    
}
