//
//  Created by Jeffrey Bergier on 2021/02/22.
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
import TestUmbrella

class PublishQueueTests: AsyncTestCase {

    func test_publish_initial() {
        let queue = PublishQueue<Int>()
        let wait = self.newWait(count: 1)
        queue.$current.sink { newValue in
            wait() { XCTAssertNil(newValue?.value) }
        }.store(in: &self.tokens)
        self.wait(for: .short)
    }
    
    func test_publish_append() {
        let queue = PublishQueue<Int>()
        let wait = self.newWait(count: 2)
        var hitOnce = false
        queue.$current.sink { newValue in
            wait() {
                if hitOnce {
                    XCTAssertEqual(newValue?.value, 5)
                } else {
                    XCTAssertNil(newValue?.value)
                }
            }
            hitOnce = true
        }.store(in: &self.tokens)
        queue.queue.append(5)
        self.wait(for: .short)
    }
    
    // when swiftUI dismisses the alert / sheet
    // it automatically sets the binding to nil
    // the queue is expected to fill it with the next item
    // if there is another item.
    func test_publish_swiftUI_dequeue() {
        let queue = PublishQueue<Int>()
        let wait = self.newWait(count: 5)
        var hitCount = 0
        queue.$current.sink { newValue in
            wait() {
                switch hitCount {
                case 0:
                    XCTAssertNil(newValue?.value)
                case 1:
                    XCTAssertEqual(newValue?.value, 5)
                case 2:
                    XCTAssertNil(newValue?.value)
                case 3:
                    XCTAssertEqual(newValue?.value, 10)
                case 4:
                    XCTAssertNil(newValue?.value)
                default:
                    XCTFail()
                }
            }
            hitCount += 1
        }.store(in: &self.tokens)
        
        queue.queue.append(5)
        queue.queue.append(10)
        self.do(after: .short) {
            // after this 10 should appear
            queue.current = nil
        }
        self.do(after: .medium) {
            // after this nil should stay as there are no more items
            queue.current = nil
        }
        
        self.wait(for: .long)
    }
    
}
