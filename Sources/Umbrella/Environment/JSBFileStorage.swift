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
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI

@MainActor
@propertyWrapper
public struct JSBCodableFileStorage<Value: Codable>: DynamicProperty {
        
    @JSBFileStorage private var storage: Data?
    private let onError: OnError?
    
    public init(url: URL, onError: OnError? = nil) {
        _storage = .init(url: url, onError: onError)
        self.onError = onError
    }
    
    public var wrappedValue: Value? {
        get { self.read() }
        nonmutating set { self.write(newValue) }
    }
    
    public var projectedValue: Binding<Value?> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
    
    // MARK: Encoding / Decoding
    
    // Not sure if storing these helps performance
    @State private var encoder = PropertyListEncoder()
    @State private var decoder = PropertyListDecoder()
    
    // Not sure if cache actually helps performance
    @State private var cache: [Data: Value] = [:]
    
    private func read() -> Value? {
        guard let data = self.storage else { return nil }
        if let cache = self.cache[data] { return cache }
        return try? self.decoder.decode(Value.self, from: data)
    }
    
    private func write(_ newValue: Value?) {
        let _data = try? self.encoder.encode(newValue)
        self.storage = _data
        guard let data = _data else { return }
        self.cache[data] = newValue
    }
}

@MainActor
@propertyWrapper
public struct JSBFileStorage: DynamicProperty {
    
    @StateObject private var filePresenter: JSBFileStoragePresenter
    private let onError: OnError?

    public init(url: URL, onError: OnError? = nil) {
        _filePresenter = .init(wrappedValue: .init(presentedItemURL: url))
        self.onError = onError
    }
    
    public var wrappedValue: Data? {
        get { self.filePresenter.data }
        nonmutating set {
            do {
                try self.filePresenter.update(newValue)
            } catch {
                self.onError?(error)
            }
        }
    }
    
    public var projectedValue: Binding<Data?> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
}

internal class JSBFileStoragePresenter: NSObject, NSFilePresenter, ObservableObject {
    
    @Published internal private(set) var data: Data?
    
    internal var presentedItemURL: URL?
    internal var presentedItemOperationQueue: OperationQueue = .main
    
    internal init(presentedItemURL: URL) {
        self.presentedItemURL = presentedItemURL
        self.data = try? Data(contentsOf: presentedItemURL)
        super.init()
        NSFileCoordinator.addFilePresenter(self)
    }
    
    @objc internal func presentedItemDidChange() {
        guard let presentedItemURL else { return }
        try? NSFileCoordinator(filePresenter: self).jsb_coordinate(readingItemAt: presentedItemURL)
        { presentedItemURL in
            self.data = try Data(contentsOf: presentedItemURL)
        }
    }
    
    internal func update(_ newValue: Data?) throws {
        guard let presentedItemURL else { return }
        try NSFileCoordinator(filePresenter: self).jsb_coordinate(
            writingItemAt: presentedItemURL,
            options: [.forReplacing, .forDeleting]
        ) { destination in
            let fm = FileManager.default
            if let newValue {
                try? fm.createDirectory(at: destination.deletingLastPathComponent(),
                                        withIntermediateDirectories: true)
                try newValue.write(to: destination)
            } else {
                /*
                 TODO: Consider checking for this specific error and ignoring.
                 Right now just ignoring all errors
                 test_presenter_writeNIL(): failed: caught error: "Error Domain=NSCocoaErrorDomain Code=4 "“aTestFile.txt” couldn’t be removed." Error Domain=NSPOSIXErrorDomain Code=2 "No such file or directory"}}"
                 */
                try? fm.removeItem(at: destination)
            }
            self.data = newValue
        }
    }
    
    deinit {
        NSFileCoordinator.removeFilePresenter(self)
    }
}

extension NSFileCoordinator {
    internal func jsb_coordinate(writingItemAt url: URL,
                                 options: WritingOptions = [],
                                 closure: (URL) throws -> Void) throws
    {
        var outterError: NSError?
        var innerError: NSError?
        self.coordinate(writingItemAt: url, options: options, error: &outterError) { url in
            do {
                try closure(url)
            } catch let error as NSError {
                innerError = error
            }
        }
        if let outterError {
            throw outterError
        } else if let innerError {
            throw innerError
        } else {
            return ()
        }
    }
    
    internal func jsb_coordinate(readingItemAt url: URL,
                                 options: ReadingOptions = [],
                                 closure: (URL) throws -> Void) throws
    {
        var outterError: NSError?
        var innerError: NSError?
        self.coordinate(readingItemAt: url, options: options, error: &outterError) { url in
            do {
                try closure(url)
            } catch let error as NSError {
                innerError = error
            }
        }
        if let outterError {
            throw outterError
        } else if let innerError {
            throw innerError
        } else {
            return ()
        }
    }
}

// MARK: Tests
/*
Add these to your test suite if you like

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

*/
