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
import TestUmbrella
import SwiftUI
import ViewInspector
import Umbrella

class Action_Tests: AsyncTestCase {
    
    // TODO: Test keyboard shortcut when ViewInspector supports it
    let locale = ActionLocalization(title: "aTitle",
                                    hint: "aHint",
                                    image: .system("xmark"))
    let style = ActionStyleImp(buttonRole: .destructive,
                               labelStyle: TitleAndIconLabelStyle(),
                               outerModifier: TEST_OuterModifier(),
                               innerModifier: TEST_InnerModifier())
    
    func test_label() throws {
        let label = self.style.action(text: self.locale).label
        _ = try label.inspect().find(text: self.locale.title)
        _ = try label.inspect().find(text: TEST_OuterModifier.text)
        _ = try label.inspect().find(text: TEST_InnerModifier.text)
        // TODO: Find image
        // TODO: Find accessibility label
    }
    
    func test_button() throws {
        let button = self.style.action(text: self.locale).button { }
        _ = try button.inspect().find(text: self.locale.title)
        _ = try button.inspect().find(text: TEST_OuterModifier.text)
        _ = try button.inspect().find(text: TEST_InnerModifier.text)
        // TODO: Find image
        // TODO: Find accessibility label
    }
    
    func test_button_enabled() throws {
        let wait = self.newWait(count: 4)
        _ = try {
            let b = self.style.action(text: self.locale).button { wait(nil) }
            try b.inspect().button().tap()
            XCTAssertFalse(try b.inspect().isDisabled())
        }()
        _ = try {
            let b = self.style.action(text: self.locale).button(isEnabled: false) { wait(nil) }
            XCTAssertNil(try? b.inspect().button().tap())
            XCTAssertTrue(try b.inspect().isDisabled())
        }()
        _ = try {
            let b = self.style.action(text: self.locale).button(isEnabled: true) { wait(nil) }
            try b.inspect().button().tap()
            XCTAssertFalse(try b.inspect().isDisabled())
        }()
        _ = try {
            let nothing: String? = nil
            let b = self.style.action(text: self.locale).button(item: nothing) { _ in wait(nil) }
            XCTAssertNil(try? b.inspect().button().tap())
            XCTAssertTrue(try b.inspect().isDisabled())
        }()
        _ = try {
            let something: String? = "-1"
            let b = self.style.action(text: self.locale).button(item: something) { inner in
                wait { XCTAssertEqual(something, inner) }
            }
            try b.inspect().button().tap()
            XCTAssertFalse(try b.inspect().isDisabled())
        }()
        _ = try {
            let empty: [String] = []
            let b = self.style.action(text: self.locale).button(items: empty) { inner in
                wait { XCTAssertEqual(empty, inner) }
            }
            XCTAssertNil(try? b.inspect().button().tap())
            XCTAssertTrue(try b.inspect().isDisabled())
        }()
        _ = try {
            let full: [String] = [""]
            let b = self.style.action(text: self.locale).button(items: full) { inner in
                wait { XCTAssertEqual(full, inner) }
            }
            try b.inspect().button().tap()
            XCTAssertFalse(try b.inspect().isDisabled())
        }()
        self.wait(for: .instant)
    }
    
    func test_localization_init() {
        #if os(watchOS) || os (tvOS)
        _ = {
            let l = ActionLocalization(title: "aTitle",
                                       hint: "aHint",
                                       image: .system("xmark"))
            XCTAssertEqual(l.title, "aTitle")
            XCTAssertEqual(l.hint, "aHint")
            XCTAssertEqual(l.image, .system("xmark"))
        }()
        #else
        _ = {
            let l = ActionLocalization(title: "aTitle",
                                       hint: "aHint",
                                       image: .system("xmark"),
                                       shortcut: .init("a"))
            XCTAssertEqual(l.title, "aTitle")
            XCTAssertEqual(l.hint, "aHint")
            XCTAssertEqual(l.image, .system("xmark"))
            XCTAssertEqual(l.shortcut, .init("a"))
        }()
        #endif
        _ = {
            let l = ActionLocalization(title: "aTitle")
            XCTAssertEqual(l.title, "aTitle")
            XCTAssertNil(l.hint)
            XCTAssertNil(l.image)
            #if os(macOS) || os(iOS)
            XCTAssertNil(l.shortcut)
            #endif
        }()
    }
    
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

struct TEST_InnerModifier: ViewModifier, Inspectable {
    static let text = "InnerModifier"
    func body(content: Self.Content) -> some View {
        VStack {
            content
            Text(type(of: self).text)
        }
    }
}

struct TEST_OuterModifier: ViewModifier, Inspectable {
    static let text = "OuterModifier"
    func body(content: Self.Content) -> some View {
        HStack {
            Text(type(of: self).text)
            content
        }
    }
}
