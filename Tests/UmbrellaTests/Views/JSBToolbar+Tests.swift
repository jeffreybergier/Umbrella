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
import TestUmbrella
@testable import Umbrella

// TODO: Test the views directly
// https://betterprogramming.pub/how-to-test-swiftui-views-smartly-6c6b13f9edb1?gi=250441c8efc
class JSBToolbar_Tests: AsyncTestCase {
    
    let title  = "Hello World"
    let done   = ActionLocalization(title: "DoneDone",
                                    hint: "DoneHint",
                                    image: .system("xmark"),
                                    shortcut: .defaultAction)
    let cancel = ActionLocalization(title: "CancelCancel",
                                    hint: "CancelHint",
                                    image: .system("xmark"),
                                    shortcut: .cancelAction)
    let delete = ActionLocalization(title: "DeleteDelete",
                                    hint: "DeleteHint",
                                    image: nil,
                                    shortcut: nil)
    
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
    
    func test_initClosureStorage() {
        let wait = self.newWait(count: 3)
        let done = { wait(nil) }
        let cancel = { wait(nil) }
        let delete = { wait(nil) }
        let toolbar = JSBToolbar(title: self.title,
                                 done: self.done,
                                 cancel: self.cancel,
                                 delete: self.delete,
                                 doneAction: done,
                                 cancelAction: cancel,
                                 deleteAction: delete)
        toolbar.actionDone()
        toolbar.actionCancel?()
        toolbar.actionDelete?()
        self.wait(for: .instant)
    }
    
    func test_initAPI_correct() {
        let toolbars = [
            JSBToolbar(title: self.title,
                       done: self.done,
                       cancel: self.cancel,
                       delete: self.delete,
                       doneAction: {},
                       cancelAction: {},
                       deleteAction: {}),
            JSBToolbar(title: self.title,
                       done: self.done,
                       doneAction: {}),
            JSBToolbar(title: self.title,
                       done: self.done,
                       cancel: self.cancel,
                       doneAction: {},
                       cancelAction: {}),
            JSBToolbar(title: self.title,
                       done: self.done,
                       delete: self.delete,
                       doneAction: {},
                       deleteAction: {}),
        ]
        XCTAssertEqual(toolbars.count, 4)
        XCTAssertTrue(type(of: toolbars.first!) == JSBToolbar.self)
    }
    
    func test_initAPI_incorrect() {
        let toolbars = [
            JSBToolbar(title: self.title,
                       done: self.done,
                       doneAction: {},
                       cancelAction: {},
                       deleteAction: {}),
            JSBToolbar(title: self.title,
                       done: self.done,
                       delete: self.delete,
                       doneAction: {},
                       cancelAction: {}),
            JSBToolbar(title: self.title,
                       done: self.done,
                       delete: self.delete,
                       doneAction: {},
                       cancelAction: {}),
        ]
        XCTAssertEqual(toolbars.count, 3)
        XCTAssertTrue(type(of: toolbars.first!) == JSBToolbar.self)
    }
}
