import Foundation

public protocol ComputationOnTerms {

    associatedtype Result

    func computeVar(name : AnyHashable) -> Result
    
    func computeNative(value : AnyHashable, sort : SortName) -> Result
    
    func computeApp(const : ConstName, count : Int, args : (Int) -> Result) -> Result
    
}

public extension Term {

    func compute<C : ComputationOnTerms, R>(_ computation : C) -> R where C.Result == R {
        switch self {
        case let .Var(id: _, name: name): return computation.computeVar(name: name)
        case let .Native(id: _, value: value, sort: sort): return computation.computeNative(value: value, sort: sort)
        case let .App(id: _, const: const, args: args):
            var results = [R?](repeating: nil, count: args.count)
            func get(index : Int) -> R {
                if let r = results[index] {
                    return r
                } else {
                    let r = args[index].compute(computation)
                    results[index] = r
                    return r
                }
            }
            return computation.computeApp(const: const, count: args.count, args: get)
        }
    }

}

public protocol ComputedResultsOfStoredTerms {
    
    associatedtype Result

    func compute(id : TermStore.Id, _ comp : () -> Result) -> Result
        
}

public extension TermStore {
    
    func computeAll<C : ComputationOnTerms, R>(_ computation : C) -> [R] where C.Result == R {
        var results : [R] = []
        
        func compute(_ term : StoredTerm) -> R {
            switch term {
            case let .Var(name: name): return computation.computeVar(name: name)
            case let .Native(value: value, sort: sort): return computation.computeNative(value: value, sort: sort)
            case let .App(const: const, args: args):
                func get(index : Int) -> R {
                    return results[args[index]]
                }
                return computation.computeApp(const: const, count: args.count, args: get)
            }
        }
        
        for i in 0 ..< count {
            results.append(compute(self[i]))
        }
        
        return results
    }
    
    final class Results<Result> : ComputedResultsOfStoredTerms {
        
        private var results : [TermStore.Id : Result]

        public init() {
            self.results = [:]
        }
        
        public func compute(id : TermStore.Id, _ computation : () -> Result) -> Result {
            if let result = results[id] {
                return result
            } else {
                let result = computation()
                results[id] = result
                return result
            }
        }
        
        public subscript(id : TermStore.Id) -> Result? {
            return results[id]
        }
        
    }
        
    func compute<C : ComputationOnTerms, Results : ComputedResultsOfStoredTerms>(_ computation : C, results : Results, id : TermStore.Id) -> C.Result where C.Result == Results.Result {
        results.compute(id: id) {
            switch self[id] {
            case let .Var(name: name): return computation.computeVar(name: name)
            case let .Native(value: value, sort: sort): return computation.computeNative(value: value, sort: sort)
            case let .App(const: const, args: args):
                func get(index : Int) -> C.Result {
                    return compute(computation, results: results, id: args[index])
                }
                return computation.computeApp(const: const, count: args.count, args: get)
            }
        }
    }
    
    func compute<C : ComputationOnTerms>(_ computation : C, id : TermStore.Id) -> C.Result {
        return compute(computation, results: Results(), id: id)
    }
    
}
