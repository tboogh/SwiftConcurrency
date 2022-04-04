import XCTest

class TaskGroup: XCTestCase {

    /*
     # TaskGroup

     `TaskGroup` provides a way to group tasks as async/let but provide more advanced usages, such as reading values as they become avaiable and producing new tasks from the result.

     In the example below the tasks are add in sequence but the output order is not guaranteed to be the same as they are added in.
     */

    func testTaskGroup() async {

        let result = await withTaskGroup(of: String.self, returning: [String].self, body: { taskGroup in
            taskGroup.addTask {
                return await self.getValue("A")
            }
            taskGroup.addTask {
                return await self.getValue("B")
            }
            taskGroup.addTask {
                return await self.getValue("C")
            }

            var values = [String]()
            for await result in taskGroup {
                values.append(result)
            }
            return values
        })

        print("TaskGroup result: \(result)")
    }

    /*
     In the following example they delay causes the tasks to completed in a different order then they are defined. In the `for` loop that awaits the results from the task groups the values are added to the result array in a different order then they are defined.
     */

    func testTaskGroupWithDelay() async throws {

        let result = try await withThrowingTaskGroup(of: String.self, returning: [String].self, body: { taskGroup in
            taskGroup.addTask {
                return try await self.getValueWithDelay("A", 5)
            }
            taskGroup.addTask {
                return try await self.getValueWithDelay("B", 2)
            }
            taskGroup.addTask {
                return try await self.getValueWithDelay("C", 3)
            }

            var values = [String]()
            for try await result in taskGroup {
                print(result)
                values.append(result)
            }
            return values
        })

        print("TaskGroup result: \(result)")
    }

    /*
     In the next example we will define two tasks that we will use the the result of to determine the next tasks to be run.
     */
    func testTaskGroupWithDelayAdvanced() async throws {

        let result = try await withThrowingTaskGroup(of: String.self, returning: [String].self, body: { taskGroup in
            taskGroup.addTask {
                return try await self.getValueWithDelay("A", 2)
            }
            taskGroup.addTask {
                return try await self.getValueWithDelay("B", 4)
            }

            var values = [String]()
            for try await result in taskGroup {
                values.append(result)
            }

            for value in values {
                switch value {
                case "A":
                    taskGroup.addTask {
                        return try await self.getValueWithDelay("A100", 0)
                    }
                    break
                default: //B
                    taskGroup.addTask {
                        return try await self.getValueWithDelay("B100", 0)
                    }
                    break
                }
            }

            var results = [String]()
            for try await result in taskGroup {
                results.append(result)
            }
            return results
        })

        print("TaskGroup2 result: \(result)")
    }


    // MARK: - Helper functions

    func getValue(_ value: String) async -> String{
        return value
    }

    func getValueWithDelay<T>(_ value: T, _ delayInSeconds: UInt64) async throws -> T {
        try await Task.sleep(nanoseconds: delayInSeconds * 1_000_000_000)
        return value
    }
}
