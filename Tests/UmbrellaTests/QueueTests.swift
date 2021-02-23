//
//  Created by Jeffrey Bergier on 2021/02/18.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import XCTest
@testable import Umbrella

class QueueTests: XCTestCase {
    
    // TODO: Add tests for append another quest
    // TODO: Add tests for removeAll()

    func test_init() {
        let q: Queue<Int> = [1,2,3]
        XCTAssertEqual(q._storage, [1,2,3])
    }
    
    func test_pop() {
        var q: Queue<Int> = [1,2,3]
        XCTAssertEqual(q.pop()!, 1)
        XCTAssertEqual(q.pop()!, 2)
        XCTAssertEqual(q._storage, [3])
    }
    
    func test_pop_nil() {
        var q: Queue<Int> = [1]
        XCTAssertEqual(q.pop()!, 1)
        XCTAssertNil(q.pop())
    }
    
    func test_append() {
        var q: Queue<Int> = [1,2,3]
        q.append(4)
        XCTAssertEqual(q._storage, [1,2,3,4])
    }
    
    func test_peek() {
        var q: Queue<Int> = [1,2,3]
        XCTAssertEqual(q.peek, 1)
        q.append(4)
        XCTAssertEqual(q.peek, 1)
    }
    
    func test_isEmpty() {
        var q: Queue<Int> = []
        XCTAssertTrue(q.isEmpty)
        q.append(4)
        XCTAssertFalse(q.isEmpty)
    }

}
