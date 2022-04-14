import XCTest
class CancellationTests: XCTestCase {

    /* ## Task Cancellation
     When a task is run it will peform it's unit of work and will continue to live until it is done. This is, if we do not explicitly cancel the task. Cancellation of a task does not stop or halt it's execution. It is up to us to define the behaviour of the task when it is cancelled. This can be to abort the execution, return a partial result or not result at all.

     When in a structured concurrency context we have two options to check cancellation. We can use the propery `Task.isCancelled` to check if the task has been cancelled. We can also call the throwing static function `Task.checkCancellation()

     Handeling cancellation is in my opinion required, any tasks that are started need to have a plan to how they handle cancellation. In certain circumstances a task needs to perform all of its work and not stop or cancel that work before it is complete. But in many cases it saves on resources and allows other work to be performed.

     When using structured concurrency cancelling a task that has one or more child tasks will cancel that group of tasks.

     In the following example a parent task is defined, but before we run it we cancel it. Since there are no checks for cancellation the print statements will be run.
     */


    func testCancellationDemoWithoutCancellationChecks() async {
        let demoTask = Task {

            func parentTask() async  {
                print("Hello, CancellationDemoWithoutCancellationChecks! \(Task.isCancelled)")
                await firstChildTask()
                await secondChildTask()
            }

            func firstChildTask() async  {
                print("Hello, first child task! \(Task.isCancelled)")
            }

            func secondChildTask() async {
                print("Hello, second child task! \(Task.isCancelled)")
            }

            /*
             Hello, CancellationDemoWithoutCancellationChecks! true
             Hello, first child task! true
             Hello, second child task! true
             */

            await parentTask()
        }
        demoTask.cancel()
        await demoTask.value
    }

    /*:

     In the next demo there are checks for cancellation and the prints in the child tasks will not run. When running tasks in a structured concurrency context a cancellation of the parent task will propogate to all the child tasks.

     */

    func testCancellationDemoWithCancellationChecks() async {
        let demoTask = Task {
            func parentTask() async  {
                print("Hello, CancellationDemoWithCancellationChecks!")
                await firstChildTask()
                await secondChildTask()
            }

            func firstChildTask() async  {
                print("First is cancelled: \(Task.isCancelled)")
            }

            func secondChildTask() async {
                print("Second is cancelled: \(Task.isCancelled)")
            }

            await parentTask()
        }
        demoTask.cancel()
        await demoTask.value
    }

    /*

     Cancellation can also be done with try/catch by using the `Task.checkCancellation()` method
     */
    func testCancellationDemoWithThrowingCancellationChecks() async throws {
        let demoTask = Task {
            func parentTask() async throws {
                print("Hello, CancellationDemoWithCancellationChecks! \(Task.isCancelled)")
                try await firstChildTask()
                try await secondChildTask()
            }

            func firstChildTask() async throws {
                try Task.checkCancellation()
                print("First is cancelled: \(Task.isCancelled)")
            }

            func secondChildTask() async throws {
                try Task.checkCancellation()
                print("Second is cancelled: \(Task.isCancelled)")
            }

            try await parentTask()
        }
        demoTask.cancel()
        try await demoTask.value
    }

    /*:
     *Very important*
     If mixing structured and unstructured concurrency the cancellation will not propogate. In the first example both tasks are cancelled but in the following the second task will not be.
     */

    func testCancellationDemoWithMixedConcurrency() async throws {
        let demoTask = Task {
            func parentTask() async throws {
                print("Hello, CancellationDemoWithMixedConcurrency!")
                try await firstChildTask()
                let task = try secondChildTask()
                await task.value
            }

            func firstChildTask() async throws {
                print("First is cancelled: \(Task.isCancelled)")
            }

            func secondChildTask() throws -> Task<Void, Never> {

                return Task {
                    do {
                        try Task.checkCancellation()
                        print("Second is cancelled: \(Task.isCancelled)")
                    } catch {
                        // :feelsbadman
                    }
                }
            }

            try await parentTask()
        }

        demoTask.cancel()
        try await demoTask.value
    }

    /*
     Tasks can be cancelled using using the `withUnsafeCurrentTask` method whic
     makes a best effort to the current task.
     */

    func testCancellationDemoWithUnsafeCurrentTask() async {
        func parentTask() async  {
            print("Hello, CancellationDemoWithCancellationChecks!")
            await firstChildTask()
            await secondChildTask()
        }

        func firstChildTask() async  {
            print("First is cancelled: \(Task.isCancelled)")
            withUnsafeCurrentTask { task in
                task?.cancel()
            }
        }

        func secondChildTask() async {
            print("Second is cancelled: \(Task.isCancelled)")
        }

        await parentTask()
    }
}
