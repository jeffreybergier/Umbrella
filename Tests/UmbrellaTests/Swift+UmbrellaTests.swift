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
@testable import Umbrella

class SwiftUmbrellaTests: XCTestCase {

    func test_result() {
        let randomInt = Int.random(in: 0..<Int.max)
        let r1: Result<Int, GenericError> = .success(randomInt)
        XCTAssertEqual(r1.value, randomInt)
        XCTAssertNil(r1.error)
        let error = GenericError(errorCode: randomInt, message: "")
        let r2: Result<Int, GenericError> = .failure(error)
        XCTAssertNil(r2.value)
        XCTAssertEqual(r2.error!.errorCode, randomInt)
    }
    
    func test_typeName() {
        XCTAssertEqual(_typeName(String.self), "Swift.String")
        XCTAssertEqual(__typeName(String.self), "String")
        XCTAssertEqual(_typeName(GenericWebKitNavigationDelegate.Error.self),
                       "Umbrella.GenericWebKitNavigationDelegate.Error")
        XCTAssertEqual(__typeName(GenericWebKitNavigationDelegate.Error.self),
                       "GenericWebKitNavigationDelegate.Error")
        XCTAssertEqual(_typeName(ImplicitError.self), "UmbrellaTests.ImplicitError")
        XCTAssertEqual(__typeName(ImplicitError.self), "ImplicitError")
    }
    
    func test_typeName_framework() {
        XCTAssertEqual(__typeName_framework(String.self), "Swift")
        XCTAssertEqual(__typeName_framework(GenericWebKitNavigationDelegate.Error.self), "Umbrella")
        XCTAssertEqual(__typeName_framework(ImplicitError.self), "UmbrellaTests")
    }
    
    func test_bundle_init() {
        // Apple frameworks are expected to return nil
        XCTAssertNil(Bundle.for(type: String.self))
        let bundle1 = Bundle.for(type: GenericWebKitNavigationDelegate.Error.self)
        XCTAssertNotNil(bundle1)
        XCTAssertEqual(bundle1?.bundleIdentifier, "com.saturdayapps.Umbrella")
        let bundle2 = Bundle.for(type: ImplicitError.self)
        XCTAssertNotNil(bundle2)
        XCTAssertEqual(bundle2?.bundleIdentifier, "com.saturdayapps.UmbrellaTests")
    }
    
}
