import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ValidationCoreTests.allTests),
    ]
}
#endif
