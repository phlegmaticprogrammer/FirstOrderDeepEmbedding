public class VarNamesOf : ComputationOnTerms {
    
    public typealias Result = Set<VarName>
    
    public init() { }
    
    public func computeVar(name: VarName) -> Result {
        return [name]
    }
    
    public func computeNative(value: AnyHashable, sort sortname: SortName) -> Result {
        return []
    }
    
    public func computeApp(const: ConstName, count: Int, args: (Int) -> Result) -> Result {
        var result : Result = []
        for i in 0 ..< count {
            result.formUnion(args(i))
        }
        return result
    }
    
}
