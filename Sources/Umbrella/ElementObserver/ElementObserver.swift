//
//  Created by Jeffrey Bergier on 2020/11/26.
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

import Combine

/// SwiftUI ObservableObject for a single item
/// See `ManagedObjectElementObserver` for details on how to use.
public protocol ElementObserver: ObservableObject, Identifiable, Hashable {
    associatedtype Value
    var value: Value { get }
    var isDeleted: Bool { get }
    var canDelete: Bool { get }
}

/// Typeeraser for `ElementObserver`
/// See `ManagedObjectElementObserver` for details on how to use.
public class AnyElementObserver<Value: Identifiable & Hashable>: ElementObserver {

    public let objectWillChange: ObservableObjectPublisher

    public var value: Value    { _value() }
    public var id: Value.ID    { _value().id }
    public var isDeleted: Bool { _isDeleted() }
    public var canDelete: Bool { _canDelete() }
    private var _value:     () -> Value
    private var _isDeleted: () -> Bool
    private var _canDelete: () -> Bool

    public init<T: ElementObserver>(_ element: T)
    where T.Value == Value,
          T.ID == Value.ID,
          T.ObjectWillChangePublisher == ObservableObjectPublisher
    {
        _value =     { element.value }
        _isDeleted = { element.isDeleted }
        _canDelete = { element.canDelete }
        self.objectWillChange = element.objectWillChange
    }
    
    public static func == (lhs: AnyElementObserver<Value>, rhs: AnyElementObserver<Value>) -> Bool {
        return lhs.value == rhs.value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.value)
    }
}
