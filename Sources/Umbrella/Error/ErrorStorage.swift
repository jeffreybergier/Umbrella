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
    
    public typealias EnvironmentValue = ObserveBox<Dictionary<Identifier, Error>>
    public typealias Value = Array<Identifier>
    
    public struct Identifier: Identifiable, Codable, Hashable {
        public var id = UUID()
    }
    
    public static func newEnvironment() -> EnvironmentValue { .init([:]) }
    
    @Environment(\.sceneContext) private var context
    @EnvironmentObject private var storage: EnvironmentValue
    @JSBSceneStorage("com.jeffburg.umbrella.errorstorage")
    private var identifiers: [SceneContext.Value: Array<Identifier>] = [:]
        
    public init() {}
    
    public private(set) var wrappedValue: Value {
        get { self.identifiers[self.context] ?? [] }
        nonmutating set { self.identifiers[self.context] = newValue }
    }
    
    public func pop(_ key: Identifier) -> Error? {
        self.wrappedValue.removeAll { key == $0 }
        return self.storage.value.removeValue(forKey: key)
    }
    
    public func append(_ error: Error) {
        let id = Identifier()
        self.wrappedValue.append(id)
        self.storage.value[id] = error
    }
}
