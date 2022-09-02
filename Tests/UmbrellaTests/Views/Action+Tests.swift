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

class Action_Tests: XCTestCase {
    func test_style_init() {
        _ = {
            let s = ActionStyleImp()
            XCTAssertNil(s.buttonRole)
            XCTAssertTrue(type(of: s.labelStyle) == DefaultLabelStyle.self)
            XCTAssertTrue(type(of: s.outerModifier) == EmptyModifier.self)
            XCTAssertTrue(type(of: s.innerModifier) == EmptyModifier.self)
        }()
        _ = {
            let s = ActionStyleImp(buttonRole: .cancel)
            XCTAssertEqual(s.buttonRole, .cancel)
            XCTAssertTrue(type(of: s.labelStyle) == DefaultLabelStyle.self)
            XCTAssertTrue(type(of: s.outerModifier) == EmptyModifier.self)
            XCTAssertTrue(type(of: s.innerModifier) == EmptyModifier.self)
        }()
        _ = {
            let s = ActionStyleImp(buttonRole: .destructive,
                                   innerModifier: TEST_InnerModifier())
            XCTAssertEqual(s.buttonRole, .destructive)
            XCTAssertTrue(type(of: s.labelStyle) == DefaultLabelStyle.self)
            XCTAssertTrue(type(of: s.outerModifier) == EmptyModifier.self)
            XCTAssertTrue(type(of: s.innerModifier) == TEST_InnerModifier.self)
        }()
        _ = {
            let s = ActionStyleImp(buttonRole: .destructive,
                                   labelStyle: TitleOnlyLabelStyle())
            XCTAssertEqual(s.buttonRole, .destructive)
            XCTAssertTrue(type(of: s.labelStyle) == TitleOnlyLabelStyle.self)
            XCTAssertTrue(type(of: s.outerModifier) == EmptyModifier.self)
            XCTAssertTrue(type(of: s.innerModifier) == EmptyModifier.self)
        }()
        _ = {
            let s = ActionStyleImp(buttonRole: nil,
                                   outerModifier: TEST_OuterModifier())
            XCTAssertNil(s.buttonRole)
            XCTAssertTrue(type(of: s.labelStyle) == DefaultLabelStyle.self)
            XCTAssertTrue(type(of: s.outerModifier) == TEST_OuterModifier.self)
            XCTAssertTrue(type(of: s.innerModifier) == EmptyModifier.self)
        }()
        _ = {
            let s = ActionStyleImp(buttonRole: .destructive,
                                   outerModifier: TEST_OuterModifier(),
                                   innerModifier: TEST_InnerModifier())
            XCTAssertEqual(s.buttonRole, .destructive)
            XCTAssertTrue(type(of: s.labelStyle) == DefaultLabelStyle.self)
            XCTAssertTrue(type(of: s.outerModifier) == TEST_OuterModifier.self)
            XCTAssertTrue(type(of: s.innerModifier) == TEST_InnerModifier.self)
        }()
        _ = {
            let s = ActionStyleImp(buttonRole: .destructive,
                                   labelStyle: IconOnlyLabelStyle(),
                                   outerModifier: TEST_OuterModifier())
            XCTAssertEqual(s.buttonRole, .destructive)
            XCTAssertTrue(type(of: s.labelStyle) == IconOnlyLabelStyle.self)
            XCTAssertTrue(type(of: s.outerModifier) == TEST_OuterModifier.self)
            XCTAssertTrue(type(of: s.innerModifier) == EmptyModifier.self)
        }()
        _ = {
            let s = ActionStyleImp(buttonRole: .cancel,
                                   labelStyle: IconOnlyLabelStyle(),
                                   innerModifier: TEST_InnerModifier())
            XCTAssertEqual(s.buttonRole, .cancel)
            XCTAssertTrue(type(of: s.labelStyle) == IconOnlyLabelStyle.self)
            XCTAssertTrue(type(of: s.outerModifier) == EmptyModifier.self)
            XCTAssertTrue(type(of: s.innerModifier) == TEST_InnerModifier.self)
        }()
        _ = {
            let s = ActionStyleImp(buttonRole: .cancel,
                                   labelStyle: IconOnlyLabelStyle(),
                                   outerModifier: TEST_OuterModifier(),
                                   innerModifier: TEST_InnerModifier())
            XCTAssertEqual(s.buttonRole, .cancel)
            XCTAssertTrue(type(of: s.labelStyle) == IconOnlyLabelStyle.self)
            XCTAssertTrue(type(of: s.outerModifier) == TEST_OuterModifier.self)
            XCTAssertTrue(type(of: s.innerModifier) == TEST_InnerModifier.self)
        }()
    }
}

struct TEST_InnerModifier: SwiftUI.ViewModifier {
    func body(content: Self.Content) -> some View {
        content
    }
}

struct TEST_OuterModifier: SwiftUI.ViewModifier {
    func body(content: Self.Content) -> some View {
        content
    }
}
