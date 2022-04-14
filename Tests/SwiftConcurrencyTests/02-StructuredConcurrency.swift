import XCTest
/*
## Structured Concurrency
Structured Concurrency is when we are in a concurrent context. When in an a structured conncurent context tasks are defined on methods and properties using the `async` keyword.

An async function is written with the `async` keyword after the parameter declerations
*/

func anAsyncFunction() async {
   // Lets do some work!
}

// For a method with a return type the *async* keyword is written before the return statement
func anAsyncFunctionWithAReturnType() async -> String {
   return "Hello, Concurrency!"
}

/* A property can have an async getter, but **not** a sync setter */
struct AsyncPropertySampleClass {

   var getter: String {
       get async {
           "Hello, getter only!"
       }
   }

   // Uncomment the following and try to build and you will get the error output "error: 'set' accessor cannot have specifier 'async'"
    private var setVariable: String = ""
   /*

   var setter: String {
       set async {
           setVariable = newValue
       }
       get {
           setVariable
       }
   }*/

    mutating func mutate(input: String) async {
        setVariable = input
    }
}


/* When using Structerd Concurrency the system keeps track of the tree of tasks.
 */

class StructuredConcurrencyTests: XCTestCase {

    func testAnAsyncTree() async {
        await anAsyncFunction()
        let result = await anAsyncFunctionWithAReturnType()
        let testClass = AsyncPropertySampleClass()
        let getResult = await testClass.getter

        print([result, getResult].joined(separator: " & "))
    }
}
