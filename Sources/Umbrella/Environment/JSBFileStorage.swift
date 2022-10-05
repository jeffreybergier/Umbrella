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

@propertyWrapper
public struct JSBFileStorage: DynamicProperty {
    
    public typealias OnError = (Error) -> Void
    
    @StateObject private var filePresenter: JSBFileStoragePresenter
    @StateObject private var onError: SecretBox<OnError?>
    
    public init(url: URL, onError: OnError? = nil) {
        _filePresenter = .init(wrappedValue: .init(presentedItemURL: url))
        _onError = .init(wrappedValue: .init(onError))
    }
    
    public var wrappedValue: Data? {
        get { self.filePresenter.data }
        nonmutating set {
            do {
                try self.filePresenter.update(newValue)
            } catch {
                self.onError.value?(error)
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
