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
    
    public typealias ReadTransform = (In) -> Out?
    public typealias WriteTransform = (In, Out) -> Result<Void, Swift.Error>
    
    public struct Value {
        public let data: Out?
        public var configuration: Configuration = .init()
        public init(data: Out? = nil, configuration: Configuration) {
            self.data = data
            self.configuration = configuration
        }
    }
    
    public struct Configuration {
        public var objectID: URL?
        public var onWrite: WriteTransform?
        public var onError: OnError?
        public init(objectID: URL? = nil,
                    onWrite: WriteTransform? = nil,
                    onError: OnError? = nil)
        {
            self.objectID = objectID
            self.onWrite = onWrite
            self.onError = onError
        }
    }
    
    private let onRead: ReadTransform
    @State private var configuration: Configuration
    @StateObject private var object = NilBox<In>()
    
    @Environment(\.managedObjectContext) private var context
        
    public init(objectID: URL? = nil,
                onError: OnError? = nil,
                onWrite: WriteTransform? = nil,
                onRead: @escaping ReadTransform)
    {
        self.onRead  = onRead
        _configuration = .init(wrappedValue: .init(objectID: objectID,
                                                   onWrite: onWrite,
                                                   onError: onError))
    }
    
    /// Provides read only access to the value and read/write access to the configuration.
    /// To write to the value use the $ prefix
    public var wrappedValue: Value {
        nonmutating set { self.write(newValue.configuration) }
        get {
            guard let input = self.object.value else {
                return .init(configuration: self.configuration)
            }
            return .init(data: self.onRead(input),
                         configuration: self.configuration)
        }
    }
    
    /// Gives read/write access to the value
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
    
    private func write(_ newValue: Configuration) {
        let oldID = self.configuration.objectID
        self.configuration = newValue
        guard newValue.objectID != oldID else { return }
        self.updateCoreData()
    }
    
    private func updateCoreData() {
        guard
            let url = self.configuration.objectID,
            let psc = self.context.persistentStoreCoordinator,
            let id = psc.managedObjectID(forURIRepresentation: url),
            let object = self.context.object(with: id) as? In
        else {
            // TODO: Create error here
            self.object.value = nil
            return
        }
        self.object.value = object
    }
    
    private func write(_ newValue: Out?) {
        let config = self.configuration
        guard
            let onWrite = config.onWrite,
            let object = self.object.value,
            let newValue
        else { return }
        let result = onWrite(object, newValue)
        guard let error = result.error else { return }
        config.onError?(error)
        assert(
            config.onError != nil,
            "An Error was thrown but ignored:\n\(String(describing: error))"
        )
    }
}
