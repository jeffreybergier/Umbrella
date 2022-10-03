//
//  Created by Jeffrey Bergier on 2022/10/03.
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
@testable import Umbrella

import Combine
import SwiftUI

class JSBFileStorage_Tests: AsyncTestCase {
    
    lazy var presenter: JSBFileStoragePresenter = JSBFileStoragePresenter(presentedItemURL: self.url)
    let testData = "\(Int.random(in: 1_000_000...9_999_999))".data(using: .utf8)!
    let url: URL = URL(fileURLWithPath: NSTemporaryDirectory())
                      .appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString)
                      .appendingPathComponent("aTestFile.txt")
    
    private var sinkBag: Set<AnyCancellable> = []
    
    func test_presenter_writeData() throws {
        XCTAssertNil(self.presenter.data)
        try self.presenter.update(self.testData)
        XCTAssertEqual(self.presenter.data!, self.testData)
    }
    
    func test_presenter_writeDataThenNIL() throws {
        XCTAssertNil(self.presenter.data)
        try self.presenter.update(self.testData)
        XCTAssertEqual(self.presenter.data!, self.testData)
        try self.presenter.update(nil)
        XCTAssertNil(self.presenter.data)
    }
    
    func test_presenter_writeNIL() throws {
        XCTAssertNil(self.presenter.data)
        try self.presenter.update(nil)
        XCTAssertNil(self.presenter.data)
    }
    
    func test_presenter_publish_data() throws {
        let wait = self.newWait(count: 2)
        self.presenter.objectWillChange.sink { _ in
            wait { XCTAssertNil(self.presenter.data) }
            DispatchQueue.main.async { wait {
                XCTAssertEqual(self.presenter.data!, self.testData)
            }}
        }.store(in: &self.sinkBag)
        
        try self.presenter.update(self.testData)
        self.wait(for: .short)
    }
    
    func test_property_error() throws {
        let wait = self.newWait()
        let invalidURL = URL(string: NSTemporaryDirectory())!
        let property = JSBFileStorage(url: invalidURL) { error in
            let error = error as NSError
            wait {
                XCTAssertEqual(error.domain, NSCocoaErrorDomain)
                XCTAssertEqual(error.code, 518)
            }
        }
        property.wrappedValue = self.testData
        self.wait(for: .short)
    }
}
