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
import TestUmbrella
@testable import Umbrella

class MappedListTests: AsyncTestCase {
    
    func test_lazy_mapping() {
        let data = [1,3,5,9,20]
        let wait = self.newWait(count: 3)
        let lazyMap: MappedList<Int, String> = MappedList(data) { input in
            wait() {
                // Make sure items 2 and 3 are never accesed so we know its lazy
                XCTAssertNotEqual(input, 3)
                XCTAssertNotEqual(input, 5)
            }
            return String(input * 2)
        }
        self.do(after: .instant) {
            XCTAssertEqual(lazyMap[0], "2")
        }
        self.do(after: .short) {
            XCTAssertEqual(lazyMap[3], "18")
        }
        self.do(after: .short) {
            XCTAssertEqual(lazyMap[4], "40")
        }
        self.wait(for: .medium)
    }
    
}
