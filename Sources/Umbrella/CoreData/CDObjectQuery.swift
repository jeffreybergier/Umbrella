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
public struct CDObjectQuery<In: NSManagedObject, Out, E: Error>: DynamicProperty {
    
    public typealias OnError = (E) -> Void
    public typealias ReadTransform = (In) -> Out
    public typealias WriteTransform = (In?, Out?) -> Result<Void, E>
        
    @Environment(\.managedObjectContext) private var context
    
    private let onRead: ReadTransform
    @StateObject private var object = NilBox<In>()
    @StateObject private var onWrite: BlackBox<WriteTransform?>
    @StateObject private var onError: BlackBox<OnError?>
    @StateObject private var objectIDURL: BlackBox<URL?>
        
    public init(objectIDURL: URL? = nil,
                onError: OnError? = nil,
                onWrite: WriteTransform? = nil,
                onRead: @escaping ReadTransform)
    {
        self.onRead  = onRead
        _onWrite     = .init(wrappedValue: .init(onWrite, isObservingValue: false))
        _onError     = .init(wrappedValue: .init(onError, isObservingValue: false))
        _objectIDURL = .init(wrappedValue: .init(objectIDURL, isObservingValue: true))
    }
    
    public mutating func update() {
        guard let url = self.objectIDURL.value else { return }
        self.objectIDURL.value = nil
        guard
            let psc = self.context.persistentStoreCoordinator,
            let id = psc.managedObjectID(forURIRepresentation: url),
            let object = self.context.object(with: id) as? In
        else {
            // TODO: Create error here
            return
        }
        self.object.value = object
    }
    
    public var wrappedValue: Out? {
        get { self.object.value.map(self.onRead) }
        nonmutating set { self.write(newValue: newValue) }
    }
    
    public var projectedValue: Binding<Out>? {
        guard let object = self.object.value else { return nil }
        return Binding {
            self.onRead(object)
        } set: {
            self.write(newValue: $0)
        }
    }
    
    public func setOnWrite(_ newValue: WriteTransform?) {
        self.onWrite.value = newValue
    }
    
    public func setOnError(_ newValue: OnError?) {
        self.onError.value = newValue
    }
    
    public func setObjectIDURL(_ newValue: URL?) {
        self.object.value = nil
        self.objectIDURL.value = newValue
    }
    
    private func write(newValue: Out?) {
        guard let onWrite = self.onWrite.value else {
            assertionFailure("Attempted to write value, but no write closure was given")
            return
        }
        guard let error = onWrite(self.object.value, newValue).error else { return }
        self.onError.value?(error)
    }
}
