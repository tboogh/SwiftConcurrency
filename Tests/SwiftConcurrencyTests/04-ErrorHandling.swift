import XCTest

class ErrorHandling: XCTestCase {

    /*:
    # Error handling
     Tasks in Swift Concurrency handle errors by using the try/catch pattern. This is a step away from the Result<Success, Error> pattern that is used in many closures. To indicate that a method can throws an error the `throws` keyword is added after the `async` keyword:
     */

    func aAsyncThrowingFunction() async throws {
        // Lets do some work, or throw an error 😱!
        throw NSError(domain: "😱", code: 666)

    }

    func testThrow() async throws {
        try await aAsyncThrowingFunction()
    }

    /*:
     The syntax is similar for an async property:
     */

    struct AsyncThrowingPropertySampleClass {

        var getter: String {
            get async throws {
                "Hello, getter only that can throw an error 😱!"
            }
        }
    }
}
