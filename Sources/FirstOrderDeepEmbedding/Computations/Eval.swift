public class Eval : ComputationOnTerms {
    
    public typealias Result = AnyHashable
    
    private let language : Language
    private let environment : Environment<AnyHashable>
    
    public init(language : Language, environment : @escaping Environment<AnyHashable>) {
        self.language = language
        self.environment = environment
    }
    
    public func computeVar(name: VarName) -> AnyHashable {
        return environment(name)!
    }
    
    public func computeNative(value: AnyHashable, sort: SortName) -> AnyHashable {
        return value
    }
    
    public func computeApp(const: ConstName, count: Int, args: (Int) -> AnyHashable) -> AnyHashable {
        let sort = language.sortOf(const.sort)!
        return sort.eval(name: const, count: count, nativeArgs: args)
    }

}
