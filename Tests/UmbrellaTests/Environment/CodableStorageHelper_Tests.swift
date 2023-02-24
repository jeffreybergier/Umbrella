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
@testable import Umbrella

class CodableStorageHelper_Tests: XCTestCase {
    
    let realValue = CodableValue("Hello World")
    let rawValue = "YnBsaXN0MDDRAQJVdmFsdWVbSGVsbG8gV29ybGQICxEAAAAAAAABAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAHQ=="
    
    func test_cacheHit() throws {
        var error: Error?
        let helper = CodableStorageHelper<CodableValue> { error = $0 }
        let rawValue = helper.encodeAndCache(self.realValue)
        XCTAssertEqual(rawValue, self.rawValue)
        let decodedValue = helper.readCacheOrDecode(rawValue)
        XCTAssertEqual(decodedValue?.value, self.realValue.value)
        try error.map { throw $0 }
    }
    
    func test_cacheMiss() throws {
        var error: Error?
        let helper = CodableStorageHelper<CodableValue> { error = $0 }
        let decodedValue = helper.readCacheOrDecode(self.rawValue)
        XCTAssertEqual(decodedValue?.value, self.realValue.value)
        try error.map { throw $0 }
    }
    
    func test_readNIL() throws {
        var error: Error?
        let helper = CodableStorageHelper<CodableValue> { error = $0 }
        let decodedValue = helper.readCacheOrDecode(nil)
        XCTAssertNil(decodedValue)
        try error.map { throw $0 }
    }
    
    func test_readInvalidData() throws {
        var error: Error?
        let helper = CodableStorageHelper<CodableValue> { error = $0 }
        let decodedValue = helper.readCacheOrDecode("Y==")
        XCTAssertNil(decodedValue)
        try error.map { throw $0 }
    }
    
    func test_encodeError() throws {
        var error: Error?
        let helper = CodableStorageHelper<String> { error = $0 }
        let rawValue = helper.encodeAndCache("Hello World")
        XCTAssertNil(rawValue)
        XCTAssertNotNil(error)
    }
    
    func test_decodeError() throws {
        var error: Error?
        let helper = CodableStorageHelper<String> { error = $0 }
        let decodedValue = helper.readCacheOrDecode(self.rawValue)
        XCTAssertNil(decodedValue)
        XCTAssertNotNil(error)
    }
}

internal struct CodableValue: Codable {
    internal var value: String
    init(_ input: String) {
        self.value = input
    }
}
