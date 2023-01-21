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
public struct CDObjectQuery<In: NSManagedObject, Out: Equatable>: DynamicProperty {
    
    public typealias OnError = (Swift.Error) -> Void
    public typealias ReadTransform = (In) -> Out?
    public typealias WriteTransform = (In, Out) -> Result<Void, Swift.Error>
    
    public struct Value {
        public var data: Out?
        public var id: URL?
        public var onError: OnError?
        public var onWrite: WriteTransform?
    }
    
    private let onRead: ReadTransform
    @StateObject private var object  = NilBox<In>()
    @StateObject private var objectID: SecretBox<URL?>
    @StateObject private var onWrite:  SecretBox<WriteTransform?>
    @StateObject private var onError:  SecretBox<OnError?>
    
    @Environment(\.managedObjectContext) private var context
        
    public init(objectID: URL? = nil,
                onError: OnError? = nil,
                onWrite: WriteTransform? = nil,
                onRead: @escaping ReadTransform)
    {
        self.onRead  = onRead
        _objectID = .init(wrappedValue: .init(objectID))
        _onWrite = .init(wrappedValue: .init(onWrite))
        _onError = .init(wrappedValue: .init(onError))
    }
    
    public var wrappedValue: Value {
        nonmutating set { self.write(newValue) }
        get {
            var output = Value(data: nil,
                               id: self.objectID.value,
                               onError: self.onError.value,
                               onWrite: self.onWrite.value)
            guard let input = self.object.value else { return output }
            output.data = self.onRead(input)
            return output
        }
    }
    
    public var projectedValue: Binding<Out>? {
        guard
            let input = self.object.value,
            let output = self.onRead(input)
        else { return nil }
        return Binding {
            output
        } set: {
            self.write($0)
        }
    }
    
    private func write(_ newValue: Value) {
        self.onWrite.value = newValue.onWrite
        self.onError.value = newValue.onError
        self.write(newValue.data)
        self.setObjectID(newValue.id)
    }
    
    private func write(_ newValue: Out?) {
        guard
            let onWrite = self.onWrite.value,
            let object = self.object.value,
            let newValue,
            newValue != self.onRead(object)
        else { return }
        let result = onWrite(object, newValue)
        guard let error = result.error else { return }
        self.onError.value?(error)
        assert(
            self.onError.value != nil,
            "An Error was thrown but ignored:\n\(String(describing: error))"
        )
    }
    
    private func setObjectID(_ newValue: URL?) {
        guard newValue != self.objectID.value else { return }
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
}
