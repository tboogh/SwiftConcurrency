import Combine
import XCTest

class _9_AsyncStream: XCTestCase {

    /*
     `AsyncStream` can be used to bridge delegate based objects to concurrency.
     An stream can be awaited and the execution will be paused until an element
     is produced. The stream will block the continution until the Task it is
     contained is cancelled or the stream has finished.
     */

    func testAsyncStream() async throws {
        print("AsyncStream: Start!")
        for await value in asyncTimer {
            dump(value, name: "AsyncStream: ")
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        print("AsyncStream: Done!")
    }

    func testCancelAsyncStream() async throws {

        print("AsyncStream: Start!")
        for await value in asyncTimer {
            try Task.checkCancellation()
            dump(value, name: "AsyncStream: ")
            if value == 2 {
                withUnsafeCurrentTask { leTask in
                    leTask?.cancel()
                }
            }
        }
        print("AsyncStream: Done!")
    }

    var asyncTimer: AsyncStream<Int> {
        AsyncStream { continutation in

            let publisher: AnyPublisher<Int, Never> = Publishers.Sequence(sequence: Array(0...5))
                .eraseToAnyPublisher()
            let cancellable = publisher
                .handleEvents(receiveCompletion: { _ in
                    continutation.finish()
                })
                .sink { value in
                continutation.yield(value)
            }

            continutation.onTermination = { @Sendable _ in
                cancellable.cancel()
            }
        }
    }
}
