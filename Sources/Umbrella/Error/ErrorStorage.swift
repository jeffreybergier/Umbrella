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
import Collections
import SwiftUI

/// Provides ErrorStorage with an identifier that can conforms to `Codable`.
/// Use `@Environment(\.errorResponder)` to catch errors and then store the identifier
/// in SceneStorage or other.
/// Note that Errors are very difficult to encode directly. If the app quits, all of the identifiers will return `NIL`
@propertyWrapper
public struct ErrorStorage: DynamicProperty {
    
    public struct Identifier: Identifiable, Codable, Hashable {
        public var id = UUID()
    }
    
    public static func newEnvironment() -> EnvironmentValue { .init() }
    
    @EnvironmentObject private var storage: EnvironmentValue
    @Environment(\.sceneContext) private var context
    
    public init() {}
    
    /// Use to detect in your UI if there are Errors to show and what the next error is.
    public var wrappedValue: Value {
        return .init(all: self.storage.identifiers[self.context, default: []],
                     rawStorage: self.storage,
                     context: self.context)
    }
}

extension ErrorStorage {
    
    public struct Value {
        public let all: [Identifier]
        public let rawStorage: EnvironmentValue
        internal let context: SceneContext.Value
        public func error(for key: Identifier) -> Error? {
            self.rawStorage.error(for: key)
        }
        public func append(_ error: Error) {
            self.rawStorage.append(error, for: self.context)
        }
        public func remove(_ key: Identifier) {
            self.rawStorage.remove(key, for: self.context)
        }
        public func removeAll() {
            self.rawStorage.removeAll(self.context)
        }
    }
    
    public class EnvironmentValue: ObservableObject {
        
        @Published public internal(set) var storage: [Identifier: Error] = [:]
        @Published public internal(set) var identifiers: [SceneContext.Value: [Identifier]] = [:]
        
        public init() {}
        
        public func error(for key: Identifier) -> Error? {
            self.storage[key]
        }
        
        public func append(_ error: Error, for context: SceneContext.Value) {
            let id = Identifier()
            self.identifiers[context, default: []].append(id)
            self.storage[id] = error
        }
        
        public func remove(_ key: Identifier, for context: SceneContext.Value) {
            self.identifiers[context, default: []].removeAll { key == $0 }
            self.storage.removeValue(forKey: key)
        }
        
        public func removeAll(_ context: SceneContext.Value? = nil) {
            if let context {
                let identifiers = self.identifiers[context, default: []]
                identifiers.forEach { self.storage.removeValue(forKey: $0) }
                self.identifiers[context] = []
            } else {
                self.storage = [:]
                self.identifiers = [:]
            }
        }
    }
}
