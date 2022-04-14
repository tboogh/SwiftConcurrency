import XCTest

final class IntroTests: XCTestCase {

    /*
    ## What are tasks?
    To explaing tasks we first need to understand what concurrency is. If you think of a list of tasks you need to perform, we can define that as something *serial*. A number tasks you will perform in order, one after the other. Next we define *concurrency*. This is the same list of tasks, but instead of performing them in order we group the tasks in smaller segments in ask our friends for help and do them in parallel. A task can be described as one of the segments, or unit of works.

    A computer consists of a CPU which consists of multiple cores which can perform work in parallel. Tasks use these multiple cores to perform multiple tasks at the same time. Since there is a limited number of cores available in a CPU there is a limit to how many tasks that can be performed at once. An operating system often devides these cores into *threads*.

     A task in Swift is generic that has two parts, the value and the error. A function that runs a task can be written as follows:

    To start a task we need to prefix it with the keyword *await*. This can only be done in a context that can await tasks.
     */

    func testExample() async throws {
        
        DispatchQueue.main.async {
            print("Async")
        }

        func say() async -> String {
            "Hello, world"
        }

        let result = await say()
        dump(result, name: "Intro:")
    }

    /*
     The keywork *await* tells the compiler that we want to halt execution on the current *thread* and run the work in the async method or property. When done the execution of the code on the current thread will continue. Traditionally in Swift this was done using DispatchQueue's and completion blocks. This required the developer to write complext nested code that we will not visit here and happily imagine never existed. If you want to now more about that subject you can [google it](https://www.google.com/search?q=dispatch+queue+nested+completion+handler&client=safari&rls=en&sxsrf=APq-WBt2zcAekwTZJbn5alqiMJ7Ghehziw%3A1648835718183&ei=hjxHYr_HCuf1qwHKr6SADw&ved=0ahUKEwi_opnat_P2AhXn-ioKHcoXCfAQ4dUDCA0&uact=5&oq=dispatch+queue+nested+completion+handler&gs_lcp=Cgdnd3Mtd2l6EAM6BwgAEEcQsANKBAhBGABKBAhGGABQuwJYlxtg2xxoBnABeACAAXKIAa4IkgEDOC40mAEAoAEByAECwAEB&sclient=gws-wiz)
     */
}
