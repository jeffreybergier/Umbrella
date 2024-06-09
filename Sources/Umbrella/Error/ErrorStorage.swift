//
//  Created by Jeffrey Bergier on 2023/01/14.
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

import Foundation
import Combine
import SwiftUI

public typealias OnError = (Error) -> Void

/// Use to store Errors across your application. Works in combination with `ErrorStorage.Presenter`
/// to display errors in your application. This type makes no attempt to encode errors, they are all lost when
/// the application quits. However, `ErrorStorage.Identifier` can be coded.
@propertyWrapper
public struct ErrorStorage: DynamicProperty {
    
    public struct Identifier: Identifiable, Codable, Hashable {
        public var id = UUID()
    }
    
    public static func newEnvironment() -> EnvironmentValue { .init() }
    
    @EnvironmentObject internal var storage: EnvironmentValue
    
    public init() {}
    
    /// Use to detect in your UI if there are Errors to show and what the next error is.
    public var wrappedValue: Value {
        return .init(self.storage)
    }
}

extension ErrorStorage {
    
    public struct Value {
        
        public let didAppendPub: PassthroughSubject<Identifier, Never>
        public let nextErrorPub: PassthroughSubject<Identifier?, Never>
        public let nextError: Identifier?
        
        private let rawStorage: EnvironmentValue
        
        internal init(_ rawStorage: EnvironmentValue) {
            self.rawStorage = rawStorage
            self.didAppendPub = rawStorage.didAppendPub
            self.nextErrorPub = rawStorage.nextErrorPub
            self.nextError = rawStorage.identifiers.first
        }
        
        public func error(for key: Identifier) -> Error? {
            self.rawStorage.error(for: key)
        }
        
        public func append(_ error: Error) {
            self.rawStorage.append(error)
        }
        
        public func remove(_ key: Identifier) {
            self.rawStorage.remove(key)
        }
        
        public func removeAll() {
            self.rawStorage.removeAll()
        }
    }
    
    public class EnvironmentValue: ObservableObject {
        
        public let didAppendPub = PassthroughSubject<Identifier, Never>()
        public let nextErrorPub = PassthroughSubject<Identifier?, Never>()
        public private(set) var identifiers: [Identifier] = []
        private var storage: [Identifier: Error] = [:]
        
        public init() {}
        
        public func error(for key: Identifier) -> Error? {
            self.storage[key]
        }
        
        public func append(_ error: Error) {
            // Send pre notifications
            self.objectWillChange.send()
            
            // Update Storage
            let id = Identifier()
            self.storage[id] = error
            self.identifiers.append(id)
            
            // Send post notifications
            self.didAppendPub.send(id)
            self.nextErrorPub.send(self.identifiers.first)
        }
        
        public func remove(_ key: Identifier) {
            // Send pre notifications
            self.objectWillChange.send()
            
            // Update Storage
            self.storage.removeValue(forKey: key)
            self.identifiers.removeAll { key == $0 }
            
            // Send post notifications
            self.nextErrorPub.send(self.identifiers.first)
        }
        
        public func removeAll() {
            // Send pre notifications
            self.objectWillChange.send()
            
            // Update Storage
            self.storage = [:]
            self.identifiers = []
            
            // Send post notifications
            self.nextErrorPub.send(self.identifiers.first)
        }
    }
}
