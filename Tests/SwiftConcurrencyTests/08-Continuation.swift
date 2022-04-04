import XCTest

final class ContinuationTests: XCTestCase {

    /*
     Bridging completion block based code with Swift Concurrency is done by using a mechanism called continuation. We will demonstrate the this using a service that does some async work and calls a completion handler with a string.
     */

    class SingleValueCompletionBasedService {

        enum SingleValuError: Error {
            case testError
        }

        func getSomeData(completion: @escaping (String) -> Void) {
            completion("Hello, World!")
        }

        func getSomeThrowingErrors(completion: @escaping (Result<String, Error>) -> Void) {
            completion(.failure(SingleValuError.testError))
        }

        func getNothing(completion: @escaping () -> Void) {
            completion()
        }
    }

    /* A simple test using the service */

    func testCompletion() {
        let service = SingleValueCompletionBasedService()

        service.getSomeData { result in
            print(result)
        }
    }

    /*
     Too convert the completion based service we will use `withCheckedContinuation` which provides a closure with a `CheckedContinuation<T, Never>`. When the `withCheckedContinuation` is awaited the current execution suspends as in other tasks. The closure is then called and when the result is ready the method `resume(returning:)` can be used to set the tasks result. When that is done the task will finish and the execution will continue.
     */

    func testCompletionContinuation() async {
        let service = SingleValueCompletionBasedService()
        let result = await withCheckedContinuation { continuation in
            service.getSomeData { value in
                continuation.resume(returning: value)
            }
        }

        print(result)
    }

    /*
     Calling `resume(returning:)` more then once in a closure is a programming error. When developing `withCheckedContinuation` can be used to ensure correctness. It includes additional internal checks that ensure errors are caught in development. Test the following two examples, the first one uses `withCheckedContinuation` and the second uses `withUnsafeContinuation`
     */

    func testCompletionContinuationError() async {
        let service = SingleValueCompletionBasedService()
        let result: String = await withCheckedContinuation { continuation in
            service.getSomeData { value in
                continuation.resume(returning: value)
                continuation.resume(returning: value)
            }
        }

        print(result)
    }

    func testCompletionUnsafeContinuationError() async {
        let service = SingleValueCompletionBasedService()
        let result: String = await withUnsafeContinuation { continuation in
            service.getSomeData { value in
                continuation.resume(returning: value)
                continuation.resume(returning: value)
            }
        }

        print(result)
    }

    /*
     `withUnsafeContinuation` does not have the internal checks that help catch these errors and is optimized for interop with non-async mechanisms. The two are interchangable and can be easily substituted during development and before deployment.
     */

    /*
     There are two versions of both the checked and unsafe version of continuation that support throwing errors.
     */

    func testCheckedThrowingContinuationWithError() async throws {
        let service = SingleValueCompletionBasedService()
        let result = try await withCheckedThrowingContinuation { continuation in
            service.getSomeThrowingErrors { result in
                continuation.resume(with: result)
            }
        }

        print(result)
    }

    func testUnsafeThrowingContinuationWithError() async throws {
        let service = SingleValueCompletionBasedService()
        let result = try await withUnsafeThrowingContinuation { continuation in
            service.getSomeThrowingErrors { result in
                continuation.resume(with: result)
            }
        }

        print(result)
    }

    /*
     `Continuation.resume` supports multiple ways to resume execution. It can be used with a single value:
     */

    func testResumeReturning() async throws {
        let service = SingleValueCompletionBasedService()
        let result: String = try await withCheckedThrowingContinuation { continuation in
            service.getSomeThrowingErrors { result in
                continuation.resume(returning: "Done!")
            }
        }

        print(result)
    }

    /*
     It supports throwing an error if used in a throwing continuation:
     */

    func testResumeThrowing() async throws {
        let service = SingleValueCompletionBasedService()
        let result: String = try await withCheckedThrowingContinuation { continuation in
            service.getSomeThrowingErrors { result in
                continuation.resume(throwing: SingleValueCompletionBasedService.SingleValuError.testError)
            }
        }

        print(result)
    }

    /*
     It supports Swift.Result:
     */

    func testResumeResult() async throws {
        let service = SingleValueCompletionBasedService()
        let result: String = try await withCheckedThrowingContinuation { continuation in
            service.getSomeThrowingErrors { result in
                continuation.resume(with: result)
            }
        }

        print(result)
    }

    /*
     And it supports being used with no values in "empty" completion blocks.
     */

    func testResumeVoid() async throws {
        let service = SingleValueCompletionBasedService()
        try await withCheckedThrowingContinuation { continuation in
            service.getNothing {
                continuation.resume()
            }
        }
    }
}
