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
import TestUmbrella
import WebKit
@testable import Umbrella

class GenericWebKitNavigationDelegate_Tests: AsyncTestCase {
    
    let fakeError = NSError(domain: "drag", code: 420)
    let fakeWebview = WKWebView()

    func test_init() {
        let delegate = GenericWebKitNavigationDelegate(onError: { _ in })
        XCTAssertNotNil(delegate)
    }
    
    func test_didFail() {
        let wait = self.newWait()
        let closure: GenericWebKitNavigationDelegate.OnError = { error in
            let error = error as NSError
            wait { XCTAssertEqual(self.fakeError, error) }
        }
        let delegate = GenericWebKitNavigationDelegate(onError: closure)
        delegate.webView(self.fakeWebview,
                         didFail: nil,
                         withError: self.fakeError)
        self.wait(for: .instant)
    }
    
    func test_didFailProvision() {
        let wait = self.newWait()
        let closure: GenericWebKitNavigationDelegate.OnError = { error in
            let error = error as NSError
            wait { XCTAssertEqual(self.fakeError, error) }
        }
        let delegate = GenericWebKitNavigationDelegate(onError: closure)
        delegate.webView(self.fakeWebview,
                         didFailProvisionalNavigation: nil,
                         withError: self.fakeError)
        self.wait(for: .instant)
    }
    
    func test_navigationDecision() {
        _ = {
            let url = URL(string: "https://www.something.com")!
            let decision = GenericWebKitNavigationDelegate.decision(for: url)
            XCTAssertEqual(decision, .allow)
        }()
        _ = {
            let url = URL(string: "http://www.something.com")!
            let decision = GenericWebKitNavigationDelegate.decision(for: url)
            XCTAssertEqual(decision, .allow)
        }()
        _ = {
            let url = URL(string: "about:settings")!
            let decision = GenericWebKitNavigationDelegate.decision(for: url)
            XCTAssertEqual(decision, .allow)
        }()
        _ = {
            let url = URL(string: "ftp://www.something.com")!
            let decision = GenericWebKitNavigationDelegate.decision(for: url)
            XCTAssertEqual(decision, .cancel)
        }()
        _ = {
            let url = URL(string: "smb://www.something.com")!
            let decision = GenericWebKitNavigationDelegate.decision(for: url)
            XCTAssertEqual(decision, .cancel)
        }()
        _ = {
            let url = URL(string: "gopher://www.something.com")!
            let decision = GenericWebKitNavigationDelegate.decision(for: url)
            XCTAssertEqual(decision, .cancel)
        }()
    }
    
    func test_errorClosureNIL() {
        // these pass if there no crash
        let delegate = GenericWebKitNavigationDelegate(onError: nil)
        delegate.webView(self.fakeWebview,
                         didFail: nil,
                         withError: self.fakeError)
        delegate.webView(self.fakeWebview,
                         didFailProvisionalNavigation: nil,
                         withError: self.fakeError)
    }
    
}
