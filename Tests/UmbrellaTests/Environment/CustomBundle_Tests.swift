//
//  Created by Jeffrey Bergier on 2023/01/27.
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

class CustomBundle_Tests: XCTestCase {
    
    private let mainBundle = Bundle.main
    private let realBundle = Bundle.module
    private let customBundle = Bundle()
    
    func test_defaultValue() throws {
        let v1 = TESTView()
        let v2 = v1.environment(\.bundle, self.customBundle)
        let t1 = try v1.inspect().findAll(Text.self).first
        let t2 = try v2.inspect().findAll(Text.self).first
        XCTAssertNotNil(t1)
        XCTAssertNotNil(t2)
        XCTAssertEqual(v1.bundle, self.mainBundle)
    }
    
    func test_image_nil() throws {
        let b = self.realBundle
        let image = b.image(named: "Nothing")
        XCTAssertNil(image)
    }
    
    func test_localized_nil() throws {
        let b = self.realBundle
        let s = b.localized(key: "Nothing")
        XCTAssertEqual(s, "Nothing")
    }
    
    func test_image() throws {
        let b = self.realBundle
        let url = b.url(forResource: "BundleTest",
                        withExtension: "png")
        let image = b.image(named: "BundleTest")
        XCTAssertNotNil(image)
        XCTAssertNotNil(url)
    }
}

fileprivate struct TESTView: View {
    @Environment(\.bundle) fileprivate var bundle
    var body: some View {
        Text(String(describing: self.bundle))
    }
}
