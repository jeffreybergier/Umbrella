//
//  Created by Jeffrey Bergier on 2022/03/13.
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
import Collections

public typealias ErrorQueue = EnvironmentQueue<UserFacingError>

/// Makes it easy to add a queue of errors to your application. Add a `Environment`
/// into your environment at the top level of your application. Then use this property wrapper
/// so that any view can access the error queue. If the property is NIL there are no errors in the
/// queue. If the property contains an error, it should be presented to the user. This is very easy
/// using `.modifier(UserFacingErrorAlert(self.$errorQueue))` syntax for presenting
/// errors. When the error is dismissed, the system sets the property to NIL. In this case, the error
/// is removed the queue and the next error is presented.
@propertyWrapper
public struct EnvironmentQueue<T>: DynamicProperty {
    
    public typealias Environment = BlackBox<Collection>
    public typealias Collection = Deque<T>
    
    public static func newEnvirementObject() -> Environment {
        return BlackBox(Deque<T>(), isObservingValue: true)
    }
    
    public static func legacyBinding(_ environment: Environment) -> Binding<T?> {
        Binding {
            environment.value.first
        } set: {
            if let newValue = $0 {
                environment.value.append(newValue)
            } else {
                guard environment.value.isEmpty == false else {
                    "Tried to remove error from queue when it was already empty".log()
                    return
                }
                environment.value.removeFirst()
            }
        }
    }
    
    @EnvironmentObject public var environment: Environment
    
    public init() {}
    
    /// Contains the next error in the Queue. Set to a new error to append a new error to the end of the
    /// queue. Set to NIL to remove the first error from the queue. Directly access `environment`
    /// property if you wish to manually modify the queue.
    public var wrappedValue: T? {
        get { self.projectedValue.wrappedValue }
        nonmutating set { self.projectedValue.wrappedValue = newValue }
    }
    
    public var projectedValue: Binding<T?> {
        Self.legacyBinding(self.environment)
    }
}
