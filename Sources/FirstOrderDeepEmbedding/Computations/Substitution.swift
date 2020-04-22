public class Substitution : FirstOrderDeepEmbedding.ComputationOnTerms {
    
    public typealias Result = Term
    
    private let substitution : (VarName) -> Term?
    
    public init(substitution : @escaping (VarName) -> Term?) {
        self.substitution = substitution
    }
    
    public func computeVar(name: VarName) -> Term {
        if let term = substitution(name) {
            return term
        } else {
            return .Var(name: name)
        }
    }
    
    public func computeNative(value: AnyHashable, sort: SortName) -> Term {
        return .Native(value: value, sort: sort)
    }
    
    public func computeApp(const: ConstName, count: Int, args: (Int) -> Term) -> Term {
        let substitutedArgs = (0 ..< count).map { i in args(i) }
        return .App(const: const, args: substitutedArgs)
    }

}
