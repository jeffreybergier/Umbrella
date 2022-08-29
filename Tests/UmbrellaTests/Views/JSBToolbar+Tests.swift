//
//  Created by Jeffrey Bergier on 2022/08/29.
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
@testable import Umbrella

class JSBToolbar_Tests: XCTestCase {
    
    func test_baseStyles() {
        _ = {
            let test = JSBToolbarButtonStyleDone
            XCTAssertNil(test.buttonRole)
            XCTAssertTrue(type(of: test.labelStyle) == TitleOnlyLabelStyle.self)
            XCTAssertTrue(type(of: test.outerModifier) == JSBToolbarButtonDone.self)
            XCTAssertTrue(type(of: test.innerModifier) == EmptyModifier.self)
        }()
        
        _ = {
            let test = JSBToolbarButtonStyleCancel
            XCTAssertEqual(test.buttonRole, .cancel)
            XCTAssertTrue(type(of: test.labelStyle) == TitleOnlyLabelStyle.self)
            XCTAssertTrue(type(of: test.outerModifier) == EmptyModifier.self)
            XCTAssertTrue(type(of: test.innerModifier) == EmptyModifier.self)
        }()
        
        _ = {
            let test = JSBToolbarButtonStyleDelete
            XCTAssertEqual(test.buttonRole, .destructive)
            XCTAssertTrue(type(of: test.labelStyle) == TitleOnlyLabelStyle.self)
            XCTAssertTrue(type(of: test.outerModifier) == EmptyModifier.self)
            XCTAssertTrue(type(of: test.innerModifier) == EmptyModifier.self)
        }()
    }
    
}
