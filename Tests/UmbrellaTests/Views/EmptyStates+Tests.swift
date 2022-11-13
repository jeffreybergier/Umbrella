//
//  Created by Jeffrey Bergier on 2022/09/02.
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
import SwiftUI
import ViewInspector
import Umbrella

class EmptyStates_Tests: XCTestCase {
    
    let full = "This is Full"
    let empty = "This is Empty"
    
    func test_collectionEmpty() {
        let source = [String]()
        let view = source.view { _ in
            Text(self.full)
        } onEmpty: {
            Text(self.empty)
        }
        XCTAssertNil(try? view.inspect().find(text: self.full))
        XCTAssertNotNil(try view.inspect().find(text: self.empty))
    }
    
    func test_collectionFull() {
        let source = ["Hello World"]
        let view = source.view {
            Text(self.full)
            Text($0.first!)
        } onEmpty: {
            Text(self.empty)
        }
        XCTAssertNotNil(try view.inspect().find(text: self.full))
        XCTAssertNotNil(try view.inspect().find(text: source.first!))
        XCTAssertNil(try? view.inspect().find(text: self.empty))
    }
    
    func test_NIL() {
        let source: String? = nil
        let view = source.view { _ in
            Text(self.full)
        } onNIL: {
            Text(self.empty)
        }
        XCTAssertNil(try? view.inspect().find(text: self.full))
        XCTAssertNotNil(try view.inspect().find(text: self.empty))
    }
    
    func test_notNIL() {
        let source: String? = "Hello World"
        let view = source.view {
            Text(self.full)
            Text($0)
        } onNIL: {
            Text(self.empty)
        }
        XCTAssertNotNil(try view.inspect().find(text: self.full))
        XCTAssertNotNil(try view.inspect().find(text: source!))
        XCTAssertNil(try? view.inspect().find(text: self.empty))
    }
}
