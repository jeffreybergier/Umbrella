//
//  Created by Jeffrey Bergier on 2022/08/23.
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

/// Provides a SceneStorage API that takes any codable value
@propertyWrapper
public struct JSBSceneStorage<Value: Codable>: DynamicProperty {
    
    @SceneStorage private var rawValue: String?
    @StateObject  private var helper: CodableStorageHelper<Value>
    
    private let defaultValue: Value
    
    public init(wrappedValue: Value, _ key: String, onError: OnError? = nil) {
        _rawValue = .init(key)
        _helper = .init(wrappedValue: .init(onError))
        self.defaultValue = wrappedValue
    }
    
    public var wrappedValue: Value {
        get { self.helper.readCacheOrDecode(self.rawValue) ?? self.defaultValue }
        nonmutating set { self.rawValue = self.helper.encodeAndCache(newValue) }
    }
    
    public var projectedValue: Binding<Value> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
}
