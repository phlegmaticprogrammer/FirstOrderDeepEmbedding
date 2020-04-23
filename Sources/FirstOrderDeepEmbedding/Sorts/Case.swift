infix operator => : AssignmentPrecedence

public struct Case<Pattern, Result> {
    public let pattern : Pattern
    
    public let result : Result
    
    public init(pattern : Pattern, result : Result) {
        self.pattern = pattern
        self.result = result
    }
}

public func => <Pattern, Result>(pattern : Pattern, result : Result) -> Case<Pattern, Result> {
    return Case(pattern: pattern, result: result)
}
