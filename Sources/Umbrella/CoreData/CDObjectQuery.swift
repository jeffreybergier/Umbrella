//
//  Created by Jeffrey Bergier on 2022/03/26.
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

import CoreData
import SwiftUI

@propertyWrapper
public struct CDObjectQuery<In: NSManagedObject, Out>: DynamicProperty {
    
    public typealias OnError = (Swift.Error) -> Void
    public typealias ReadTransform = (In) -> Out?
    public typealias WriteTransform = (In?, Out?) -> Result<Void, Swift.Error>
    
    private let onRead: ReadTransform
    @StateObject private var object = NilBox<In>()
    @StateObject private var onWrite: SecretBox<WriteTransform?>
    @StateObject private var onError: SecretBox<OnError?>
    
    @Environment(\.managedObjectContext) private var context
        
    public init(objectIDURL: URL? = nil,
                onError: OnError? = nil,
                onWrite: WriteTransform? = nil,
                onRead: @escaping ReadTransform)
    {
        self.onRead  = onRead
        _onWrite = .init(wrappedValue: .init(onWrite))
        _onError = .init(wrappedValue: .init(onError))
    }
    
    public var wrappedValue: Out? {
        get {
            guard let cd = self.object.value else { return nil }
            return self.onRead(cd)
        }
        nonmutating set { self.write(newValue) }
    }
    
    public var projectedValue: Binding<Out>? {
        guard let value = self.wrappedValue else { return nil }
        return Binding {
            return value
        } set: {
            self.write($0)
        }
    }
    
    public func setObjectIDURL(_ newValue: URL?) {
        self.object.value = nil
        guard
            let url = newValue,
            let psc = self.context.persistentStoreCoordinator,
            let id = psc.managedObjectID(forURIRepresentation: url),
            let object = self.context.object(with: id) as? In
        else {
            // TODO: Create error here
            return
        }
        self.object.value = object
    }
    
    private func write(_ newValue: Out?) {
        guard let onWrite = self.onWrite.value else {
            assertionFailure("Attempted to write value, but no write closure was given")
            return
        }
        guard let error = onWrite(self.object.value, newValue).error else { return }
        self.onError.value?(error)
        assert(
            self.onError.value != nil,
            "An Error was thrown but ignored:\n\(String(describing: error))"
        )
    }
    
    public func setOnWrite(_ newValue: WriteTransform?) {
        self.onWrite.value = newValue
    }
    
    public func setOnError(_ newValue: OnError?) {
        self.onError.value = newValue
    }
}
