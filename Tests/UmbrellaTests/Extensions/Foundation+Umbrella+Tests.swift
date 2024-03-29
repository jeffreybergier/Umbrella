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

class FoundationUmbrella_Tests: XCTestCase {

    func test_string_trim() {
        XCTAssertNil("".trimmed)
        XCTAssertNil("\n\n\n    \n\n\n\n    \n".trimmed)
        XCTAssertEqual("aString".trimmed, "aString")
        XCTAssertEqual("  \n   aString   \n   ".trimmed, "aString")
        // does interrupt white space in the middle, just the ends
        XCTAssertEqual("  \n   aStr \n ing   \n   ".trimmed, "aStr \n ing")
    }
    
    func test_JSBImage() {
        #if canImport(UIKit)
        let image = JSBImage(systemName: "xmark")
        XCTAssertTrue(image!.isKind(of: UIImage.self))
        #else
        let image = JSBImage(systemSymbolName: "xmark", accessibilityDescription: nil)
        XCTAssertTrue(image!.isKind(of: NSImage.self))
        #endif
    }
    
}
