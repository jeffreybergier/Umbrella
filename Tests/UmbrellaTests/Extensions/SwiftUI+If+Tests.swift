//
//  Created by Jeffrey Bergier on 2022/09/11.
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
import ViewInspector
import SwiftUI
import Umbrella

class SwiftUI_If_Tests: XCTestCase {
    
    func test_platform_iOS() throws {
        let v = Color.white.if(.iOS) {
            $0
            Text("Addition")
        }
        #if os(iOS)
        _ = try v.inspect().find(text: "Addition")
        #else
        XCTAssertNil(try? v.inspect().find(text: "Addition"))
        #endif
    }
    
    func test_platform_macOS() throws {
        let v = Color.white.if(.macOS) {
            $0
            Text("Addition")
        }
        #if os(macOS)
        _ = try v.inspect().find(text: "Addition")
        #else
        XCTAssertNil(try? v.inspect().find(text: "Addition"))
        #endif
    }
    
    func test_platform_watchOS() throws {
        let v = Color.white.if(.watchOS) {
            $0
            Text("Addition")
        }
        #if os(watchOS)
        _ = try v.inspect().find(text: "Addition")
        #else
        XCTAssertNil(try? v.inspect().find(text: "Addition"))
        #endif
    }
    
    func test_platform_tvOS() throws {
        let v = Color.white.if(.tvOS) {
            $0
            Text("Addition")
        }
        #if os(tvOS)
        _ = try v.inspect().find(text: "Addition")
        #else
        XCTAssertNil(try? v.inspect().find(text: "Addition"))
        #endif
    }
    
    func test_lift() throws {
        let v = Color.white.lift {
            $0
            Text("Addition")
        }
        _ = try v.inspect().find(text: "Addition")
    }
    
    func test_item_notNil() throws {
        let item: String? = "Addition"
        let v = Color.white.if(value: item) {
            $0
            Text($1)
        }
        _ = try v.inspect().find(text: "Addition")
    }
    
    func test_item_nil() throws {
        let item: String? = nil
        let v = Color.white.if(value: item) { v, _ in
            v
            Text("Addition")
        }
        XCTAssertNil(try? v.inspect().find(text: "Addition"))
    }
    
    func test_bool_true() throws {
        let v = Color.white.if(bool: true) {
            $0
            Text("Addition")
        }
        _ = try v.inspect().find(text: "Addition")
    }
    
    func test_bool_false() throws {
        let v = Color.white.if(bool: false) {
            $0
            Text("Addition")
        }
        XCTAssertNil(try? v.inspect().find(text: "Addition"))
    }
    
    func test_bool_else_true() throws {
        let v = Color.white.if(bool: true) {
            $0
            Text("Addition")
        } else: {
            $0
            Text("Fail")
        }
        _ = try v.inspect().find(text: "Addition")
        XCTAssertNil(try? v.inspect().find(text: "Fail"))
    }
    
    func test_bool_else_false() throws {
        let v = Color.white.if(bool: false) {
            $0
            Text("Fail")
        } else: {
            $0
            Text("Addition")
        }
        _ = try v.inspect().find(text: "Addition")
        XCTAssertNil(try? v.inspect().find(text: "Fail"))
    }
}
