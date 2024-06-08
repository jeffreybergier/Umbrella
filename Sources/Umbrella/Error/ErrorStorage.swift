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
import SwiftUI

public typealias OnError = (Error) -> Void

/// Use to store Errors across your application. Works in combination with `ErrorStorage.Presenter`
/// to display errors in your application. This type makes no attempt to encode errors, they are all lost when
/// the application quits. However, `ErrorStorage.Identifier` can be coded.
@propertyWrapper
public struct ErrorStorage: DynamicProperty {
    
    /// HACK because SwiftUI needs to let things settle before trying to present next error
    #if os(watchOS)
    /// TODO: Remove watch long delay. Needed because dismissing errors takes forever.
    public static var HACK_errorDelay: DispatchTime { .now() + 1.0 }
    #else
    public static var HACK_errorDelay: DispatchTime { .now() + 0.1 }
    #endif
    
    public struct Identifier: Identifiable, Codable, Hashable {
        public var id = UUID()
    }
    
    public static func newEnvironment() -> EnvironmentValue { .init() }
    
    @EnvironmentObject private var storage: EnvironmentValue
    
    public init() {}
    
    /// Use to detect in your UI if there are Errors to show and what the next error is.
    public var wrappedValue: Value {
        return .init(all: self.storage.identifiers,
                     rawStorage: self.storage)
    }
}

extension ErrorStorage {
    
    public struct Value {
        public let all: [Identifier]
        public let rawStorage: EnvironmentValue
        public func error(for key: Identifier) -> Error? {
            self.rawStorage.error(for: key)
        }
        public func append(_ error: Error) {
            // HACK because SwiftUI needs to let things settle before trying to present next error
            DispatchQueue.main.asyncAfter(deadline: ErrorStorage.HACK_errorDelay)
            { [rawStorage] in
                rawStorage.append(error)
            }
        }
        public func remove(_ key: Identifier) {
            // HACK because SwiftUI needs to let things settle before trying to present next error
            DispatchQueue.main.asyncAfter(deadline: ErrorStorage.HACK_errorDelay)
            { [rawStorage] in
                rawStorage.remove(key)
            }
        }
        public func removeAll() {
            // HACK because SwiftUI needs to let things settle before trying to present next error
            DispatchQueue.main.asyncAfter(deadline: ErrorStorage.HACK_errorDelay)
            { [rawStorage] in
                rawStorage.removeAll()
            }
        }
    }
    
    public class EnvironmentValue: ObservableObject {
        
        @Published public internal(set) var storage: [Identifier: Error] = [:]
        @Published public internal(set) var identifiers: [Identifier] = []
        
        public init() {}
        
        public func error(for key: Identifier) -> Error? {
            self.storage[key]
        }
        
        public func append(_ error: Error) {
            let id = Identifier()
            self.storage[id] = error
            self.identifiers.append(id)
        }
        
        public func remove(_ key: Identifier) {
            self.storage.removeValue(forKey: key)
            self.identifiers.removeAll { key == $0 }
        }
        
        public func removeAll() {
            self.storage = [:]
            self.identifiers = []
        }
    }
}
