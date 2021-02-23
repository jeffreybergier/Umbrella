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

class QueueResultTests: XCTestCase {
    
    func test_append_failure() {
        var q = Queue<Int>()
        let rO: Result<String, Int> = .failure(3)
        let rT = q.append(rO)
        XCTAssertEqual(rO, rT)
        XCTAssertEqual(q.pop()!, 3)
        XCTAssertNil(q.pop())
    }
    
    func test_append_success() {
        var q = Queue<Int>()
        let rO: Result<Int, String> = .success(4)
        let rT = q.append(rO)
        XCTAssertEqual(rO, rT)
        XCTAssertEqual(q.pop()!, 4)
        XCTAssertNil(q.pop())
    }
}

extension Int: Error {}
extension String: Error {}
