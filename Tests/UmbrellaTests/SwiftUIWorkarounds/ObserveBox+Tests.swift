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
import TestUmbrella
import Combine
import Umbrella

class ObserveBox_Tests: AsyncTestCase {
    
    var observe = Set<AnyCancellable>()
    
    func test_yes_publish() {
        let wait = self.newWait(count: 2)
        let box = ObserveBox(0)
        XCTAssertEqual(box.value, 0)
        box.objectWillChange.sink { _ in
            wait { XCTAssertEqual(box.value, 0) }
        }.store(in: &self.observe)
        box.objectDidChange.sink { _ in
            wait { XCTAssertEqual(box.value, 1) }
        }.store(in: &self.observe)
        box.value = 1
        self.wait(for: .instant)
    }
    
}
