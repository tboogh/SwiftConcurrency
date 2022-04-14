import XCTest
final class UnstructuredConcurrencyTests: XCTestCase {
    /*
     ## Unstructured Concurrency

     To access a context where we can run Tasks in a context before the intruduction of concurrency we need to use unstructured concurrency. This is where we need to manually start a task where we can run the unit of work that we want to run concurrentely.

     This will start a parallel execution of task that will not block the current thread. This is equivalant to using the `async` method on a `DispatchQueue` to run code that doesn't block the current thread. Such as performing a slower unit of work that does not block the UI.

     Inside the body of the task we are now in a context where we can use *Structured Concurrency*.
     */

    func testAsync() async {
        await testTwoAsync()
        await testThreeAsync()
    }

    func testTwoAsync() async {
        await testThreeAsync()
    }

    func testThreeAsync() async {
        await testTwoAsync()
    }

    func testTask() {
        let task = Task {
            
            func test() async {
                await Task {
                    print("hello")
                }
            }

            await test()
        }
    }
}
