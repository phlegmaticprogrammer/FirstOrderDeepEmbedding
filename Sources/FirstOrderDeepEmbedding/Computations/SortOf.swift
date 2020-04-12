public class SortOf : ComputationOnTerms {
    
    public typealias Result = SortName?
    
    private let language : Language
    private let environment : Environment<SortName>
    
    public init(language : Language, environment : @escaping Environment<SortName>) {
        self.language = language
        self.environment = environment
    }
    
    public func computeVar(name: VarName) -> SortName? {
        return environment(name)
    }
    
    public func computeNative(value: AnyHashable, sort sortname: SortName) -> SortName? {
        guard let sort = language.sortOf(sortname) else { return nil }
        guard sort.isValid(nativeValue: value) else { return nil }
        return sortname
    }
    
    public func computeApp(const: ConstName, count: Int, args: (Int) -> SortName?) -> SortName? {
        guard let signature = language.signatureOf(const) else { return nil }
        guard count == signature.args.count else { return nil }
        var polymorphic : SortName? = nil
        for i in 0 ..< count {
            guard let ty = args(i) else { return nil }
            switch signature.args[i] {
            case let .monomorph(name: sigTy):
                if ty != sigTy { return nil }
            case .polymorph:
                if polymorphic == nil {
                    polymorphic = ty
                } else if polymorphic! != ty {
                    return nil
                }
            }
        }
        switch signature.result {
        case let .monomorph(name: sigTy):
            return sigTy
        case .polymorph:
            return polymorphic
        }
    }
    
}
