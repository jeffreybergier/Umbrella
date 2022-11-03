//
//  Created by Jeffrey Bergier on 2022/09/10.
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
import Umbrella

class Swift_Umbrella_Tests: XCTestCase {

    func test_result_success() {
        let r: Result<String, Error> = .success("-1")
        XCTAssertEqual(r.value, "-1")
        XCTAssertNil(r.error)
    }
    
    func test_result_failure() {
        let error = NSError(domain: "test", code: -1)
        let r: Result<String, NSError> = .failure(error)
        XCTAssertNil(r.value)
        XCTAssertEqual(r.error?.domain, "test")
        XCTAssertEqual(r.error?.code, -1)
    }
    
    func test_result_reduce() {
        let r1: Result<String, NSError> = .success("-1")
        let r2 = r1.reduce {
            XCTAssertEqual($0, "-1")
            return .success("-3")
        }
        let r3 = r2.reduce {
            XCTAssertEqual($0, "-3")
            let output: Result<Int, NSError> = .failure(NSError(domain: "test", code: -5))
            return output
        }
        XCTAssertEqual(r2.value, "-3")
        XCTAssertEqual(r3.error?.domain, "test")
        XCTAssertEqual(r3.error?.code, -5)
    }
    
}
