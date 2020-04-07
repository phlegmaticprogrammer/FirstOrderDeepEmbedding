import Foundation

infix operator => : AssignmentPrecedence

public struct Case<Pattern, Result> {
    public let pattern : Pattern
    public let result : Result
}b

public func => <Pattern, Result>(pattern : Pattern, result : Result) -> Case<Pattern, Result> {
    return Case(pattern: pattern, result: result)
}
