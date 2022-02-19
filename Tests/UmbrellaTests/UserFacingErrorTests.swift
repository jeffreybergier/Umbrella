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
import Umbrella

enum ImplicitError: UserFacingError {
    var message: String { "My Explicit Message" }
    case all
}

enum ExplicitError: UserFacingError {
    static var errorDomain: String = "MyExplicitErrorDomain"
    var message: String { "My Explicit Message" }
    var title: String { "MyExplicitTitle" }
    var dismissTitle: String { "MyExplicitDismiss" }
    var errorCode: Int { 123_456_789 }
    var errorUserInfo: [String : Any] { ["A": 10] }
    var options: [RecoveryOption] { [.init(title: "MyExplicitOption1", isDestructive: true, perform: {})] }
    case all
}

class UserFacingErrorTests: XCTestCase {
    
    func test_localizations() {
        XCTAssertEqual(ImplicitError.all.title, "Error")
        XCTAssertEqual(ImplicitError.all.dismissTitle, "Dismiss")
        XCTAssertEqual(ExplicitError.all.title, "MyExplicitTitle")
        XCTAssertEqual(ExplicitError.all.dismissTitle, "MyExplicitDismiss")
    }
    
    func test_domain() {
        XCTAssertEqual(ImplicitError.errorDomain, "UmbrellaTests.ImplicitError")
        XCTAssertEqual(ExplicitError.errorDomain, "MyExplicitErrorDomain")
    }
    
    func test_code() {
        XCTAssertEqual(ImplicitError.all.errorCode, 0)
        XCTAssertEqual(ExplicitError.all.errorCode, 123_456_789)
    }
    
    func test_userInfo() {
        XCTAssertTrue(ImplicitError.all.errorUserInfo.isEmpty)
        XCTAssertFalse(ExplicitError.all.errorUserInfo.isEmpty)
        let a = ExplicitError.all.errorUserInfo["A"] as! Int
        XCTAssertNotNil(ExplicitError.all.errorUserInfo["A"])
        XCTAssertEqual(a, 10)
    }
    
    func test_options() {
        XCTAssertTrue(ImplicitError.all.options.isEmpty)
        XCTAssertFalse(ExplicitError.all.options.isEmpty)
        XCTAssertEqual(ExplicitError.all.options.first?.isDestructive, true)
        XCTAssertEqual(ExplicitError.all.options.first?.title, "MyExplicitOption1")
    }
    
}
