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
public struct CDListQuery<In: NSManagedObject, Out>: DynamicProperty {
    
    public typealias OnError = (Swift.Error) -> Void
    public typealias ReadTransform = (In) -> Out
    
    public struct Value<C> {
        public let data: C
        public var configuration: Configuration
    }
    
    public struct Configuration: Equatable {
        public var predicate: NSPredicate?
        public var sortDescriptors: [SortDescriptor<In>] = []
    }
    
    private let onRead: ReadTransform
    @State private var configuration: Configuration
    @FetchRequest public var request: FetchedResults<In>
    
    public init(sort:      [SortDescriptor<In>] = [],
                predicate: NSPredicate? = .init(value: false),
                animation: Animation? = .default,
                onRead:    @escaping ReadTransform)
    {
        self.onRead    = onRead
        _configuration = .init(wrappedValue: .init(predicate: predicate,
                                                   sortDescriptors: sort))
        _request       = .init(entity: In.entity(),
                               sortDescriptors: sort.map { NSSortDescriptor($0) },
                               predicate: predicate,
                               animation: animation)
    }
    
    public var wrappedValue: Value<some RandomAccessCollection<Out>> {
        nonmutating set { self.write(newValue.configuration) }
        get {
            .init(data: self.request.lazy.map(self.onRead),
                  configuration: self.configuration)
        }
    }
    
    private let needsUpdate = SecretBox(true)
    public func update() {
        guard self.needsUpdate.value else { return }
        self.needsUpdate.value = false
        self.updateCoreData()
    }
    
    private func write(_ newValue: Configuration) {
        let oldConfiguration = self.configuration
        self.configuration = newValue
        guard oldConfiguration != newValue else { return }
        self.updateCoreData()
    }
    
    private func updateCoreData() {
        let newValue = self.configuration
        self.request.nsPredicate = newValue.predicate
        self.request.sortDescriptors = newValue.sortDescriptors
    }
}
