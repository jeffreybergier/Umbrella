//
//  Created by Jeffrey Bergier on 2022/09/10.
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
import Umbrella

class BindingUmbrella_Tests: XCTestCase {
    
    var originalValue = 5
    var originalValueNil: Int?
    var originalBool = false
    var originalArray: [String] = []

    func test_map() {
        let b1 = Binding<Int> {
            self.originalValue
        } set: {
            self.originalValue = $0
        }
        let b2 = b1.map { $0 * 2 } set: { $0 / 2 }
        XCTAssertEqual(b1.wrappedValue, 5)
        XCTAssertEqual(b2.wrappedValue, 10)
        b1.wrappedValue = 10
        XCTAssertEqual(b1.wrappedValue, 10)
        XCTAssertEqual(b2.wrappedValue, 20)
        b2.wrappedValue = 30
        XCTAssertEqual(b1.wrappedValue, 15)
        XCTAssertEqual(b2.wrappedValue, 30)
    }
    
    func test_compactMap() {
        let b1 = Binding<Int?> {
            self.originalValueNil
        } set: {
            self.originalValueNil = $0
        }
        let b2: Binding<Int> = b1.compactMap(default: 5)
        XCTAssertEqual(b1.wrappedValue, nil)
        XCTAssertEqual(b2.wrappedValue, 5)
        b1.wrappedValue = 10
        XCTAssertEqual(b1.wrappedValue, 10)
        XCTAssertEqual(b2.wrappedValue, 10)
        b1.wrappedValue = nil
        XCTAssertEqual(b1.wrappedValue, nil)
        XCTAssertEqual(b2.wrappedValue, 5)
        b2.wrappedValue = 11
        XCTAssertEqual(b1.wrappedValue, 11)
        XCTAssertEqual(b2.wrappedValue, 11)
    }
    
    func test_compactMap_convenience() {
        _ = {
            let b = Binding<String?> { nil } set: { _ in }
            XCTAssertEqual(b.compactMap().wrappedValue, "")
        }()
        _ = {
            let b = Binding<Int?> { nil } set: { _ in }
            XCTAssertEqual(b.compactMap().wrappedValue, 0)
        }()
        _ = {
            let b = Binding<Double?> { nil } set: { _ in }
            XCTAssertEqual(b.compactMap().wrappedValue, 0)
        }()
        _ = {
            let b = Binding<Bool?> { nil } set: { _ in }
            XCTAssertEqual(b.compactMap().wrappedValue, false)
        }()
    }
    
    func test_isFlipped() {
        let b = Binding<Bool> { self.originalBool } set: { self.originalBool = $0 }
        XCTAssertEqual(b.wrappedValue, false)
        XCTAssertEqual(b.flipped.wrappedValue, true)
        b.wrappedValue = true
        XCTAssertEqual(b.wrappedValue, true)
        XCTAssertEqual(b.flipped.wrappedValue, false)
        b.flipped.wrappedValue = true
        XCTAssertEqual(b.wrappedValue, false)
        XCTAssertEqual(b.flipped.wrappedValue, true)
    }
    
    func test_isPresented_Collection() {
        let b = Binding<[String]> { self.originalArray } set: { self.originalArray = $0 }
        XCTAssertEqual(b.wrappedValue, [])
        XCTAssertEqual(b.mapBool().wrappedValue, false)
        b.wrappedValue = ["Hello"]
        XCTAssertEqual(b.wrappedValue, ["Hello"])
        XCTAssertEqual(b.mapBool().wrappedValue, true)
        b.mapBool().wrappedValue = true
        XCTAssertEqual(b.wrappedValue, ["Hello"])
        XCTAssertEqual(b.mapBool().wrappedValue, true)
        b.mapBool().wrappedValue = false
        XCTAssertEqual(self.originalArray, [])
        XCTAssertEqual(b.wrappedValue, [])
        XCTAssertEqual(b.mapBool().wrappedValue, false)
    }
    
    func test_isPresented_Optional() {
        var value: String? = nil
        let b = Binding<String?> { value } set: { value = $0 }
        let isP = b.mapBool()
        XCTAssertNil(value)
        XCTAssertNil(b.wrappedValue)
        XCTAssertFalse(isP.wrappedValue)
        b.wrappedValue = "Hello World"
        XCTAssertEqual(value, "Hello World")
        XCTAssertTrue(isP.wrappedValue)
        isP.wrappedValue = false
        XCTAssertNil(value)
        XCTAssertNil(b.wrappedValue)
        XCTAssertFalse(isP.wrappedValue)
    }
    
}
