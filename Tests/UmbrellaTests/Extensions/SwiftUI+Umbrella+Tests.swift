//
//  Created by Jeffrey Bergier on 2022/09/12.
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
import ViewInspector
import SwiftUI
import Umbrella

class SwiftUI_Umbrella_Tests: AsyncTestCase {
    
    func test_onLoadChange_sync() throws {
        let wait = self.newWait()
        let value = "String"
        let v = Color.clear.onLoadChange(of: value, async: false) { newValue in
            wait {
                XCTAssertEqual(newValue, value)
            }
        }
        try v.inspect().callOnAppear()
        self.wait(for: .instant)
    }
    
    /*
    // TODO: Fix when ViewInspector supports calling Task
    func test_onLoadChange_async() throws {
        let wait = self.newWait()
        let value = "String"
        let v = Color.clear.onLoadChange(of: value, async: true) { newValue in
            wait {
                XCTAssertEqual(newValue, value)
            }
        }
        try v.inspect().callTask()
        self.wait(for: .instant)
    }
    */
}
