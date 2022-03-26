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
    
    public typealias ReadTransform = (In) -> Out
    public typealias WriteTransform = (In?, Out?) -> Result<Void, E>
    
    private let objectIDURL: URL
    public let onRead: ReadTransform
    
    @EnvironmentQueue<E> private var errorQ
    @Environment(\.managedObjectContext) private var context
    
    @StateObject public var object: NilBox<In> = .init()
    @StateObject public var onWrite: BlackBox<WriteTransform?>
    @StateObject private var needsUpdate = BlackBox(true, isObservingValue: false)
    
    public init(objectIDURL: URL,
                onWrite: WriteTransform? = nil,
                onRead: @escaping ReadTransform)
    {
        self.objectIDURL = objectIDURL
        self.onRead = onRead
        _onWrite = .init(wrappedValue: BlackBox(onWrite, isObservingValue: false))
    }
    
    public mutating func update() {
        guard self.needsUpdate.value else { return }
        self.needsUpdate.value = false
        guard
            let psc = self.context.persistentStoreCoordinator,
            let id = psc.managedObjectID(forURIRepresentation: self.objectIDURL),
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
    
    private func write(newValue: Out?) {
        guard let onWrite = self.onWrite.value else {
            assertionFailure("Attempted to write value, but no write closure was given")
            return
        }
        guard let error = onWrite(self.object.value, newValue).error else { return }
        self.errorQ = error
    }
}
