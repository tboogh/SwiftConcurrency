import XCTest

class AsyncLet: XCTestCase {

    /*
     # Async/let

     `async let` is used to define a variable that will contain the result of task when completed. As in all usages of concurrency no work is performed until the `await` keyword is used.
     */

    func testAsyncLet() async {
        async let asyncLetA = getValue("A")
        async let asyncLetB = getValue("B")
        async let asyncLetC = getValue("C")
        let result = await [asyncLetA,
                            asyncLetB,
                            asyncLetC]
        print("Async let result: \(result)")
    }

    /*
     In the following example the async functions use a delay to complete at different times. Even though the tasks complete at different times the final array is only returned when all the tasks contained in it have completed.
     */

    func testAsyncLetWithRandomTimer() async throws {
        async let asyncLetA = getValueWithDelay("A", 5)
        async let asyncLetB = getValueWithDelay("B", 2)
        async let asyncLetC = getValueWithDelay("C", 3)
        print("Start parent")
//        try await Task.sleep(nanoseconds: 10_000_000_000)
        print("Wait parent")
        let result = try await [asyncLetA,
                                asyncLetB,
                                asyncLetC]
        print("Async let result: \(result)")
    }

    func testTaskAsyncLetWithRandomTimer() async throws {
        let taskA = Task { try await getValueWithDelay("A", 5) }
        let taskB = Task { try await getValueWithDelay("B", 2) }
        taskB.cancel()
        let taskC = Task { try await getValueWithDelay("C", 3) }
        print("Start parent")

        print("Wait parent")
        let resultTaskA = try await taskA.value
        NSLog("TaskA")
        let resultTaskB = try await taskB.value
        NSLog("TaskB")
        let resultTaskC = try await taskC.value
        NSLog("TaskC")
        let result = [resultTaskA, resultTaskB, resultTaskC]
        print("Async let result: \(result)")
    }

    func testForAsyncLetWithRandomTimer() async throws {
        async let asyncLetA = getValueWithDelay("A", 5)
        async let asyncLetB = getValueWithDelay("B", 2)
        async let asyncLetC = getValueWithDelay("C", 3)
        let result = try await [asyncLetA,
                                asyncLetB,
                                asyncLetC]
        print("Async let result: \(result)")
    }

    // MARK: - Helper functions

    func getValue(_ value: String) async -> String{
        print(value)
        return value
    }

    func getValueWithDelay(_ value: String, _ delayInSeconds: UInt64) async throws -> String{
        print("start \(value)")
        try Task.checkCancellation()
        try await Task.sleep(nanoseconds: delayInSeconds * 1_000_000_000)
        print(value)
        return value
    }
}
